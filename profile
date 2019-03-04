#!/bin/bash

# set plan9 environment
export PLAN9=/usr/local/plan9

# set golang environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on

# set acme environment
export ACME=$HOME/acme
export usebigarrow=1
export EDITOR=editinacme
export BROWSER=firefox
if [ -f /usr/bin/google-chrome-stable ]; then
	export BROWSER=/usr/bin/google-chrome-stable
fi

# set java environment
export JAVA_HOME=/usr/lib64/java

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

pathappend "$HOME/bin" "$GOROOT/bin" "$GOPATH/bin" "$PLAN9/bin" "$JAVA_HOME/bin" "$HOME/VSCode-linux-x64/bin/"

# prepend acme and goroot into path to avoid using gcc-go in system path by default
export PATH="$ACME/bin:$GOROOT/bin":$PATH

alias tb="nc termbin.com 9999"



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
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
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
		sans="IBMPlexSansCond"
		;;
	fira)
		mono="FiraMono-Regular"
		sans="FiraSans-Regular"
		;;
	lucida)
		mono="LucidaConsole"
		sans="LucidaSansUnicode"
		;;
	syntax)
		mono="SyntaxLTStd-Roman"
		sans="SyntaxLTStd-Roman"
		;;
	terminus)
		mono="Terminus (TTF)"
		sans="Terminus (TTF)"
		;;
	book)
		mono="GoMono"
		sans="Bitter-Regular"
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

