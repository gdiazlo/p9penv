 #!/bin/bash

GOVERSION=1.14.2

if [ ! -d ~/.go/$GOVERSION ]; then
	echo Installing Go $GOVERSION
	mkdir -p ~/.go/$GOVERSION
	wget -c "https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz" -O - | tar -zx -C ~/.go/${GOVERSION}/ --strip-components=1
fi

GOROOT=~/.go/$GOVERSION
PATH=~/.go/$GOVERSION/bin:$PATH

# Download and update golang tools

# Download go lang tools and helpers
go get -u golang.org/x/tools/...

# 3rd party

go get -u github.com/9fans/go/acme/editinacme
go get -u github.com/9fans/go/acme/acmego
go get -u github.com/9fans/go/acme/Watch
go get -u github.com/mpl/xplor

# other tools

go get -u rsc.io/mailgun/cmd/mailgun-mail
go get -u rsc.io/mailgun/cmd/mailgun-sendmail
go get -u github.com/marguerite/linux-bing-wallpaper

# lang server
go get -u golang.org/x/tools/cmd/gopls
go get -u github.com/fhs/acme-lsp/cmd/acme-lsp
go get -u github.com/fhs/acme-lsp/cmd/L
go get -u github.com/fhs/acme-lsp/cmd/acmefocused

