#!/bin/bash

# A.Mereghetti, 2022-11-28
# this is a template batch job file

RunFolder=$HOME
cd ${RunFolder}

# start batch job
echo " starting job at `date` in folder $PWD as $USER on `hostname`..."

# --------------------------------------
# actual simulation job
for ((ii=1;ii<=1200;ii++)); do
    echo "Hello world! ${ii}"
    sleep 1
done
# --------------------------------------

# end of batch job
cd - > /dev/null 2>&1
echo " ...ending job at `date`."
