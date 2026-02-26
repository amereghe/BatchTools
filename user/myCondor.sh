#!/bin/bash

# run me as:
#      bash -ci '. BatchTools/user/myCondor.sh'

source ~/.bashrc

for myCase in `ls -d BeamSizeRoom1_noDELTARAY/????mm BeamSizeRoom1_PRECISIO/????mm` ; do
    echo "${myCase}"
    # cd ${myCase} ; pwd ; cd -
    cd ${myCase} ; my_condor_submit -spool condor.sub ; cd -
done

for ii in $(seq 3818 4057) ; do
    echo "my_condor_transfer_data ${ii}"
    my_condor_transfer_data ${ii}
done

for ii in $(seq 3677 1 3680) ; do
    for jj in $(seq 0 4) ; do
        echo "my_condor_ssh_to_job ${ii}.${jj}"
        my_condor_ssh_to_job ${ii}.${jj}
    done
done

# remaining time
for ii in $(seq 4078 1 4082) ; do
    for jj in $(seq 0 4) ; do
        tLine=`my_condor_ssh_to_job ${ii}.${jj} "grep -B1 'NEXT SEEDS' fluka_*/*.out | tail -2 | head -1"`
        remTimeH=`echo ${tLine} | awk '{remPart=$2; tPerPrim=$4; rT=remPart*tPerPrim; rTd=int(rT/(24*3600.)); rTh=int((rT-rTd*24*3600)/3600.); rTm=int((rT-rTd*24*3600-rTh*3600)/60.); rTs=int((rT-rTd*24*3600-rTh*3600-rTm*60)); printf ("rem time: %10.0fs (%10.3f ms/prim, %8.1f kPrim) ==> %5.0fd %5.0fh %5.0fm %5.0fs;\n",rT,tPerPrim*1000,remPart/1000,rTd,rTh,rTm,rTs)}'`
        echo "${ii}.${jj}: ${remTimeH}"
    done
done

for ii in $(seq 3858 4017) ; do
    echo "my_condor_rm ${ii}"
    my_condor_rm ${ii}
done
