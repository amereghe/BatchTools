#!/bin/bash

# run as root!

lDownload=false
lCopy=true
lSCopy=false
lClean=true

FLAIRpath=flair
flairVer=2.3-0f
flairVerShort=`echo ${flairVer} | cut -d\- -f1`
flairDist=INFN
pathT2bins="/usr/local/bin"
flairBins=( fcalc fless fm pt )
flairExes=( Calculator.py ViewerPage.py Manual.py PeriodicTable.py )

# go to suitable folder
cd /usr/local
mkdir -p ${FLAIRpath}/${flairDist}
cd ${FLAIRpath}/${flairDist}

# download stuff
if ${lDownload} ; then
    wget --no-check-certificate https://www.fluka.org/flair/flair-${flairVer}py3.tgz
    wget --no-check-certificate https://www.fluka.org/flair/flair-geoviewer-${flairVer}py3.tgz
elif ${lCopy} ; then
    cp /media/DATA/soft/flair-${flairVer}py3.tgz .
    cp /media/DATA/soft/flair-geoviewer-${flairVer}py3.tgz .
elif ${lSCopy} ; then
    scp amereghe@192.168.1.100:/media/DATA/soft/flair-${flairVer}py3.tgz .
    scp amereghe@192.168.1.100:/media/DATA/soft/flair-geoviewer-${flairVer}py3.tgz .
fi    

# create appropriate folder with downloaded material
tar xvzf flair-${flairVer}py3.tgz
tar xvzf flair-geoviewer-${flairVer}py3.tgz
mv flair-${flairVerShort} flair-${flairVer}
mv flair-geoviewer-${flairVerShort} flair-geoviewer-${flairVer}

# compile geoviewer
cd flair-geoviewer-${flairVer}
make
make install install-bin install-mime
cd -
cd /usr/local/${FLAIRpath}
mv *.geoviewer geoviewer.so usrbin2dvh fonts ${flairDist}/flair-${flairVer}
cd -

# user binaries
echo "regenerating ${pathT2bins}/flair ..."
cat << EOF > ${pathT2bins}/flair
#!/usr/bin/sh
flairDist=${flairDist}
flairVer=${flairVer}
"/usr/local/flair/\${flairDist}/flair-\${flairVer}/flair" \$*
EOF
chmod +x ${pathT2bins}/flair
for (( ii=0; ii<${#flairBins[@]}; ii++ )) ; do
    echo "regenerating ${pathT2bins}/${flairBins[${ii}]} ..."
    cat << EOF > ${pathT2bins}/${flairBins[${ii}]}
#!/usr/bin/sh
flairDist=${flairDist}
flairVer=${flairVer}
DIR="/usr/local/flair/\${flairDist}/flair-\${flairVer}"
PYTHONPATH=\${DIR}/lib python \${DIR}/${flairExes[${ii}]} \$*
EOF
    chmod +x ${pathT2bins}/${flairBins[${ii}]}
done

# make installation available for the linux group fluka
cd /usr/local
chown -R root:fluka ${FLAIRpath}
cd -

# clean away package files
if [ ${lClean} ] ; then
    rm flair*${flairVer}*.tgz
    rm -rf flair-geoviewer-${flairVer}
fi
