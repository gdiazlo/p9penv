#!/bin/bash

#suckless dekstop set up
SLD=$HOME/.sld
mkdir -p $SLD/bin
mkdir -p $SLD/src
cd $SLD/src

# st
git clone https://git.suckless.org/st
cd st
git branch config
git checkout config
wget http://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff
wget http://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff
wget http://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.2.diff
wget http://st.suckless.org/patches/scrollback/st-scrollback-20190331-21367a0.diff
wget http://st.suckless.org/patches/scrollback/st-scrollback-mouse-20191024-a2c479c.diff
# wget http://st.suckless.org/patches/externalpipe/st-externalpipe-0.8.2.diff
# patch < st-externalpipe-0.8.2.diff
patch < st-xresources-20190105-3be4cf1.diff
patch < st-scrollback-20190331-21367a0.diff
patch < st-scrollback-mouse-20191024-a2c479c.diff
patch < st-bold-is-not-bright-20190127-3be4cf1.diff
patch < st-boxdraw_v2-0.8.2.diff
make
cp st  $SLD/bin

cd $SLD/src
git clone https://git.suckless.org/dwm
cd dwm
git branch config
git checkout config
wget http://dwm.suckless.org/patches/xrdb/dwm-xrdb-6.2.diff
wget http://dwm.suckless.org/patches/fakefullscreen/dwm-fakefullscreen-20170508-ceac8c9.diff
wget http://dwm.suckless.org/patches/fancybar/dwm-fancybar-2019018-b69c870.diff
wget http://dwm.suckless.org/patches/dmenumatchtop/dwm-dmenumatchtop-6.2.diff
# wget http://dwm.suckless.org/patches/systray/dwm-systray-20190208-cb3f58a.diff
patch < dwm-xrdb-6.2.diff
# patch < dwm-systray-20190208-cb3f58a.diff
patch < dwm-fakefullscreen-20170508-ceac8c9.diff
patch < dwm-fancybar-2019018-b69c870.diff
patch < dwm-dmenumatchtop-6.2.diff
make
cp dwm $SLD/bin

cd $SLD/src
git clone https://git.suckless.org/dmenu
cd dmenu
make
cp dmenu $SLD/bin
