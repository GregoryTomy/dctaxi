import optuna
import numpy as np
from kaen.hpo.optuna import BaseOptunaService


class DcTaxiHpoService(BaseOptunaService):
    def hparams(self):
        trial = self._trial

        # define hyperparameters
        return {
            "seed": trial.suggest_int("seed", 0, np.iinfo(np.int32).max - 1),
            "optimizer": trial.suggest_categorical("optimizer", ["Adam"]),
            "lr": trial.suggest_loguniform("lr", 0.001, 0.1),
            "num_hidden_neurons": [
                trial.suggest_categorical(
                    f"num_hidden_layer_{layer}_neurons", [7, 11, 13, 19, 23]
                )
                for layer in range(
                    trial.suggest_categorical("num_layers", [11, 13, 17, 19])
                )
            ],
            "batch_size": trial.suggest_categorical(
                "batch_size", [2**i for i in range(16, 22)]
            ),
            "max_batches": trial.suggest_int("max_batches", 40, 400, log=True),
        }

    def on_experiment_end(self, experiment, parent_run):
        study = self._study
        try:
            for key, fig in {
                "plot_param_importances": optuna.visualization.plot_param_importances(
                    study
                ),
                "plot_parallel_coordinate_all": optuna.visualization.plot_parallel_coordinate(
                    study,
                    params=[
                        "max_batches",
                        "lr",
                        "num_hidden_layer_0_neurons",
                        "num_hidden_layer_1_neurons",
                        "num_hidden_layer_2_neurons",
                    ],
                ),
                "plot_parallel_coordinate_l0_l1_l2": optuna.visualization.plot_parallel_coordinate(
                    study,
                    params=[
                        "num_hidden_layer_0_neurons",
                        "num_hidden_layer_1_neurons",
                        "num_hidden_layer_2_neurons",
                    ],
                ),
                "plot_contour_max_batches_lr": optuna.visualization.plot_contour(
                    study, params=["max_batches", "lr"]
                ),
            }.items():
                fig.write_image(key + ".png")
                self.mlflow_client.log_artifact(
                    run_id=parent_run.info.run_id, local_path=key + ".png"
                )

        except:
            print(f"Failed to correctly persist experiment visualization artifacts")
            import traceback

            traceback.print_exc()

        # log the dataframe with the study summary
        study.trials_dataframe().describe().to_html(experiment.name + ".html")
        self.mlflow_client.log_artifact(
            run_id=parent_run.info.run_id, local_path=experiment.name + ".html"
        )

        # log the best hyperparameters in the parent run
        self.mlflow_client.log_metric(parent_run.info.run_id, "loss", study.best_value)
        for k, v in study.best_params.items():
            self.mlflow_client.log_param(parent_run.info.run_id, k, v)
