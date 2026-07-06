#!/bin/bash

# the script uses sshpass
# sshpass can be installed on Ubuntu with:
# $ sudo apt update
# $ sudo apt install sshpass

ExeFolder="${PWD}"
myMachines=(
)
makeCommand="
cd ${ExeFolder}
export FLUPRO=/usr/local/FLUKA/INFN/2025.1.4
export FLUKA=${FLUPRO}
export FLUFOR=gfortran
make clean
make source_CNAOaccDB
make exe
ls -ltrh --color=auto
"

# prompt for the password securely and store it in SSHPASS
read -s -p "Enter the ssh password for all machines: " SSHPASS
echo "" # just to add a newline after the invisible input
export SSHPASS

echo "preparing FLUKA exe(s)..."
for myMachine in ${myMachines[@]} ; do
    echo "...machine: ${myMachine};"
    echo "...user: ${USER};"
    echo "...path: ${ExeFolder};"
    echo "   ...preparing folder (including cleaning existing files away)..."
    sshpass -e ssh -o StrictHostKeyChecking=no ${USER}@${myMachine} "rm -rf ${ExeFolder}; mkdir -p ${ExeFolder}"
    echo "   ...scp-ing source files..."
    sshpass -e scp -r -o StrictHostKeyChecking=no ${ExeFolder}/* ${USER}@${myMachine}:${ExeFolder}
    echo "   ...actually compiling..."
    sshpass -e ssh -t -o StrictHostKeyChecking=no ${USER}@${myMachine} "${makeCommand}"
done

echo "...done."
