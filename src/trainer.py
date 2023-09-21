from model import DcTaxiModel
import os
import kaen
from datetime import datetime
import torch as pt
import numpy as np
import pytorch_lightning as pl
import torch.distributed as dist
from torch.utils.data import DataLoader
from torch.nn.parallel import DistributedDataParallel

from kaen.torch import ObjectStorageDataset as osds


def train(model, train_glob, val_glob, test_glob=None):
    seed = (
        int(model.hparams["seed"])
        if "seed" in model.hparams
        else int(datetime.now().microsecond)
    )

    np.random.seed(seed)
    pt.manual_seed(seed)

    kaen.torch.init_process_group(model.layers)

    trainer = pl.Trainer(
        max_epochs=1,
        limit_train_batches=int(model.hparams.max_batches)
        if "max_batches" in model.hparams
        else 1,
        limit_val_batches=1,
        num_sanity_val_steps=1,
        val_check_interval=min(20, int(model.hparams.max_batches)),
        limit_test_batches=1,
        log_every_n_steps=1,
        gradient_clip_val=0.5
        #enable_progress_bar=True,
    )

    train_dl = DataLoader(
        osds(
            train_glob,
            worker=kaen.torch.get_worker_rank(),
            replicas=kaen.torch.get_num_replicas(),
            shard_size=int(model.hparams.batch_size),
            batch_size=int(model.hparams.batch_size),
            storage_options={"anon": False},
        ),
        pin_memory=True,
    )

    val_dl = DataLoader(
        osds(
            val_glob,
            batch_size=int(model.hparams.batch_size),
            storage_options={"anon": False},
        ),
        pin_memory=True,
    )

    trainer.fit(model, train_dataloaders=train_dl, val_dataloaders=val_dl)
    if test_glob is not None:
        test_dl = DataLoader(
            osds(
                test_glob,
                batch_size=int(model.hparams.batch_size),
                storage_options={"anon": False},
            ),
            pin_memory=True,
        )

        trainer.test(model, dataloaders=test_dl)

    return model, trainer


def main():
    model, trainer = train(
        DcTaxiModel(
            **{
                "seed": "1686523060",
                "num_features": "8",
                "num_hidden_neurons": "[3, 5, 8]",
                "batch_norm_linear_layers": "1",
                "optimizer": "Adam",
                "lr": "0.03",
                "max_batches": "1",
                "batch_size": "1000",
            }
        ),
        train_glob="https://raw.githubusercontent.com/osipov/smlbook/master/train.csv",
        test_glob="https://raw.githubusercontent.com/osipov/smlbook/master/test.csv",
        val_glob="https://raw.githubusercontent.com/osipov/smlbook/master/valid.csv",
    )
    print(trainer.callback_metrics)


if __name__ == "__main__":
    main()
