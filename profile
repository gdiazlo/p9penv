#!/bin/bash

# QT auto scale
export QT_AUTO_SCREEN_SCALE_FACTOR=true

# set plan9 environment
export PLAN9=~/.plan9

# set golang environment
export GOVERSION=$($PLAN9/bin/ls -p ~/.go | tail -n 1)
export GOROOT=~/.go/$GOVERSION
export GOPATH=$HOME/go
export GO111MODULE=on
export CGO_LDFLAGS_ALLOW='-Wl,-unresolved_symbols=ignore-all'

# set java environmant
export JAVA_VERSION=13.0.1
export JAVA_HOME=~/.java/$JAVA_VERSION

# set scala environment
export SBT_VERSION=1.3.3
export SBT_HOME=~/.sbt/$SBT_VERSION

# set acme environment
export ACME=$HOME/.acme
export usebigarrow=1
export EDITOR=editinacme
export PAGER=nobs
export BROWSER=firefox
unset FCEDIT VISUAL

# set cursor to a steady bar |
# printf '\033[6 q'

# set aliases
alias ls="9 lc -F"
alias tb="nc termbin.com 9999"

# set java environment
export JAVA_HOME=~/.java/jdk/11.0.2/
export SBT_HOME=~/.java/sbt/1.3.3/
export MVN_HOME=~/.java/mvn/3.6.2/

# check if something is not there
dirs=("$HOME/lib" "$PLAN9" "$GOROOT" "$GOPATH" "$ACME")
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

pathappend() {
  for ARG in "$@"
  do
    if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
        PATH="${PATH:+"$PATH:"}$ARG"
    fi
  done
}

pathappend "$HOME/bin" "$GOPATH/bin" "$PLAN9/bin" "$JAVA_HOME/bin" "$SBT_HOME/bin" "$MVN_HOME/bin"

# prepend ~/bin and goroot into path to avoid using gcc-go in system path by default
export PATH="~/bin:$GOROOT/bin":$PATH

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
complete -f nospace _cd cda

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
		sans="IBMPlexSerif-Medium"
		;;
	fira)
		mono="FiraMono-Medium"
		sans="FiraSans-Medium"
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
		mono="InputMonoCondensed-Medium"
		sans="InputSansCondensed-Medium"
		;;
	input)
		mono="InputMono-Light"
		sans="InputSans-Light"
		;;
	noto)
		mono="NotoSansMono-Regular"
		sans="NotoSans-Regular"
		;;
	adobe)
		mono="SourceCodePro-Medium"
		sans="SourceSansPro-Regular"
		;;
	plan9)
		export fixedfont="/usr/local/plan9/font/pelm/unicode.9.font"
		export font="/lib/font/bit/lucsans/euro.8.font"
		return
		;;
	esac

	export fixedfont="/mnt/font/${mono}/${acme_font_size}a/font"
	export font="/mnt/font/${sans}/${acme_font_size}a/font"
	export hidpifixedfont="/mnt/font/${mono}/${acme_font_size_hidpi}a/font"
	export hidpifont="/mnt/font/${sans}/${acme_font_size_hidpi}a/font"
}

_acme() {
	SHELL=bash  $PLAN9/bin/acme -a -c 1 -f "$font,$hidpifont" -F "$fixedfont,$hidpifixedfont" "$@"
}

complete -f nospace _cd acme

# start new p9p session
new_p9p_session() {
	for proc in fontsrv factotum plumber; do
		pgrep $proc 2>&1 > /dev/null
		if [ $? -ne 0 ]; then
			$PLAN9/bin/9 $proc &
		fi
	done
}

if [ ! -z "$DISPLAY" ]; then
	new_p9p_session
fi

# default font
_set_font terminus 14 22

# source
source ~/.acme/bin/git-prompt.sh
export PS1='$(__git_ps1 "(%s)")>'
