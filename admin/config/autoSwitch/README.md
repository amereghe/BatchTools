# AutoSwitch
This sub-folder contains all the material/info for enabling automatic switch of resources of an execution node in/out HTCondor.

## Working Principle
The idea is that a crontab job running on the execution node switches resources periodically. The amount of resources is declared in a specific .conf file of HTCondor:
* if the file *is* in the config folder of HTCondor, then the file is parsed and resources are moved out of HTCondor as soon as condor_restart is issued on the node;
* if the file is *not* in the config folder of HTCondor, then all the resources available in the hardware are made available to HTCondor.

The crontab job actually performs the switch only if a trigger file, found in a specific location, is present; if the trigger file is not present, the switch is inhibited, and the state of the resources does not change - no matter the actual state.

## Storing folder
A dedicated folder should be prepared storing the crontab job script, the trigger file and the .conf file of HTCondor (which describes how many resources should be spared) when it is not used.

A possible path and structure is:
```
$ pwd
/home/condset
$ ls -la
total 20
drwxrwxr-x 3 root condset 4096 apr 21 16:39 .
drwxr-xr-x 8 root root    4096 mar 31 09:48 ..
-rwxrwxr-- 1 root condset 7772 apr 21 16:41 switchHTC.sh
-rw-r--r-- 1 root condset 1105 apr 21 16:41 switchHTC.sh.log
-rw-rw-r-- 1 root condset    0 apr 21 16:19 .switch.me
$ ls -la .config
total 8
drwxr-xr-x 2 root condset 4096 apr 21 15:38 .
drwxrwxr-x 3 root condset 4096 apr 20 12:01 ..
```

All the files and subfolders belong to `root:condset` (`root` should be in the group).
The read/write/execute rights should be as indicated in the snippet above.
All people entitled to create/rename the trigger file should be in the `condset` group.

To create the `condset` group and populate it (as `root`):
```
$ addgroup condset
$ usermod -aG condset <userName>
```

## The trigger file
The trigger file is `.switch.me`:
* if present, then the switch takes place - no matter in which direction, i.e. in order to spare resources (e.g. for direct login) or to make them available to HTCondor;
* if the file is moved (i.e. named differently), then the switch is inhibited; hence, the resources are not moved.

It is extremely important the switch file, once created, it grants the correct rights to all concerned users, i.e.:
* it belongs to the `condset` linux group;
* it has write rights.

Renaming the file is the preferred option, such that the correct rights, once properly set, are kept. For this purpose, a couple of aliases can be defined (e.g. in `~/.bash_aliases`), e.g.
```
# bash
# - path to storing folder
export CondPath="/home/condset"
# - alias to trigger all resources into HTCondor
alias HTCTrigOn='mv ${CondPath}/.dont.switch.me ${CondPath}/.switch.me'
# - alias to spare resources out of HTCondor
alias HTCTrigOff='mv ${CondPath}/.switch.me ${CondPath}/.dont.switch.me'
# - alias to display the resources currently available to HTCondor
alias HTCStatRes='${CondPath}/switchHTC.sh -Q'
# - alias to display the status of the trigger
alias HTCStatTrg='ls ${CondPath}/*switch.me'
```

## The crontab job
The script of the crontab job can be run by `root` and by all users belonging to the `condset` group.
In this way, all concerned users have a quick way to check the status of resources.

An example of crontab job is:
```
# switch to spare resources out of HTCondor:
# - at 8PM from Monday through Friday to make all avaiable to HTCondor
# - at 6AM from Monday through Friday to spare some from HTCondor
00 20 *   *  1-5   cd /home/condset ; ./switchHTC.sh -F -d 2>&1 >> switchHTC.sh.log
00 6  *   *  1-5   cd /home/condset ; ./switchHTC.sh -S -d 2>&1 >> switchHTC.sh.log
```

The crontab job should be set as `root` via the `crontab -e` command (to edit the crontab).
To check the crontab list of `root`: `crontab -l` (as `root`).
