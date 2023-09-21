# Data Exploration



## Directory Structure

```plaintext
data-exploration/
├── 0_summary_stats.ipynb
├── 1_dctaxi_dev_test.py
└── 2_pyspark_dev_test.sh
```

## Files

1. 0_summary_stats.ipynb: This Jupyter notebook generates statistical summaries of the data, such as mean, standard deviation, and count, to guide the subsequent data sampling process.
2. 1_dctaxi_dev_test.py: A Python script that performs guided random sampling of data from an S3 bucket. It uses the previously computed summary statistics to guide the sampling process.
3. 2_pyspark_dev_test.sh: Bash script to execute the PySpark job, set environment variables, and manage the job's input parameters.

We also explore how to choose a statistically significant test sample size using methods like Standard Error of the Mean (SEM). 

## Usage

1. Run 0_summary_stats.ipynb to generate summary statistics.
2. Use 1_dctaxi_dev_test.py to perform guided sampling based on summary statistics.
3. Execute 2_pyspark_dev_test.sh to kick off the PySpark job.