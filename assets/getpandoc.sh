#!/usr/bin/env sh

# curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

dir=$(mktemp -d)
curl -L "https://github.com/jgm/pandoc/releases/download/2.11.3.2/pandoc-2.11.3.2-linux-amd64.tar.gz" | tar zx --strip-components 1 -C "$dir"
mv $dir/bin/pandoc $HOME/.local/bin/

# pandoc templates
curl 'https://raw.githubusercontent.com/ryangrose/easy-pandoc-templates/master/copy_templates.sh' | bash


