#!/bin/bash

# myMachines="10.221.50.52 10.221.50.56"
# myMachines="192.168.1.103"
myMachines="192.168.1.100 192.168.1.101 192.168.1.102 192.168.1.103"
userName="marcop"
admiName="amereghe"
actCommand="
sudo useradd ${userName} --create-home -s /bin/bash -G fluka,dataers
sudo passwd ${userName}
sudo -u ${userName} /usr/bin/xdg-user-dirs-update
"
# actCommand="
# sudo useradd ${userName} --create-home -s /bin/bash
# sudo passwd ${userName}
# sudo -u ${userName} /usr/bin/xdg-user-dirs-update
# sudo usermod -aG sudo ${userName}
# "

echo "adding user ${userName} ..."
for myMachine in ${myMachines} ; do
    echo "...machine: ${myMachine};"
    echo "   ...creating user ${userName}, setting password and populating home folder..."
    ssh -t ${admiName}@${myMachine} "${actCommand}"
    echo "   ...done;"
done

echo "...done."
