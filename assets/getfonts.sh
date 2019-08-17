 #!/bin/bash
 
DEST=~/.fonts

syntax() {
	fonts=("https://www.wfonts.com/download/data/2016/07/06/syntax-lt-std/syntax-lt-std.zip")
	install "syntax" "${fonts[@]}"
}

lucida() {
	fonts=("https://www.wfonts.com/download/data/2014/11/24/lucida-sans-unicode/lucida-sans-unicode.zip" "https://www.wfonts.com/download/data/2016/07/08/lucida-sans/lucida-sans.zip" "https://www.wfonts.com/download/data/2014/12/30/lucida-sans-typewriter/lucida-sans-typewriter.zip" "https://www.wfonts.com/download/data/2015/10/29/lucida-grande/lucida-grande.zip" "https://www.wfonts.com/download/data/2014/12/30/lucida-calligraphy/lucida-calligraphy.zip" "https://www.wfonts.com/download/data/2014/12/30/lucida-fax/lucida-fax.zip" "https://www.wfonts.com/download/data/2016/05/14/lucida-bright/lucida-bright.zip" "https://www.ffonts.net/Lucida-Console.font.zip")
	install "lucida" "${fonts[@]}"
}

letter() {
	fonts=("https://www.wfonts.com/download/data/2016/07/10/letter-gothic-std/letter-gothic-std.zip")
	install "letter" "${fonts[@]}"
}

input() {
	fonts=("http://input.fontbureau.com/build/?fontSelection=whole&a=0&g=ss&i=0&l=0&zero=0&asterisk=0&braces=0&preset=default&line-height=1.4&accept=I+do&email=")
	install "input" "${fonts[@]}"
}

terminus() {
	fonts=("https://files.ax86.net/terminus-ttf/files/latest.zip")
	install "terminus" "${fonts[@]}"
}

computer_modern() {
	fonts=("http://mirrors.ctan.org/fonts/cm-unicode.zip")
	install "computer_modern" "${fonts[@]}"
}

ibm() {
	fonts=("https://github.com/IBM/plex/releases/download/v2.0.0/TrueType.zip")
	install "ibmplex" "${fonts[@]}"
}

bitter() {
	fonts=("https://www.huertatipografica.com/free_download/48")
	install "bitter" "${fonts[@]}"
}

# install go font
go() {
	fonts=("https://go.googlesource.com/image/+archive/master/font/gofont/ttfs.tar.gz")
	wget -O gofont.tar.gz ${fonts[0]}
	copy "go"
}

noto() {
	fonts=("https://noto-website-2.storage.googleapis.com/pkgs/Noto-hinted.zip")
	install "noto" "${fonts[@]}"
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
		wget -O $i.zip ${fonts[$i]}
		unzip -o $i.zip
		copy "$name"
		rm $i.zip
	done
}


ALL=(input letter lucida syntax go terminus computer_modern bitter ibm noto)

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

