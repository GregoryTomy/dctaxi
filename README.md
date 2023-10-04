# DC Taxi Fare Prediction Model [Project README in progress]

## Overview

The purpose of this project is to build a machine learning model that can predict the taxi fare in Washington D.C. The model is trained on a large dataset of taxi rides, which includes features such as distance, time of the day, and day of the week. The codebase is structured to be modular, easily extensible, and integrates with MLFlow for experiment tracking and Kaen for distributed training. It uses a Neural Network architecture built with PyTorch and leverages PyTorch Lightning for easier training and validation. The project also utilizes several cloud and data processing technologies to create a robust and scalable system.

## Major Technologies Used

* **PyTorch**: Used to build the neural network architecture. It allows for dynamic computation graphs and is very flexible, making it a good fit for research.
* **PyTorch Lightning**: An extension of PyTorch that helps organize PyTorch code and makes it more readable and scalable. Used for training, validation, and testing steps.
* **Docker**: Docker containers encapsulate the software, libraries, and operating system in a single package, ensuring that the application runs consistently across multiple computing environments.
* **AWS**:
    *  EC2: Virtual servers for running the application.
    * S3: Used for storing the datasets.
    * AWS Lambda: Serverless compute, mainly used for triggered actions and logs.
* **PySpark**: Used for efficient data manipulation and preparation. Ideal for handling large-scale data.
* **MLFlow**: An open-source platform that manages the machine learning lifecycle, including experimentation, reproducibility, and deployment. It integrates well with other frameworks like PyTorch and can be hosted on AWS. 
* **Optuna**: An open-source hyperparameter optimization framework in Python. Used for automating the search for the most effective hyperparameters for machine learning models.

## Project Structure 

```plaintext
.
├── athena
├── data-exploration
├── data-loading
├── data-preprocessing
├── lightning_logs
├── logs
├── src
│   ├── experiment.py
│   ├── hpo.py
│   ├── model.py
│   └── trainer.py
├── study
├── tests
└── utils.sh
```

## Src
### experiment.py
This script sets up the hyperparameter experiment for the model. It initializes the experiment client and sets the hyperparameters for the machine learning model. It also imports the model and training logic to be used for the experiment. It includes:


### hpo.py
This is where hyperparameter optimization (HPO) is performed. It leverages Kaen's `BaseMLFlowClient` to handle HPO tasks. Kaen uses Optuna under the hood for the actual optimization. The hyperparameters are dynamically defined using Optuna's suggest_* methods. Logging of hyperparameters and metrics is done through the MLflow client, which is part of Kaen's framework.

### model.py
Defines the architecture of the neural network model (DcTaxiModel) used for predicting taxi fares. Built using PyTorch Lightning, it includes:

1. **__init__**: Initializes layers, sets the random seed, etc.
2. **forward**: Implements the forward pass.
3. **training_step**: Defines what happens in a single training step.
4. **test_step**: Defines what happens in a single test step.
5. **validation_step**: Defines what happens in a single validation step.
6. **configure_optimizers**: Sets up the optimizer for training.

### experiment.py
The experiment.py file adds integration between the `DcTaxiModel` and the MLFlow framework for managing and tracking Hyperparameter Optimization (HPO) experiments. Specifically, it utilizes subclasses of BaseMLFlowClient for this purpose.


