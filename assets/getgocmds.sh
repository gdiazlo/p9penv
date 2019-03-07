 #!/bin/bash

# Download go lang toosl and helpers
go get -u golang.org/x/tools/...

# 3rd party

go get -u github.com/davidrjenni/A
go get -u github.com/rogpeppe/godef
go get -u github.com/nsf/gocode
go get -u github.com/zmb3/gogetdoc
go get -u github.com/godoctor/godoctor
go get -u github.com/josharian/impl
go get -u github.com/fatih/gomodifytags
go get -u github.com/davidrjenni/reftools/cmd/fillstruct
go get -u github.com/9fans/go/acme/editinacme
go get -u github.com/9fans/go/acme/acmego
go get -u github.com/9fans/go/acme/Watch
go get -u github.com/mpl/xplor

# other tools

go get -u rsc.io/mailgun/cmd/mailgun-mail
go get -u rsc.io/mailgun/cmd/mailgun-sendmail

# lang server
GO111MODULE=auto go get -u github.com/sourcegraph/go-langserver
GO111MODULE=auto go get github.com/fhs/acme-lsp/cmd/L
GO111MODULE=on go get github.com/saibing/bingo

