#!/bin/bash

#  set plan9 environment
export PLAN9=/usr/local/plan9

# set golang environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# set acme environment
export ACME=$HOME/acme

export PATH=$PATH:$HOME/bin:$ACME/bin:$PLAN9/bin:$GOROOT/bin:$GOPATH/bin

# set cd to execute awd when in acme win
cda () {
        builtin cd "$@" &&
        case "$TERM!$-" in
        linux!*)
                ;;
        *!*i*)
                awd
        esac
}
alias cd=cda
complete -f nospace _cd cda

# set up plan9 environtment tools

# get plan9port namespace
ns=$(namespace)

if [ ! -S "${ns}/plumb" ]; then
	9 plumber &
fi

if [ ! -S "${ns}/font" ]; then
	9 fontsrv &
fi


# set acme fonts and size

# install go fonts in linux only
install_go_fonts() {
	cd /tmp
	git clone https://go.googlesource.com/image
	mkdir -p ~/.fonts
	cp image/font/gofont/ttfs/* ~/.fonts
	fc-cache -f -v
}

export acme_font_size=12

_sfont() {
	if [[ $1 =~ ^[0-9]+$ ]]; then
		export acme_font_size=$1
	else
		echo Usage sfont size
	fi
}

alias sfont=_sfont

mono=""
sans=""

case "$(uname -s)" in
   Darwin)
	mono="GoMono"
	sans="GoRegular"
     ;;

   Linux)
	mono="Go Mono"
	sans="Go Regular"
     ;;
esac

_acme() {
	export font="/mnt/font/${sans}/${acme_font_size}a/font"
	export fixedfont="/mnt/font/${mono}/${acme_font_size}a/font"
	SHELL=bash  9 acme -a -c 1 -f "$font" -F "$fixedfont" "$@"
}

alias acme=_acme
complete -f nospace _cd acme

