import os
from model import DcTaxiModel
from trainer import train
from kaen.hpo.client import BaseMLFlowClient


class DcTaxiExperiment(BaseMLFlowClient):
    def on_run_start(self, run_idx, run):
        print(f"{run}({run.info.status}): starting...")

        # create a set of default hyperparameters
        default_hparams = {
            "seed": "1686523060",
            "num_features": "8",
            "num_hidden_neurons": "[3, 5, 8]",
            "batch_norm_linear_layers": "1",
            "optimizer": "Adam",
            "lr": "0.03",
            "max_batches": "1",
            "batch_size": 1000,
        }

        # fetch the MLFlow hyperparameters if available
        hparams = (
            run.data.params
            if run is not None and run.data is not None
            else default_hparams
        )

        # override the defaults with the MLFlow hyperparameters
        hparams = {**default_hparams, **hparams}

        untrained_model = DcTaxiModel(**hparams)

        def log(self, k, v, **kwargs):
            if self.mlflow_client and 0 == int(os.environ["KAEN_RANK"]):
                if "step" in kwargs and kwargs["step"] is not None:
                    self.mlflow_client.log_metric(
                        run.info.run_id, k, v, step=kwargs["step"]
                    )
                else:
                    self.mlflow_client.log_metric(run.info.run_id, k, v)

        import types

        untrained_model.log = types.MethodType(log, self)

        model, trainer = train(
            untrained_model,
            train_glob=os.environ["KAEN_OSDS_TRAIN_GLOB"],
            val_glob=os.environ["KAEN_OSDS_VAL_GLOB"],
            test_glob=os.environ["KAEN_OSDS_TEST_GLOB"],
        )

        print(trainer.callback_metrics)
