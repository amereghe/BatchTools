#!/bin/bash

export FLUPRO=/usr/local/FLUKA/INFN/2025.1.2
export FLUKA=${FLUPRO}
export FLUFOR=gfortran
FLUKAexe=${FLUPRO}/flukahp
inputFile=`ls -1 *.inp | tail -1`
NN=0
MM=1

# start job
echo " starting job at `date` in folder `pwd` as `whoami` on `hostname`..."

# run
echo "running command: ${FLUKA}/flutil/rfluka -e ${FLUKAexe} -N${NN} -M${MM} ${inputFile%.inp}"
${FLUKA}/flutil/rfluka -e ${FLUKAexe} -N${NN} -M${MM} ${inputFile%.inp}

# post-processing (modify this part according to your needs)
for ext in err out log ; do
    echo "gzipping ${inputFile%.inp}???.${ext}..."
    gzip ${inputFile%.inp}???.${ext}
done
for iUnit in $(seq 21 22) ; do
    echo "gzipping fort.${iUnit} files..."
    gzip *fort.${iUnit}
done

# end of job
echo " ...ending job at `date`."
