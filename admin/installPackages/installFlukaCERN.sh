#!/usr/bin/bash

# run as root!

FLUKAverLong=4-5.2
lCopy=true
lSCopy=false
lClean=false
FLUKApath=FLUKA/CERN

die() {
  echo >&2 "$1"
  exit $E_BADARGS
}

# go to suitable folder
cd /usr/local
mkdir -p ${FLUKApath}/${FLUKAverLong}
cd ${FLUKApath}/${FLUKAverLong}

if ${lCopy} ; then
    echo "copying files..."
    cp /mnt/san_data/soft/FLUKA_CERN/fluka-${FLUKAverLong}.x86-Linux-gfor9.tgz .
elif ${lSCopy} ; then
    echo "scopying files..."
    scp amereghe@svpvclus01.cnao.group:/mnt/san_data/soft/FLUKA_CERN/fluka-${FLUKAverLong}.x86-Linux-gfor9.tgz .
fi

# untar material
tar xvzf fluka-${FLUKAverLong}.x86-Linux-gfor9.tgz
mv fluka${FLUKAverLong} ${FLUKAverLong}

# compile
cd ${FLUKAverLong}/src
make
cd -

# make installation available for the linux group fluka
chmod -R a+r .
chmod -R o-rx .
cd ../../../
chown -R root:fluka FLUKA
cd -

# clean away package files
! ${lClean} || rm fluka${FLUKAver}*tgz

# ls
ls -ltrh --color=auto ${FLUKAverLong}/bin
ls -ltrh --color=auto ${FLUKAverLong}
