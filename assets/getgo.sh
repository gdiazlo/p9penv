 #!/bin/bash
OS=linux
if [[ $OSTYPE == "darwin"* ]]; then
	OS=darwin
fi

GOVERSION=1.15.2
GOROOT=$HOME/.local/go/$GOVERSION
if [ ! -d $GOROOT ]; then
	echo Installing Go $GOVERSION
	mkdir -p $GOROOT
	curl -L "https://dl.google.com/go/go${GOVERSION}.$OS-amd64.tar.gz" | tar -zx -C $GOROOT --strip-components=1
fi


PATH=$GOROOT/bin:$PATH

# Download and update golang tools

# Download go lang tools and helpers
go get -u golang.org/x/tools/...

# 3rd party
go get -u 9fans.net/go/acme/editinacme
go get -u 9fans.net/go/acme/Watch
go get -u 9fans.net/go/acme/Dict
go get -u github.com/mpl/xplor

# other tools
go get -u rsc.io/mailgun/cmd/mailgun-mail
go get -u rsc.io/mailgun/cmd/mailgun-sendmail
go get -u go get github.com/emersion/hydroxide/cmd/hydroxide

# lang server
go get -u golang.org/x/tools/cmd/gopls
go get -u github.com/fhs/acme-lsp/cmd/acme-lsp
go get -u github.com/fhs/acme-lsp/cmd/L
go get -u github.com/fhs/acme-lsp/cmd/acmefocused

# filesystems
go get -u github.com/sirnewton01/ghfs

# libraries 9p 2000 library for go
go get -u github.com/hugelgupf/p9
