 #!/bin/bash

DEST=~/.fonts

# Opensource font sponsored by Red Hat
# http://overpassfont.org/
overpass() {
	fonts=("https://github.com/RedHatBrand/Overpass/releases/download/3.0.2/overpass-desktop-fonts.zip")
	install "overpass" "${fonts[@]}"
}

# Opensource font sponsored by Adobe
# https://github.com/adobe-fonts/
adobe() {
	fonts=("https://github.com/adobe-fonts/source-serif-pro/releases/download/3.001R/source-serif-pro-3.001R.zip" "https://github.com/adobe-fonts/source-sans-pro/releases/download/3.006R/source-sans-pro-3.006R.zip" "https://github.com/adobe-fonts/source-code-pro/releases/download/2.030R-ro%2F1.050R-it/source-code-pro-2.030R-ro-1.050R-it.zip")
	install "adobe" "${fonts[@]}"
}

# Opensource font Copper Hewwit by Chester Jenkins
# https://www.cooperhewitt.org/open-source-at-cooper-hewitt/cooper-hewitt-the-typeface-by-chester-jenkins/
copper() {
	fonts=("https://uh8yh30l48rpize52xh0q1o6i-wpengine.netdna-ssl.com/wp-content/uploads/fonts/CooperHewitt-OTF-public.zip")
	install "copper" "${fonts[@]}"
}

# Opensource font by David Johnatan Ross
# https://input.fontbureau.com/
input() {
	fonts=("http://input.fontbureau.com/build/?fontSelection=whole&a=0&g=ss&i=0&l=0&zero=0&asterisk=0&braces=0&preset=default&line-height=1.4&accept=I+do&email=")
	install "input" "${fonts[@]}"
}

# Opensource font by
# https://practicaltypography.com/fonts/charter.zip
charter() {
	fonts=("https://practicaltypography.com/fonts/charter.zip")
	install "charter" "${fonts[@]}"
}

# Open fonts by SIL
# https://software.sil.org/fonts/

# Opensource font by
# http://terminus-font.sourceforge.net/
terminus() {
	fonts=("https://files.ax86.net/terminus-ttf/files/latest.zip")
	install "terminus" "${fonts[@]}"
}

# Open fonts by D. Knuth ported to TTF
# http://mirrors.ctab,org/fonts
computer_modern() {
	fonts=("http://mirrors.ctan.org/fonts/cm-unicode.zip")
	install "computer_modern" "${fonts[@]}"
}

# Open source fonts by IBM
# https://github.com/IBM/plex
ibm() {
	fonts=("https://github.com/IBM/plex/releases/download/v2.0.0/TrueType.zip")
	install "ibmplex" "${fonts[@]}"
}

# Free font by Huerta Tipografica
# https://www.huertatipografica.com
bitter() {
	fonts=("https://www.huertatipografica.com/free_download/48")
	install "bitter" "${fonts[@]}"
}

# Opensource font by Mozilla
# https://github.com/mozilla/fira
fira() {
	fonts=("https://github.com/mozilla/Fira/archive/4.202.zip")
	install "fira" "${fonts[@]}"
}
# Free Font derived form Lucida to be included with Go programming language
# https://blog.golang.org/go-fonts
go() {
	fonts=("https://go.googlesource.com/image/+archive/master/font/gofont/ttfs.tar.gz")
	wget -O gofont.tar.gz ${fonts[0]}
	copy "go"
}

# Open source fonts from Google
noto() {
	fonts=("https://noto-website-2.storage.googleapis.com/pkgs/Noto-hinted.zip")
	install "noto" "${fonts[@]}"
}

lora() {
	fonts=("https://www.fontsquirrel.com/fonts/download/lora")
	install "lora" "${fonts[@]}"
}

orbitron() {
	fonts=("https://github.com/theleagueof/orbitron/archive/master.zip")
	install "orbitron" "${fonts[@]}"
}

montserrat() {
	fonts=("https://github.com/JulietaUla/Montserrat/archive/v7.200.zip")
	install "monserrat" "${fonts[@]}"
}

copy() {
	name=$1
	shift
	mkdir -p $DEST/$name
        find ./ -type f \( -iname \*.ttf -o -iname \*.otf \) -exec cp {} $DEST/$name \;
        find ./ -type f \( -iname \*.TTF -o -iname \*.OTF \) -exec cp {} $DEST/$name \;
}

install() {
	name=$1
	shift
	fonts="$@"
	for i in "${!fonts[@]}"; do
		echo Downloading ${fonts[$i]} into $i.zip
		wget -O $i.zip ${fonts[$i]}
		echo Uncompressing $i.zip
		unzip -o $i.zip
		echo Copying into $name
		copy "$name"
		echo Remove $i.zip
		rm $i.zip
	done
}

ALL=(overpass adobe copper input charter terminus computer_modern ibm bitter fira go noto lora orbitron montserrat)

if [ -z "$1" ]; then
	echo Select all or one of the following fonts:
	echo ${ALL[@]}
	exit
fi

FONTS=( "$@" )

for font in ${FONTS[@]}; do
	tmp=$(mktemp -d)
	cd $tmp
	echo Installing $font
	$font
	cd
	echo Remove $tmp
done

fc-cache -f

