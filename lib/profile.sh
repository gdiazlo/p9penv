#!/usr/bin/env bash

umask 077
# session
export XDG_DATA_DIRS=/home/gdiazlo/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:/home/gdiazlo/.local/share/flatpak/exports/share

# set plan9 environment
export PLAN9=$HOME/.local/plan9
export P9PENV=$HOME/.local/p9penv

# mk max concurrent procs
# only valid for linux
export nproc=16

# set golang environment
export GOVERSION=$($PLAN9/bin/ls -p $HOME/.local/go | tail -n 1)
export GOROOT=$HOME/.local/go/$GOVERSION
export GOPATH=$HOME/go
export GO111MODULE=on

# set java environmant
export _JAVA_OPTIONS='-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dawt.useSystemAAFontSettings=on'
export JAVA_VERSION=11.0.8
export JAVA_HOME=$HOME/.local/java/jdk/$JAVA_VERSION

# set scala environment
export SBT_VERSION=1.4.4
export SBT_HOME=$HOME/.local/java/sbt/$SBT_VERSION

# set Maven Home
export MVN_VERSION=3.6.3
export MVN_HOME=$HOME/.local/java/mvn/$MVN_VERSION/

# set rust environment
CARGO=$HOME/.cargo

# ocaml opam environment
test -r $HOME/.opam/opam-init/init.sh && . $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# set acme environment
export usebigarrow=1
export EDITOR=editinacme
export PAGER=nobs
export BROWSER=firefox
unset FCEDIT VISUAL

# set cursor to a steady bar |
# printf '\033[6 q'
# set cursor to a steady block
echo -e -n "\x1b[\x30 q"
export GNUTERM="sixelgd size 1280,720 truecolor font 'DEC Terminal Modern' 14"

# set aliases
alias tb="nc termbin.com 9999"

# check if something is not there
dirs=("$HOME/lib" "$HOME/mail" "$PLAN9" "$GOROOT" "$GOPATH" "$P9PENV")
for d in $dirs; do
	if [ ! -d ${d} ]; then
		echo "$d does not exists. Verify set up"
	fi
done

files=("$HOME/lib/plumbing")
for f in $files; do
	if [ ! -f ${f} ]; then
		echo "$f does not exists. Verify set up"
	fi
done

# Prepare PATH environment
#   append custom tools at the end of the current path
#   prepend ~/bin and goroot into path to avoid using gcc-go in system path by default
pathappend="$P9PENV/bin:$P9PENV/mail:$GOPATH/bin:$PLAN9/bin:$PLAN9/bin/upas:$JAVA_HOME/bin:$SBT_HOME/bin:$MVN_HOME/bin:/usr/sbin:/sbin"
pathprepend="$HOME/bin:$HOME/.local/bin:$GOROOT/bin:$CARGO/bin"
export PATH=$pathprepend:$PATH:$pathappend

# ssh agent set up

SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

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
# complete -f nospace _cd cda

_set_font() {
	family="$1"
	shift
	size="$1"
	shift
	hidpi="$1"
	shift

	if [[ $size =~ ^[0-9]+$ ]]; then
		acme_font_size=$size
	fi

	if [[ $hidpi =~ ^[0-9]+$ ]]; then
		acme_font_size_hidpi=$hidpi
	fi

	if [ -z "$family" ]; then
		family="plan9"
	fi

	case $family in
	dejavu)
		mono="DejaVuSansMono"
		sans="DejaVuSans"
		;;
	go)
		mono="Go Mono"
		sans="Go Regular"
		;;
	cmu)
		mono="CMU Typewriter Text Variable Width"
		sans="CMU Concrete Roman"
		;;
	ibm)
		mono="IBMPlexMono"
		sans="IBMPlexSans"
		;;
	fira)
		mono="FiraMono-Regular"
		sans="FiraSans-Regular"
		;;
	terminus)
		mono="TerminusTTF"
		sans="TerminusTTF"
		;;
	book)
		mono="GoMono"
		sans="Bitter-Regular"
		;;
	input-condensed)
		mono="InputMonoCondensed-Regular"
		sans="InputSansCondensed-Regular"
		;;
	input)
		mono="InputMono-Regular"
		sans="InputSans-Regular"
		;;
	noto)
		mono="NotoSansMono-Regular"
		sans="NotoSans-Regular"
		;;
	adobe)
		mono="SourceCodePro-Regular"
		sans="SourceSansPro-Regular"
		;;
	*)
		mono='FiraMono-Regulat'
		sans='FiraSans-Regular'
		return
		;;
	esac

	export fixedfont="/mnt/font/${mono}/${acme_font_size}a/font"
	export font="/mnt/font/${sans}/${acme_font_size}a/font"
	export hidpifixedfont="/mnt/font/${mono}/${acme_font_size_hidpi}a/font"
	export hidpifont="/mnt/font/${sans}/${acme_font_size_hidpi}a/font"
}

# start new p9p session
# start factotum before secstore so it does not prompt for a password
# load secrets manually using ipso
p9p_session() {
	xdg=/run/user/$(id -u)
	NAMESPACE=$xdg/ns
	mountpoint -q $xdg || NAMESPACE=`namespace`;

	mkdir -p $NAMESPACE
	export NAMESPACE

	for proc in fontsrv factotum secstored plumber; do
		pgrep $proc 2>&1 > /dev/null
		if [ $? -ne 0 ]; then
			$proc &
		fi
	done
}

# default font
_set_font ibm 13 26

# always set up the p9p session,
# this will start services only if there are not started yet
p9p_session

_acme() {
	SHELL=rc  $PLAN9/bin/acme -a -c 1 -f "$font,$hidpifont" -F "$fixedfont,$hidpifixedfont" "$@"
}
