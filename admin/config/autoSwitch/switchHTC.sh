#!/bin/bash

# the script must be run as root in a specific folder (e.g. /home/condset)
# $ ll /home/condset
# drwxrwxr-x 2 root condset 4096 mar 31 09:48 ./
# drwxr-xr-x 8 root root    4096 mar 31 09:48 ../
# the condset linux group contains all people that can activate/deactivate
#     the move of resources in/out of HTCondor
# the HTCsparConfigFile is the HTCondor config file sparing resources
#     it is moved back and forth between the /home/condset and the HTCondor
#     config folder

HTCset=`dirname $0`
HTCconfig=`condor_config_val LOCAL_CONFIG_DIR`
HTCexecute=`condor_config_val EXECUTE`
# actions:
lFull=false
lSpare=false
lQuery=true
# options
lDebug=false
HTCsparConfigFile="52-spare-resources.conf"
HTCsparTrigger=".switch.me"
HTCSparCPUs=20 # []
HTCSparRAM=65 # [GB]
# script version
scriptVer="0.1"

# ==============================================================================
# FUNCTIONs
# ==============================================================================

die() {
  echo "$1"
  exit $2
}

how_to_use() {
       script_name=`basename $0`
cat <<EOF

       ${script_name} [actions] [options]

                   ==> Version number ${scriptVer} <==

       Script for sparing resources from HTCondor for login and for restoring
         resources back to HTCondor

       actions:
       -F  full:       restores full resources to HTCondor

       -H  help:       prints this help

       -Q  query:      query status of resources

       -S  spare:      stops jobs, reset resources to a lower level and resumes
                         node activity.

       options:
       -d  debug mode: debug output is on (default: ${lDebug})

       -f  spare file: name of HTCondor config file describing resources to
                         be spared (default: ${HTCsparConfigFile})

       -n  spare CPUs: number of CPUs to spare (default: ${HTCSparCPUs})

       -r  spare RAM:  RAM to spare (in GB - default: ${HTCSparRAM})
EOF
}

gentlyStopJobs(){
    echo "gently stopping jobs..."
    echo "...FLUKA jobs..."
    find ${HTCexecute} -name "fluka_*" -exec touch {}/rfluka.stop \;
    echo "...done;"
}

waitForJobsToFinish(){
    nWaitMax=10
    echo "waiting for stopping jobs..."
    echo "...waiting for FLUKA jobs to finish..."
    nWait=0
    while [ `find ${HTCexecute} -name "fluka_*" | wc -l` -ne 0 ] ; do
        let nWait=nWait+1
        echo "...still `find ${HTCexecute} -name "fluka_*" | wc -l` jobs running. Waiting (${nWait}/${nWaitMax})..."
        sleep 1m
        if [ ${nWait} -ge ${nWaitMax} ] ; then
            echo "...waited ${nWait} times. End wait!"
            break
        fi
    done
    echo "...done;"
}

echoResources(){
    for myResource in MEMORY RESERVED_MEMORY NUM_CPUS ; do
        echo "               condor_config_val ${myResource}: `condor_config_val ${myResource}`"
    done
}

