#!/bin/bash

ExeFolder="${PWD}"
myMachines="192.168.1.100 192.168.1.101 192.168.1.102"
makeCommand="
cd ${ExeFolder}
export FLUPRO=/usr/local/FLUKA/INFN/2024.1.3
export FLUKA=${FLUPRO}
export FLUFOR=gfortran
make clean
make source_CNAOaccDB
make exe
ls -ltrh --color=auto
"

echo "preparing FLUKA exe(s)..."
for myMachine in ${myMachines} ; do
    echo "...machine: ${myMachine};"
    echo "...user: ${USER};"
    echo "...path: ${ExeFolder};"
    echo "   ...preparing folder (including cleaning existing files away)..."
    ssh ${USER}@${myMachine} "rm -rf ${ExeFolder}; mkdir -p ${ExeFolder}"
    echo "   ...scp-ing source files..."
    scp -r ${ExeFolder}/* ${USER}@${myMachine}:${ExeFolder}
    echo "   ...actually compiling..."
    ssh -t ${USER}@${myMachine} "${makeCommand}"
done

echo "...done."
