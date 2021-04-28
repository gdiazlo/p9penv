# plan9port linux environment

Configurations, clients, scripts and guides to work with plan9ports
in linux.

Because I always forgot to set up something, I just wanna clone this
and be ready.

I just understood why  `/usr/local/plan9` is a good compromise. You just
need to run plan9port on OSX, Linux and FreeBSD, and the easiest way to
set up a profile which behaves as expected on the three systems is by
using a hardcoded system path.

The `NAMESPACE` variable is something ugly too. I decided to create a
`$HOME/.ns/N` direcotry as a namespace point. There is a funcion in
the profile called `nssetup N` which creates folder in case it does not
exists, and return the path created to set up the NAMESPACE variable.

# Install

If you want to contribute to plan9port, it is convenient to clone the
repository on your $HOME folder and then link that to `/usr/local/plan9`
so everything works.

````
% git clone https://github.com/9fans/plan9port.git $HOME/.local/plan9
% sudo ln -s $HOME/.local/plan9 /usr/local/plan9
````

I use `~/.local/plan9` instead of something like `~/src` to remind myself
I cannot left the tree broken, because I use it. But still I want to test
things and make some changes.


# Assets

## Fonts

The `getfonts.rc` script downloads fonts and install them on your `$HOME`.
These days I use IBM Plex family.

One caveat with `fontsrv` is that it does not support fallback fonts on
Linux. It seems to work on OSX. If you need emoji support,
you can use DejaVuSans which has a good UTF support including some emojis.

I have set up that font as default in the profile.

There are Three scripts to play with fonts inside acme:

- `F+` → Increases the size of the current font, by 1 point or the number
passed as argument

- `F-` → Decreases the size of the cuurrent font, by 1 point or the
number passed as argument

- `F` → Sets the current font to be the one passed by argument. If the
font is not found, it greps through the font list searching for the
pattern passed by argument

## Programming languages

I need to use a couple programming languages daily, so I build a couple of scripts to set up the environment for them.
I prefer to manage these environments and versions carefully instead of installing system-wide environments.

The profile loads a lot of variables for each language.

 - `getgo.rc`--> installs golang in $HOME/.local/go
 - `getjava.rc` --> install java in $HOME/.local/java
 - `getscala.rc` --> install metals and scalafmt into $HOME/.local/bin
 - `opam.rc` --> install opam into $HOME/local/bin (beware this is a curl | bash)

# Acme

I use [acme-lsp](https://github.com/fhs/acme-lsp) to work with those
programming languages sometimes.

 - `gopls` --> golang language server
 - `jdt` --> java language server (from eclipse)
 - `metals` --> scala language server
 - `ocaml-lsp` --> ocaml language server
 - `ccls` --> C language server

And also [xplor](https://github.com/mpl/xplor) to naviage code in some
projects with deep nested directories.

# Factotum

I use factotum as a cheap password manager sometimes. For that I have
created [src/pass.c](src/pass.c). It is probably insecure, but a better
option that a plain text file laying araound or a complex password
manager.


# Email

I use nedmail and upas to read email. I have put some documentation in
[docs/p9p-email.md](docs/p9p-email.md)

There are some scripts I use in [mail/](mail/) for reading and sending
email using plan9ports programs.

# Dekstop interface

Still trying to find something satisfactory. Just use whatever it is at
hand for now.

There are too many things out there. Playing nice will them is too
painfull. So I have removed all custom configurations and helpers to
deal with graphical environment

I will let  a way to launch 9term and acme with the plan9port profile
loaded, like .dekstop files or BSDs and Linux.

