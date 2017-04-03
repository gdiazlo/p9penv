#!/bin/bash

cd /tmp
git clone https://go.googlesource.com/image
mkdir -p ~/.fonts
cp image/font/gofont/ttfs/* ~/.fonts
fc-cache -f -v

