#!/bin/bash

export FLUPRO=/usr/local/FLUKA/INFN/2024.1.3
export FLUKA=${FLUPRO}
export FLUFOR=gfortran
FLUKAexe=${FLUPRO}/flukadpm3
inputFile=`ls -1 *inp | head -1`
NN=0
MM=1

# start job
echo " starting job at `date` in folder $PWD..."

#  run
echo "running command: ${FLUKA}/flutil/rfluka -e ${FLUKAexe} -N${NN} -M${MM} ${inputFile%.inp}"
${FLUKA}/flutil/rfluka -e ${FLUKAexe} -N${NN} -M${MM} ${inputFile%.inp}

# end of job
echo " ...ending job at `date`."
