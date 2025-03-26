#!/bin/bash

export FLUPRO=/usr/local/FLUKA/INFN/2021.2.9
export FLUKA=${FLUPRO}
export FLUFOR=gfortran
FLUKAexe=${FLUPRO}/flukahp
NN=0
MM=1

# start job
echo " starting job at `date` in folder $PWD as $USER on `hostname`..."

# run
for inputFile in `ls -1 *.inp` ; do
        echo "running command: ${FLUKA}/flutil/rfluka -e ${FLUKAexe} -N${NN} -M${MM} ${inputFile%.inp}"
        ${FLUKA}/flutil/rfluka -e ${FLUKAexe} -N${NN} -M${MM} ${inputFile%.inp}
        gzip ${inputFile%.inp}???.err ${inputFile%.inp}???.out ${inputFile%.inp}???.log
done

# post-processing (modify this part according to your needs)
for iUnit in $(seq 21 22) ; do
        echo "gzipping fort.${iUnit} files..."
        gzip *fort.${iUnit}
done

# end of job
echo " ...ending job at `date`."