switchResources() {
    echo "call to switchResources()"
    lSwitch=false
    # steps:
    # 1. stop HTCondor node
    # 2. either of the two possibilities:
    #    - restore HTCondor .conf file sparing resources in config dir
    #    - move HTCondor .conf file sparing resources out of config dir
    # 3. gently stop jobs and wait for them to be over
    # 4. restart HTCondor on node (this will kill jobs still running)
    if ${lSpare} ; then
        if [ -e ${HTCset}/.config/${HTCsparConfigFile} ] ; then
            echo "... ${HTCsparConfigFile} present in ${HTCset}/.config: moving all spared resources of the node back to HTCondor..."
            lSwitch=true
        else
            echo "...no ${HTCsparConfigFile} in ${HTCset}/.config: aborting switch..."
        fi
    elif ${lFull} ; then
        if [ -e ${HTCconfig}/${HTCsparConfigFile} ] ; then
            echo "... ${HTCsparConfigFile} present in ${HTCconfig}: sparing resources of the node from HTCondor..."
            lSwitch=true
        else
            echo "...no ${HTCsparConfigFile} in ${HTCconfig}: aborting switch..."
        fi
    fi

    if ${lSwitch} ; then
        if ${lQuery} ; then
            echo "...debug info: situation BEFORE switch:"
            echoResources
        fi
        ! ${lDebug} || echo "...debug info: condor_off -peaceful -startd"
        condor_off -peaceful -startd
        if ${lSpare} ; then
            ! ${lDebug} || echo "...debug info: mv ${HTCset}/.config/${HTCsparConfigFile} ${HTCconfig}"
            mv ${HTCset}/.config/${HTCsparConfigFile} ${HTCconfig}
        elif ${lFull} ; then
            ! ${lDebug} || echo "...debug info: mv ${HTCconfig}/${HTCsparConfigFile} ${HTCset}/.config"
            mv ${HTCconfig}/${HTCsparConfigFile} ${HTCset}/.config
        fi
        ! ${lDebug} || echo "...debug info: gentlyStopJobs()"
        gentlyStopJobs
        ! ${lDebug} || echo "...debug info: waitForJobsToFinish()"
        waitForJobsToFinish
        ! ${lDebug} || echo "...debug info: condor_restart (killing remaining jobs)"
        condor_restart
    else
    fi
    echo "...done;"
}

# ==============================================================================
# MAIN
# ==============================================================================

# log terminal line command
echo ""
echo "`date +"[%Y-%m-%d %H:%M:%S]"` ==> ver ${scriptVer} <== $0 $*"

# ==============================================================================
# OPTIONs
# ==============================================================================

while getopts  ":dFQHn:r:S" opt ; do
    case $opt in
        d)
            lDebug=true
            ;;
        F)
            lFull=true
            ;;
        H)
            how_to_use
            die "" 0
            ;;
        n)
            HTCSparCPUs=$OPTARG
            ;;
        Q)
            lQuery=true
            ;;
        r)
            HTCSparRAM=$OPTARG
            ;;
        S)
            lSpare=true
            ;;
        \?)
            die "Invalid option: -$OPTARG"
            ;;
        :)
            die "Option -$OPTARG requires an argument."
            ;;
    esac
done

# ==============================================================================
# CHECKs
# ==============================================================================

# terminal-line request
if ${lFull} && ${lSpare} ; then
    die "which action? either -F OR -S, NEVER both at the same time!" 1
elif ! ${lFull} && ! ${lSpare} && ! ${lQuery} ; then
    die "please choose an action! either -F OR -Q OR -S!" 1
fi

# variables
[ -n "${HTCset}" ] || die "something wrong with detecting condset path" 1
HTCset=`realpath ${HTCset}`
[ -n "${HTCconfig}" ] || die "something wrong with detecting condor config folder" 1
HTCconfig=${HTCconfig/,/ }
# get actual HTCondor config folder
lFound=false
for myHTCconfig in ${HTCconfig[@]} ; do
    nFound=`find ${myHTCconfig} -name "*.conf" | wc -l`
    [ ${nFound} -eq 0 ] || lFound=true
    ! ${lFound} || break
done
if ! ${lFound} ; then
    die "cannot identify actual conf folder of HTCondor"
else
    HTCconfig=${myHTCconfig}
fi

if ${lDebug} ; then
    echo "debug info: HTC setting folder: ${HTCset}"
    echo "debug info: HTC config folder: ${HTCconfig}"
fi

# ==============================================================================
# ACTUAL JOB
# ==============================================================================

if [ -e ${HTCset}/${HTCsparTrigger} ] ; then
    switchResources
else
    echo "...file ${HTCsparTrigger} NOT in folder ${HTCset}: aborting switch..."
fi

if ${lQuery} ; then
    echo "...situation of resources:"
    echoResources
fi

# ==============================================================================
# done
# ==============================================================================

die "...done." 0
