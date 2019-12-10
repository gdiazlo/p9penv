#!/bin/bash

#suckless dekstop set up
SLD=$HOME/.sld
mkdir -p $SLD/bin
mkdir -p $SLD/src
cd $SLD/src

if [ ! -d st ]; then
# st
git clone https://git.suckless.org/st
cd st
# git checkout 0.8.2
git branch config
git checkout config
wget http://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff
wget http://st.suckless.org/patches/scrollback/st-scrollback-20190331-21367a0.diff
wget http://st.suckless.org/patches/scrollback/st-scrollback-mouse-20191024-a2c479c.diff
patch < st-xresources-20190105-3be4cf1.diff
patch < st-scrollback-20190331-21367a0.diff
patch < st-scrollback-mouse-20191024-a2c479c.diff
 make
 cp st  $SLD/bin
 cd $SLD/src
fi

if [ ! -d dwm ]; then
git clone https://git.suckless.org/dwm
cd dwm
git checkout 6.2
git branch config
git checkout config
wget http://dwm.suckless.org/patches/xrdb/dwm-xrdb-6.2.diff
wget http://dwm.suckless.org/patches/fakefullscreen/dwm-fakefullscreen-20170508-ceac8c9.diff
wget http://dwm.suckless.org/patches/fancybar/dwm-fancybar-2019018-b69c870.diff
patch < dwm-xrdb-6.2.diff
patch < dwm-fakefullscreen-20170508-ceac8c9.diff
patch < dwm-fancybar-2019018-b69c870.diff
make
cp dwm $SLD/bin
cd $SLD/src
fi

if [ ! -d dmenu ]; then
git clone https://git.suckless.org/dmenu
cd dmenu
git checkout 4.9
git branch config
git checkout config
wget https://tools.suckless.org/dmenu/patches/mouse-support/dmenu-mousesupport-4.7.diff
wget https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-4.9.diff
patch < dmenu-mousesupport-4.7.diff
patch < dmenu-fuzzymatch-4.9.diff
sed -i 's/monospace:size=10/Source Code Pro:size 12/g' config.def.h
make
cp dmenu dmenu_run dmenu_path stest $SLD/bin
cd $SLD/src
fi

if [ ! -d slstatus ]; then
git clone https://git.suckless.org/slstatus
cd slstatus
make
cp slstatus $SLD/bin
cd $SLD/src
fi

if [ ! -d slock ]; then
git clone https://git.suckless.org/slock
cd slock

git branch config
git checkout config
wget https://tools.suckless.org/slock/patches/dpms/slock-dpms-1.4.diff

patch < slock-dpms-1.4.diff

make
cp slock $SLD/bin
cd $SLD/src
fi
