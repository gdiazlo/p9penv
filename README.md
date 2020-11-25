# plan9port linux environment

Configurations, clients, scripts and guides to work with plan9ports
in linux.

Because I always forgot to set up something, I just wanna clone this
and be ready.

I have updated the environment to be aligned with [basedir
spec](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

There are some caveats though:
 - plan9port scripts and wrappers spect to be located into
 `/usr/local/plan9` and the shebang of the scripts is updated with that
 assumption. A proposal might be to use `#!/usr/bin/env $PLAN9/bin/rc`
 as the shebang for scripts. Meanwhile, I link `/usr/local/plan9` into
 the XDG location at `$HOME/.local/plan9`.

# Install

First install [plan9port](https://github.com/9fans/plan9port) into
`$HOME/.local/plan9` and set `PLAN9` environment variable to that
location.

# Assets

## Fonts

The `getfonts.rc` script downloads fonts and install them on your `$HOME`.
These days I use IBM Plex family.

One caveat with `fontsrv` is that it does not support fallback fonts on
Linux. It seems to work on OSX. If you need emoji support desperately,
you can use DejaVuSans which has a good UTF support including some emojis.

## Programming languages

 - getgo.sh --> installs golang in $HOME/.local/go
 - getjava.sh --> install java in $HOME/.local/java
 - getscala.sh --> install metals and scalafmt into $HOME/.local/bin
 - opam.sh --> install opam into $HOME/local/bin (beware this is a curl | bash)

# Acme

I use [acme-lsp](https://github.com/fhs/acme-lsp) to work with those
programming languages.

 - gpls --> golang language server
 - jdt --> java language server (from eclipse)
 - metals --> scala language server
 - ocaml-lsp --> ocaml language server
 - ccls --> C language server

# Factotum

I have an updated ipso script to use `XDG_RUN_DIR` instead of /tmp as
base for the namepsace files. On my profile I set up the `NAMESPACE`
variable to `$XDG_RUNTIME_DIR/ns`

I use factotum as a cheap password manager sometimes. For that I have
created [src/pass.c](src/pass.c). It is probably insecure, but a better
option that a plain text file laying araound or a complex password
manager.

# Email

I use nedmail and upas to read email. I have put some documentation in
[slack9 site](https://slack9.io/howto/p9p-email.html)

There are some scripts I use in [mail/](mail/) for reading and sending
email.

# Dekstop interface

Still trying to find something satisfactory. Just use whatever it is at
hand for now.

