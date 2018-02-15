 #!/bin/bash

# Download go lang toosl and helpers

go get golang.org/x/tools/cmd/goimports
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/gotype
go get golang.org/x/tools/cmd/stringer
go get golang.org/x/tools/cmd/guru
go get golang.org/x/tools/cmd/eg
go get golang.org/x/tools/cmd/cover

# 3rd party


go get github.com/davidrjenni/A
go get github.com/zmb3/gogetdoc
go get github.com/godoctor/godoctor
go get github.com/josharian/impl
go get github.com/fatih/gomodifytags
go get github.com/davidrjenni/reftools/cmd/fillstruct


