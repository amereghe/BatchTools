#!/usr/bin/bash

# run as root!

# set env vars
credFileName="myCredentials.sh" # contains myUserID and myUserPass vars (necessary only for download)
FLUKAverLong=2025.1.0
FLUKAver=`echo ${FLUKAverLong} | cut -d\. -f1,2`
# check your version against those available on the FLUKA website!
#   choose the version on the web <= to yours
# UBUNTU_20.04.1
# GFORver=9.4  # gfortran --version
# GLIBCver=2.17 # ldd --version
GFORver=11.4  # gfortran --version
GLIBCver=2.35 # ldd --version
lDownload=false
lCopy=false
lSCopy=true
lClean=true
FLUKApath=FLUKA/INFN

die() {
  echo >&2 "$1"
  exit $E_BADARGS
}

# go to suitable folder
cd /usr/local
mkdir -p ${FLUKApath}/${FLUKAverLong}
cd ${FLUKApath}/${FLUKAverLong}

# download stuff
if ${lDownload} ; then
    ! [ -e ./${credFileName} ] || source ./${credFileName}
    ! [ -e `dirname $0`/${credFileName} ] || source `dirname $0`/${credFileName}
    ! [ -z "${myUserID}" ] || die "myUserID var NOT defined!"
    ! [ -z "${myUserPass}" ] || die "myUserPass var NOT defined!"
    wget --user ${myUserID} --password ${myUserPass} --no-check-certificate https://www.fluka.org/packages/fluka${FLUKAver}-linux-gfor64bit-${GFORver}-glibc${GLIBCver}-AA.tar.gz
    wget --user ${myUserID} --password ${myUserPass} --no-check-certificate https://www.fluka.org/packages/fluka${FLUKAver}-data.tar.gz
elif ${lCopy} ; then
    cp /media/DATA/soft/FLUKA_${FLUKAverLong}/fluka${FLUKAver}-linux-gfor64bit-${GFORver}-glibc${GLIBCver}-AA.tar.gz .
    cp /media/DATA/soft/FLUKA_${FLUKAverLong}/fluka${FLUKAver}-data.tar.gz .
elif ${lSCopy} ; then
    scp amereghe@192.168.1.100:/media/DATA/soft/FLUKA_${FLUKAverLong}/fluka${FLUKAver}-linux-gfor64bit-${GFORver}-glibc${GLIBCver}-AA.tar.gz .
    scp amereghe@192.168.1.100:/media/DATA/soft/FLUKA_${FLUKAverLong}/fluka${FLUKAver}-data.tar.gz .
fi    

# create appropriate folder with downloaded material
tar xvzf fluka${FLUKAver}-linux-gfor64bit-${GFORver}-glibc${GLIBCver}-AA.tar.gz
tar xvzf fluka${FLUKAver}-data.tar.gz

# prepare for installation
export FLUPRO=$PWD
export FLUKA=${FLUPRO}
export FLUFOR=gfortran

# compile
make ; $FLUPRO/flutil/ldpmqmd

# make installation available for the linux group fluka
chmod -R a+r .
find . -type f -executable -exec chmod a+x {} \;
cd ../../../
chown -R root:fluka FLUKA

# clean away package files
cd -
! ${lClean} || rm fluka${FLUKAver}*tar.gz

# ls
ls -ltrh --color=auto flutil
ls -ltrh --color=auto
