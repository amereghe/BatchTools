#!/bin/bash

pwd
hostname
whoami
groups
for ii in $( seq 180 ) ; do
    echo $ii
    sleep 10s
done
