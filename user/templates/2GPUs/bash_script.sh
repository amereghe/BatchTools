#!/bin/bash

# Path to conda environment
CONDA_PATH="/home/luna/local/anaconda3/bin/activate"
CONDA_ENV="/home/luna/research/cenvs/myenv"

# Initialize conda for bash
source "$CONDA_PATH"

# Activate environment
conda activate "$CONDA_ENV"

# Run the python script
python py_script.py

