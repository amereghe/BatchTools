#!/bin/bash

# the script must be run as root in a specific folder (e.g. /home/condset)
# $ ll /home/condset
# drwxrwxr-x 2 root condset 4096 mar 31 09:48 ./
# drwxr-xr-x 8 root root    4096 mar 31 09:48 ../
# the condset linux group contains all people that can activate/deactivate
#     the move of resources in/out of HTCondor
# the HTCsparingConfigFile is the HTCondor config file sparing resources
#     it is moved back and forth between the /home/condset and the HTCondor
#     config folder

HTCset=`dirname $0`
HTCconfig=`condor_config_val LOCAL_CONFIG_DIR`
HTCexecute=`condor_config_val EXECUTE`
HTCsparingConfigFile="52-reduce-resources-for-bioIng.conf"
HTCtrigger="switch.me"
lDebug=true
# actions:
lFull=false
lSpare=false
lQuery=true
# script version
scriptVer="0.1"

# ==============================================================================
# FUNCTIONs
# ==============================================================================

die() {
  echo >&2 "$1"
  exit $2
}

how_to_use() {
       script_name=`basename $0`
cat <<EOF

       ${script_name} [actions]

                   ==> Version number ${scriptVer} <==

       Script for sparing resources from HTCondor for login and for restoring
         resources back to HTCondor

       actions:
       -F  full:     restores full resources to HTCondor

       -H  help:     prints this help

       -Q  query:    query status of resources

       -S  spare:    stops jobs, reset resources to a lower level and resumes
                     node activity.

EOF
}

gentlyStopFLUKAjobs(){
    echo "gently stopping FLUKA jobs..."
    lTouched=false
    nWaitMax=10
    nWait=0
    for flukaFolder in `find ${HTCexecute} -name "fluka_*"` ; do
        echo "...stopping job in folder ${flukaFolder} ..."
        touch ${flukaFolder}/rfluka.stop
        lTouched=true
    done
    if ${lTouched} ; then
        echo "...waiting for FLUKA jobs to finish..."
        find ${HTCexecute} -name "fluka_*" | wc -l
        # while [ `find ${HTCexecute} -name "fluka_*" | wc -l` -ne 0 ] ; do
        #     echo "...still `find ${HTCexecute} -name "fluka_*" | wc -l` jobs running. Waiting..."
        #     sleep 1m
        #     let nWait=nWait+1
        #     if [ ${nWait} -ge ${nWaitMax} ] ; then
        #         echo "...waited ${nWait} times. End wait!"
        #         break
        #     fi
        # done
    fi
    echo "...done;"
}

echoResources(){
    for myResource in MEMORY NUM_CPUS ; do
        echo "               condor_config_val ${myResource}: `condor_config_val ${myResource}`"
    done
}

fullHTC() {
    echo "call to fullHTC()"
    # steps:
    # 1. gently stop HTCondor node
    # 2. gently stop jobs
    # 3. move HTCondor .conf file sparing resources out of config dir
    # 4. restart HTCondor on node
    if [ -e ${HTCconfig}/${HTCsparingConfigFile} ] ; then
        echo "... ${HTCsparingConfigFile} present in ${HTCconfig}: let's proceed with switching..."
        if ${lQuery} ; then
            echo "...debug info: situation BEFORE switch:"
            echoResources
        fi
        ! ${lDebug} || echo "...debug info: condor_off -startd"
        condor_off -startd
        ! ${lDebug} || echo "...debug info: gentlyStopFLUKAjobs"
        ! ${lDebug} || echo "...debug info: mv ${HTCconfig}/${HTCsparingConfigFile} ${HTCset}/.config"
        mv ${HTCconfig}/${HTCsparingConfigFile} ${HTCset}/.config
        ! ${lDebug} || echo "...debug info: condor_restart"
        condor_restart
    else
        echo "...no ${HTCsparingConfigFile} in ${HTCconfig}: aborting switch..."
    fi
    echo "...done;"
}

spareResources() {
    echo "call to spareResources()"
    # steps:
    # 1. gently stop HTCondor node
    # 2. gently stop jobs
    # 3. restore HTCondor .conf file sparing resources in config dir
    # 4. restart HTCondor on node
    if [ -e ${HTCset}/.config/${HTCsparingConfigFile} ] ; then
        echo "... ${HTCsparingConfigFile} present in ${HTCset}/.config: let's proceed with switching..."
        if ${lQuery} ; then
            echo "...debug info: situation BEFORE switch:"
            echoResources
        fi
        ! ${lDebug} || echo "...debug info: condor_off -startd"
        condor_off -startd
        ! ${lDebug} || echo "...debug info: gentlyStopFLUKAjobs"
        ! ${lDebug} || echo "...debug info: mv  ${HTCset}/.config/${HTCsparingConfigFile} ${HTCconfig}"
        mv  ${HTCset}/.config/${HTCsparingConfigFile} ${HTCconfig}
        ! ${lDebug} || echo "...debug info: condor_restart"
        condor_restart
    else
        echo "...no ${HTCsparingConfigFile} in ${HTCset}/.config: aborting switch..."
    fi
    echo "...done;"
}

# ==============================================================================
# MAIN
# ==============================================================================

# log terminal line command
echo "`date +"[%Y-%m-%d %H:%M:%S]"` ==> ver ${scriptVer} <== $0 $*"

# ==============================================================================
# OPTIONs
# ==============================================================================

while getopts  ":FQHS" opt ; do
    case $opt in
        F)
            lFull=true
            ;;
        H)
            how_to_use
            die "" 0
            ;;
        Q)
            lQuery=true
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

if [ -e ${HTCset}/${HTCtrigger} ] ; then
    if ${lFull} ; then
        echo "moving all spared resources of the node back to HTCondor..."
        fullHTC
    elif ${lSpare} ; then
        echo "sparing resources of the node from HTCondor..."
        spareResources
    else
        echo "query resources:"
    fi
else
    echo "...file ${HTCtrigger} NOT in folder ${HTCset}: aborting switch..."
fi

if ${lQuery} ; then
    echo "...situation of resources:"
    echoResources
fi

# ==============================================================================
# done
# ==============================================================================

die "...done." 0
