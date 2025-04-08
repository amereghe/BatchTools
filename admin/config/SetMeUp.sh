#!/bin/bash

# central manager IP
export central_manager_name=192.168.1.100

# POOL password
export htcondor_password=MyHTC0nd0r~CN@0!


# INSTALLATION (as root)
# from https://htcondor.readthedocs.io/en/latest/getting-htcondor/admin-quick-start.html
# - create central manager
curl -fsSL https://get.htcondor.org | GET_HTCONDOR_PASSWORD="$htcondor_password" /bin/bash -s -- --no-dry-run --central-manager $central_manager_name
# - create submit node
curl -fsSL https://get.htcondor.org | GET_HTCONDOR_PASSWORD="$htcondor_password" /bin/bash -s -- --no-dry-run --submit $central_manager_name
# - create execute node
curl -fsSL https://get.htcondor.org | GET_HTCONDOR_PASSWORD="$htcondor_password" /bin/bash -s -- --no-dry-run --execute $central_manager_name
# - download mini-condor
curl -fsSL https://get.htcondor.org | /bin/bash -s -- --no-dry-run

# REMOVAL (as root)
# - rm htcondor installation
sh -c "apt-get -y remove --purge condor && apt-get -y autoremove --purge && rm -fr /etc/condor"
# - rm minicondor installation
sh -c "apt-get -y remove --purge minicondor && apt-get -y autoremove --purge && rm -fr /etc/condor"
