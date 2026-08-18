#!/bin/bash

# run as root!

lDownload=false
lCopy=true
lSCopy=false
lClean=false

FLAIRpath=flair
flairVer=3.4-5.4
flairVerShort=`echo ${flairVer} | cut -d\- -f1`
flairDist=CERN
pathT2bins="/usr/local/bin"
flairBins=( fcalc fless fm pt )
flairExes=( Calculator.py ViewerPage.py Manual.py PeriodicTable.py )

# go to suitable folder
cd /usr/local
mkdir -p ${FLAIRpath}/${flairDist}
cd ${FLAIRpath}/${flairDist}

# download stuff
if ${lDownload} ; then
    wget --no-check-certificate https://flair.cern/download/flair-${flairVer}.tgz
    wget --no-check-certificate https://flair.cern/download/flair-geoviewer-${flairVer}.tgz
elif ${lCopy} ; then
    cp /mnt/san_data/soft/flair/CERN/flair-${flairVer}.tgz .
    cp /mnt/san_data/soft/flair/CERN/flair-geoviewer-${flairVer}.tgz .
elif ${lSCopy} ; then
    scp amereghe@svpvclus01.cnao.group:/mnt/san_data/soft/flair/CERN/flair-${flairVer}.tgz .
    scp amereghe@svpvclus01.cnao.group:/mnt/san_data/soft/flair/CERN/flair-geoviewer-${flairVer}.tgz .
fi

# create appropriate folder with downloaded material
tar xvzf flair-${flairVer}.tgz
tar xvzf flair-geoviewer-${flairVer}.tgz
mv flair-${flairVerShort} flair-${flairVer}
mv flair-geoviewer-${flairVerShort} flair-geoviewer-${flairVer}

# compile geoviewer
cd flair-geoviewer-${flairVer}
make
# make install-bin and install-mime do not exist!
# make install install-bin install-mime
make install
cd -
cd /usr/local/${FLAIRpath}
mv *.geoviewer geoviewer.so usrbin2dvh fonts meshtk ${flairDist}/flair-${flairVer}
cd -

# user binaries
echo "regenerating ${pathT2bins}/flair_CERN ..."
cat << EOF > ${pathT2bins}/flair_CERN
#!/usr/bin/sh
"/usr/local/flair/${flairDist}/flair-${flairVer}/flair" \$*
EOF
chmod +x ${pathT2bins}/flair_CERN
for (( ii=0; ii<${#flairBins[@]}; ii++ )) ; do
    echo "regenerating ${pathT2bins}/${flairBins[${ii}]}_CERN ..."
    cat << EOF > ${pathT2bins}/${flairBins[${ii}]}_CERN
#!/usr/bin/sh
DIR="/usr/local/flair/${flairDist}/flair-${flairVer}"
PYTHONPATH=\${DIR}/lib python3 \${DIR}/${flairExes[${ii}]} \$*
EOF
    chmod +x ${pathT2bins}/${flairBins[${ii}]}_CERN
done

# make installation available for the linux group fluka
cd /usr/local
chown -R root:fluka ${FLAIRpath}
cd -

# clean away package files
if ${lClean} ; then
    echo "cleaning..."
    rm flair*${flairVer}*.tgz
    rm -rf flair-geoviewer-${flairVer}
fi

# fix permissions
chmod -R a+r /usr/local/${FLAIRpath}
chown -R root:fluka /usr/local/bin

# compilation fails on Ubuntu 20.04 because of missing GL/gl.h 
# --> to find it:
# $ apt-file search "GL/gl.h"
# (for installation: apt install apt-file)
# (for updating package DB: apt-file update)
# libgl-dev: /usr/include/GL/gl.h           
# $ apt-get install libgl-dev
# $ apt-get install libogre-1.9-dev
