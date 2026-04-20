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
lFull=false
lSpare=false
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

fullHTC() {
    echo "call to fullHTC()"
    # gently stop HTCondor node
    # gently stop jobs
    # move HTCondor .conf file sparing resources out of config dir
    # restart HTCondor
    lMove=false
    for HTCconfDir in ${HTCconfig} ; do
        if [ -e ${HTCconfDir}/${HTCsparingConfigFile} ] ; then
            lMove=true
            break
        fi
    done
    if ${lMove} ; then
        echo "... ${HTCsparingConfigFile} present in ${HTCconfDir}: let's proceed with switching..."
        echo "mv ${HTCconfDir}/${HTCsparingConfigFile} ${HTCset}/.config"
        echo "condor_off -startd"
        echo "gentlyStopFLUKAjobs"
        echo "condor_restart"
    else
        echo "... no ${HTCsparingConfigFile} in ${HTCconfDir}: aborting switch..."
    fi
    echo "...done;"
}

spareResources() {
    echo "call to spareResources()"
    # gently stop HTCondor node
    # gently stop jobs
    # restore HTCondor .conf file sparing resources in config dir
    # restart HTCondor
    if [ -e ${HTCset}/.config/${HTCsparingConfigFile} ] ; then
        echo "... ${HTCsparingConfigFile} present in ${HTCset}/.config: let's proceed with switching..."
        echo "condor_off -startd"
        echo "gentlyStopFLUKAjobs"
        echo "condor_restart"
    else
        echo "... no ${HTCsparingConfigFile} in ${HTCset}/.config: aborting switch..."
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

while getopts  ":FHS" opt ; do
    case $opt in
        F)
            lFull=true
            ;;
        H)
            how_to_use
            die "" 0
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
fi

# variables
[ -n "${HTCset}" ] || die "something wrong with detecting condset path" 1
HTCset=`realpath ${HTCset}`
[ -n "${HTCconfig}" ] || die "something wrong with detecting condor config folder" 1
HTCconfig=${HTCconfig/,/ }

echo "${HTCset}"
echo "${HTCconfig}"

if [ -e ${HTCset}/${HTCtrigger} ] ; then
    if ${lFull} ; then
        echo "moving all spared resources back to HTCondor..."
        fullHTC
    else
        echo "sparing resources from HTCondor..."
        spareResources
    fi
else
    echo "...file ${HTCtrigger} NOT in folder ${HTCset}: aborting switch..."
fi

# ==============================================================================
# done
# ==============================================================================

die "...done." 0
