#!/bin/bash

# set plan9 environment
export PLAN9=/usr/local/plan9

# set golang environment
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# set acme environment
export ACME=$HOME/acme
export usebigarrow=1
export EDITOR=editinacme
export BROWSER=chrome

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

pathappend "$HOME/bin" "$ACME/bin" "$GOROOT/bin" "$GOPATH/bin" "$PLAN9/bin"

new_imap_session() {
	echo -n "server name: "
	read server
	echo
	echo -n "user name: "
	read user
	echo
	echo -n "password: "
	read -s password
	echo
	9 factotum -g "proto=pass service=imap server=$server user=$user !password=$password"
	9 mailfs -t $server
}

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

# install go font
install_go_fonts() {
	cd $(mktemp -d)
	git clone https://go.googlesource.com/image
	mkdir -p ~/.fonts
	cp image/font/gofont/ttfs/* ~/.fonts
	fc-cache -f -v
}

# install terminus font
install_terminus_fonts() {
	cd $(mktemp -d)
	wget https://files.ax86.net/terminus-ttf/files/latest.zip
	unzip latest.zip
	cd terminus-ttf-4.46.0
	cp *.ttf ~/.fonts
	fc-cache -f -v
}

# install cmu fonts
install_cmu_fonts() {
	cd $(mktemp -d)
	wget https://kent.dl.sourceforge.net/project/cm-unicode/cm-unicode/0.7.0/cm-unicode-0.7.0-ttf.tar.xz
	tar xvfJ cm-unicode-0.7.0-ttf.tar.xz
	cp cm-unicode-0.7.0/*.ttf ~/.fonts
	fc-cache -f -v
}

# install fonts in OSX
install_fonts_osx() {
	cp ~/.fonts/* ~/Library/Fonts/
}

_set_font() {
	family="$1"
	shift
	size="$1"
	shift

	if [[ $size =~ ^[0-9]+$ ]]; then
		acme_font_size=$size
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
	terminus)
		mono="Terminus (TTF)"
		sans="Terminus (TTF)"
		if [ $size -lt 14 ]; then
			size=14
		fi
		;;
	plan9)
		export fixedfont="$PLAN9/font/fixed/unicode.8x13.font"
		export font="$PLAN9/font/lucsans/unicode.8.font"
		return
		;;
	esac

	export fixedfont="/mnt/font/${mono}/${acme_font_size}a/font"
	export font="/mnt/font/${sans}/${acme_font_size}a/font"
}

alias set_font=_set_font


_acme() {
	SHELL=bash  $PLAN9/bin/acme -a -c 1 -f "$font" -F "$fixedfont" "$@" 2>&1 >/dev/null &
}

alias acme=_acme
alias acme2="_acme -l $HOME/acme/layout/2cols.dump"
alias acme3="_acme -l $HOME/acme/layout/3cols.dump"

complete -f nospace _cd acme

# start new p9p session
new_p9p_session() {
	for proc in factotum plumber fontsrv devdraw mailfs; do
		pkill $proc
	done
	$PLAN9/bin/9 plumber &
	$PLAN9/bin/9 fontsrv &
        $PLAN9/bin/9 factotum -n &
	# if you use factotum for ssh or other keys	
        # 9 aescbc -d < $HOME/lib/secstore.aes | 9p write -l factotum/ctl
        # eval `9 ssh-agent -e`
	set_font terminus 14
}

setcolor() {
	declare -A colors
	colors[black]="#313131"
	colors[gray]="#777777"
	colors[purple]="#bfb1d5"
	colors[green]="#adddcf"
	colors[blue]="#abe1fd"
	colors[orange]="#fed1be"
	colors[yellow]="#f0e0a2"
	colors[lightgray]="#e8e7e5"
	colors[white]="#fafafa"

        echo -ne "\033]11;${colors[$1]}\007"
        echo -ne "\033]10;${colors[$2]}\007"
}

