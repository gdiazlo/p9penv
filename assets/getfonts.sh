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


install() {
	name=$1
	shift	
	fonts="$@"
	for f in $fonts; do 
		wget $f
	done
	for i in $(ls -1 *.zip); do
		unzip $i
	done
	mkdir -p $DEST/$name
	find ./ -type f \( -iname \*.ttf -o -iname \*.otf \) -exec cp {} $DEST/$name \;
	find ./ -type f \( -iname \*.TTF -o -iname \*.OTF \) -exec cp {} $DEST/$name \;
}

# install ibm plex fonts

ibm() {
	git clone https://github.com/IBM/plex
	mkdir -p $DEST/ibm
	find ./ -type f \( -iname \*.otf \) -exec cp {} $DEST/$name \;
}

# install go font
go() {
	git clone https://go.googlesource.com/image
	mkdir -p $DEST/go
	cp image/font/gofont/ttfs/* $DEST/go
}

# install terminus font
terminus() {
	wget https://files.ax86.net/terminus-ttf/files/latest.zip
	unzip latest.zip
	cd terminus-ttf-4.46.0
	mkdir -p $DEST/terminus
	cp *.ttf $DEST/terminus
}

# install cmu fonts
computer_modern() {
	wget http://mirrors.ctan.org/fonts/cm-unicode.zip
	unzip cm-unicode.zip
	mkdir -p $DEST/computer-modern
	find ./ -type f \( -iname \*.ttf -o -iname \*.otf \) -exec cp {} $DEST/$name \;
	find ./ -type f \( -iname \*.TTF -o -iname \*.OTF \) -exec cp {} $DEST/$name \;
}

bitter() {
	wget -O bitter.zip https://www.huertatipografica.com/free_download/48
	unzip bitter.zip
	mkdir -p $DEST/bitter
	cp *.otf $DEST/bitter
}

FONTS=(lucida syntax go terminus computer_modern bitter ibm)


for font in ${FONTS[@]}; do
	tmp=$(mktemp -d)
	cd $tmp
	echo Installing $font
	$font
	cd
	echo Remove $tmp
done

fc-cache -f -v
