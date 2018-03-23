#!/bin/bash

#  set plan9 environment
export PLAN9=/usr/local/plan9

# set golang environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# set acme environment
export ACME=$HOME/acme
export usebigarrow=1
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
	cd $(mktemp -d)
	git clone https://go.googlesource.com/image
	mkdir -p ~/.fonts
	cp image/font/gofont/ttfs/* ~/.fonts
	fc-cache -f -v
}

install_cmu_fonts() {
	cd $(mktemp -d)
	wget https://kent.dl.sourceforge.net/project/cm-unicode/cm-unicode/0.7.0/cm-unicode-0.7.0-ttf.tar.xz
	tar xvfJ cm-unicode-0.7.0-ttf.tar.xz
	cp cm-unicode-0.7.0/*.ttf ~/.fonts
	fc-cache -f -v
}

install_fonts_osx() {
	cp ~/.fonts/* ~/Library/Fonts/
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

_set_font() {
	mono=$1
	sans=$2

	case "$(uname -s)" in
	Darwin)
		export devdrawretina=1
		mono=$(echo $mono | 9 sed 's/ //g')
		sans=$(echo $sans | 9 sed 's/ //g')
	;;

	esac
}


_acme() {
	_set_font "Go Mono" "Go Regular"
	_set_font "CMU Typewriter-Regular" "CMU Typewriter Variable"
	export font="/mnt/font/${sans}/${acme_font_size}a/font"
	export fixedfont="/mnt/font/${mono}/${acme_font_size}a/font"
	SHELL=bash  9 acme -a -c 1 -f "$font" -F "$fixedfont" "$@" 2>&1 >/dev/null
}

alias acme=_acme
alias acme2="_acme -l $HOME/acme/layout/2cols.dump"
alias acme3="_acme -l $HOME/acme/layout/3cols.dump"

complete -f nospace _cd acme

