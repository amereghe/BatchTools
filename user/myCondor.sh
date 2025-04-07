#!/bin/bash

# run me as:
#      bash -ci '. BatchTools/user/myCondor.sh'

source ~/.bashrc
for ii in $(seq 0 49) ; do
    echo "my_condor_transfer_data 107.${ii}"
    my_condor_transfer_data 107.${ii}
done

