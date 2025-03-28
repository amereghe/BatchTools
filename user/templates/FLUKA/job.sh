#!/bin/bash

export FLUPRO=/usr/local/FLUKA_INFN/2024.1.3
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
    echo ""
    for ext in err out log ; do
        echo "gzipping ${inputFile%.inp}???.${ext}..."
        gzip ${inputFile%.inp}???.${ext}
    done
done

# post-processing (modify this part according to your needs)
for iUnit in $(seq 21 22) ; do
    echo "gzipping fort.${iUnit} files..."
    gzip *fort.${iUnit}
done

# end of job
echo " ...ending job at `date`."
