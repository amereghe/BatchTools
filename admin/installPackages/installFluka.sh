#!/usr/bin/bash

# run as root!

# set env vars
credFileName="myCredentials.sh" # contains myUserID and myUserPass vars (necessary only for download)
FLUKAverLong=2025.1.4
FLUKAver=`echo ${FLUKAverLong} | cut -d\. -f1,2`
GFORver=""
GLIBCver=""
# check your version against those available on the FLUKA website!
#   choose the version on the web <= to yours
# UBUNTU_24.04
GFORver="${GFORver} 12.2"  # gfortran --version
GLIBCver="${GLIBCver} 2.37" # ldd --version
# UBUNTU_26.04
GFORver="${GFORver} 15.2"  # gfortran --version
GLIBCver="${GLIBCver} 2.42" # ldd --version
iInstall=1
lDownloadOnly=true
lDownload=true
lCopy=false
lSCopy=false
lClean=false
FLUKApath=FLUKA/INFN
#
GFORver=( ${GFORver} )
GLIBCver=( ${GLIBCver} )

die() {
  echo >&2 "$1"
  exit $E_BADARGS
}

# in case of downloading FLUKA, make sure you load the correct credentials
if ${lDownload} ; then
    [ ! -f ./${credFileName} ] || source ./${credFileName}
    [ ! -f `dirname $0`/${credFileName} ] || source `dirname $0`/${credFileName}
    [[ -n "${myUserID}" ]] || die "myUserID var NOT defined!"
    [[ -n "${myUserPass}" ]] || die "myUserPass var NOT defined!"
fi

# go to suitable folder
if ! ${lDownloadOnly} ; then
    cd /usr/local
    mkdir -p ${FLUKApath}/${FLUKAverLong}
    cd ${FLUKApath}/${FLUKAverLong}
fi

# download stuff
if ${lDownload} ; then
    for ((ii=0;ii<${#GFORver[@]};ii++)) ; do
	wget --user ${myUserID} --password ${myUserPass} --no-check-certificate https://www.fluka.eu/Fluka/www/htmls/packages/fluka${FLUKAver}-linux-gfor64bit-${GFORver[$ii]}-glibc${GLIBCver[$ii]}-AA.tar.gz
    done
    wget --user ${myUserID} --password ${myUserPass} --no-check-certificate https://www.fluka.eu/Fluka/www/htmls/packages/fluka${FLUKAver}-data.tar.gz
elif ${lCopy} ; then
    echo "copying files..."
    cp /mnt/san_data/soft/FLUKA/INFN/${FLUKAverLong}/fluka${FLUKAver}-linux-gfor64bit-${GFORver}-glibc${GLIBCver}-AA.tar.gz .
    cp /mnt/san_data/soft/FLUKA/INFN/${FLUKAverLong}/fluka${FLUKAver}-data.tar.gz .
elif ${lSCopy} ; then
    scp amereghe@svpvclus01.cnao.group:/mnt/san_data/soft/FLUKA/INFN/${FLUKAverLong}/fluka${FLUKAver}-linux-gfor64bit-${GFORver}-glibc${GLIBCver}-AA.tar.gz .
    scp amereghe@svpvclus01.cnao.group:/mnt/san_data/soft/FLUKA/INFN/${FLUKAverLong}/fluka${FLUKAver}-data.tar.gz .
fi
if ${lDownloadOnly} ; then
    exit
fi

# create appropriate folder with downloaded material
tar xvzf fluka${FLUKAver}-linux-gfor64bit-${GFORver[${iInstall}]}-glibc${GLIBCver[$iInstall]}-AA.tar.gz
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
find . -type d -exec chmod g+x {} \;
cd ../../../
chown -R root:fluka FLUKA

# clean away package files
cd -
! ${lClean} || rm fluka${FLUKAver}*tar.gz

# ls
ls -ltrh --color=auto flutil
ls -ltrh --color=auto
