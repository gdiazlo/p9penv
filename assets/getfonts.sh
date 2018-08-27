 #!/bin/bash
 
 DEST=~/.fonts
 
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
	wget https://kent.dl.sourceforge.net/project/cm-unicode/cm-unicode/0.7.0/cm-unicode-0.7.0-ttf.tar.xz
	tar xvfJ cm-unicode-0.7.0-ttf.tar.xz
	mkdir -p $DEST/computer-modern
	cp cm-unicode-0.7.0/*.ttf $DEST/computer-modern
}

bitter() {
	wget -O bitter.zip https://www.huertatipografica.com/free_download/48
	unzip bitter.zip
	mkdir -p $DE$ST/bitter
	cp *.otf $DEST/bitter
}

FONTS=(go terminus computer_modern bitter)

for font in ${FONTS[@]}; do
	tmp=$(mktemp -d)
	cd $tmp
	echo Installing $font
	$font
	cd
	rm -rf $tmp
done

fc-cache -f -v
