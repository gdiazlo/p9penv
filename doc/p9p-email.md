---
title: plan9port email
lang: en-US
---

## plan9port email

This article describes how to work with email using the
[plan9port] environment.

Most of the tools included in [plan9port] came, obviously, from [Plan9],
but even if they're old, there have been maintained to keep them working
on current systems.

The instructions to set up email on Plan9 can be read on the [wiki]

To read email from [acme], we need to set up:

 - [secstored] to store auth information on disk
 - [factotum] as an authentication agent
 - [upas/fs] or [mailfs] to present a mailbox with a filesystem interface
 - [upas/smtp] or other MTA like [msmtp] to send emails
 - [ned] or Mail to manage the emails
 - and some other utilities

### Install plan9port

To install plan9port I do:

~~~~{.bash}
$ git clone https://github.com/9fans/plan9port.git $HOME/.plan9
$ cd $HOME/.plan9
$ ./INSTALL
~~~~

I do not install plan9port system wide, but you can follow the
standard location and install it in ```/usr/local/plan9``` or where
you want.

To install [upas] utilities, we need to manually build them:

~~~~{.bash}
$ cd $HOME/.plan9/src/cmd/upas
$ $HOME/.plan9/bin/9 mk install
~~~~

### Environment

On Plan9, services posted an entry into the srv filesystem so others
could easily mount their filesystem from them and use they services. On
Plan9Port libraries and programs expect a ```$NAMESPACE``` varaible to
point to that location.

Also, on Plan9 there is the [network database], which in plan9port is
located in ```$PLAN9/ndb```.  On the current plan9port implementation,
the ndb is not generally used, and programs expect some hostnames to
work with their default settings.

On my system, I prepare my environment on my ```$HOME/.profile```[^1]
file like this:

[^1]: To read my current profile, take a loot at my [dot files](https://github.com/gdiazlo/p9penv)


~~~~{.bash}
# ~/.profile
export PLAN9=$HOME/.plan9

NAMESPACE=/tmp/$USER/ns/root
if [ -d $XDG_RUNTIME_DIR ]; then
	NAMESPACE=$XDG_RUNTIME_DIR/ns/root
fi
export NAMESPACE
mkdir -p $NAMESPACE

new_p9p_session() {
	for proc in fontsrv secstored factotum plumber; do
		pgrep $proc 2>&1 > /dev/null
		if [ $? -ne 0 ]; then
			$PLAN9/bin/9 $proc &
		fi
	done
}

new_p9p_session
~~~~

Please read ```[XDG_RUNTIME_DIR]``` documentation, as that folder is deleted when the user logs out.

Then reload your user profile either by logging out and logging in or by loading your profile on your current session:

~~~~{.bash}
$ source $HOME/.profile
~~~~

### Setting up secstored

You can skip this section and go directly to the section abut mailfs
below if you do not plan to use secstore to persist your secrets on disk.

It serves files using the secstore protocol. It allows to securely store
and retrieve files from an encrypted data store on disk.

Secstored starts when the ```new_p9p_session``` function executes when
your profile is loaded.

Secstored programs use by default the host called ```secstore``` as its server name, so we add that to our ```/etc/hosts``` file:

~~~~{.bash}
# echo 127.0.0.1 secstore >> /etc/hosts
~~~~

To use it, we need to create an user into secstore with the ```secuser``` command:

~~~~{.bash}
$ 9 secuser $USER
new account (because $PLAN9/secstore/$USER account does not exist)
$USER password:
retype password:
expires [DDMMYYYY, default = 12052021]:
Enabled or Disabled [default Enabled]:
require STA? [default no]:
comments [default = ]:
hostname Jun 12 22:53:40 CHANGELOGIN for '$USER'
change written
$
~~~~

Files stored in secstore are saved in ```$PLAN9/secstore/store/$USER/```
by default,  filenames can be read, but the contents are encrypted.

There are no files yet on our secstore:

~~~~{.bash}
$ ls $PLAN9/secstore/store/$USER/
$
~~~~

Then we need to store our  credentials in file called ```factotum```
using secstore.

To start, we need to upload an empty ```factotum``` fie to secstore,
so the script  ```ipso``` works correctly.

~~~~{.bash}
$ touch factotum
$ secstore -p factotum
$ rm factotum
~~~~

Other rough edges of the script is the way select where to store the
temporary files.  I use a modified version which uses $XDG_RUNTIME_DIR
as a base.


~~~~
#!/usr/local/plan9/bin/rc

. 9.rc
name = secstore
get = secstoreget
put = secstoreput
edit = no
load = no
flush = no

fn secstoreget{
	secstore -i -g $1 <_password
}

fn secstoreput{
	secstore -i -p $1 <_password
}

fn aesget{
	if(! ~ $1 /*){
		echo >[1=2] ipso: aescbc requires fully qualified pathname
		exit usage
	}
	aescbc -i -d < $1 > `{basename $1} <[3] _password
}

fn aesput{
	aescbc -i -e > $1 < `{basename $1} <[3] _password
}

fn editedfiles{
	if(~ $get aesget){
		for(i in $files)
			if(ls -tr | sed '1,/^_timestamp$/d' | grep -s '^'^`{basename $i}^'$')
				echo $i
	}
	if not
		ls -tr | sed '1,/^_timestamp$/d'
}

while(~ $1 -*){
	switch($1){
	case -a
		name = aescbc
		get = aesget
		put = aesput
	case -f
		flush = yes
	case -e
		edit = yes
	case -l
		load = yes
	case *
		echo >[2=1] 'usage: ipso [-a -f -e -l] [-s] [file ...]'
		exit usage
	}
	shift
}

if(~ $flush no && ~ $edit no && ~ $load no){
	edit = yes
	if(~ factotum $*){
		load = yes
		flush = yes
	}
}

if(~ $flush yes && ~ $edit no && ~ $load no){
	echo flushing old keys
	echo delkey | 9p write factotum/ctl
	exit 0
}

if(~ $get aesget && ~ $#* 0){
	echo >[2=1] ipso: must specify a fully qualified file name for aescbc '(-a)'
	exit usage
}

user=`{whoami}
cd $XDG_RUNTIME_DIR || exit $status
mkdir -p ipso.$user
chmod 700 ipso.$user || exit $status
cd ipso.$user
dir=`{pwd}
dir=$"dir

fn sigexit {
	rm -rf $dir
}

if ( ~ $edit yes ) echo '
	Warning: The editor will display the secret contents of
	your '$name' files in the clear, and they will
	be stored temporarily in '^$dir^'
	in the clear, along with your password.
'

# get password and remember it
readcons -s $name^' password' >_password

# get list of files
if(~ $#* 0){
	if(! secstore -G . -i < _password > _listing){
		echo 'secstore read failed - bad password?'
		sleep 2
		exit password
	}
	files=`{sed 's/[ 	]+.*//' _listing}
}
if not
	files = $*

# copy the files to local ramfs
for(i in $files){
	if(! $get $i){
		echo $name ' read failed - bad password?'
		sleep 2
		exit password
	}
}
sleep 2; date > _timestamp	# so we can find which files have been edited.

# edit the files
if(~ $edit yes){
	B `{for(i in $files) basename $i}
	readcons 'type enter when finished editing' >/dev/null
}
if(~ $flush yes ){
	echo flushing old keys
	echo delkey | 9p write factotum/ctl
}
if(~ $load yes){
	echo loading factotum keys
	if (~ factotum $files) cat factotum | 9p write -l factotum/ctl
}

# copy the files back
for(i in `{editedfiles}){
	prompt='copy '''^`{basename $i}^''' back? [y/n/x]'
	switch(`{readcons $prompt}){
	case [yY]*
		if(! $put $i){
			echo $name ' read failed - bad password?'
			sleep 2
			exit password
		}
		echo ''''$i'''' copied to $name
		if(~ $i factotum && ! ~ $load yes){	# do not do it twice
			cat $i | 9p write -l factotum/ctl
		}
	case [xXqQ]*
		exit
	case [nN]* *
		echo ''''$i'''' skipped
	}
}

exit ''
~~~~

To execute ```ipso``` we first need to open a plan9port editor like
[acme].

~~~~{.bash}
$ ipso

        Warning: The editor will display the secret contents of
        your secstore files in the clear, and they will
        be stored temporarily in /run/user/1000/ipso.gdiazlo
        in the clear, along with your password.

secstore password:
server: your_hostname
server: your_hostname
type enter when finished editing:
~~~~

Then we need to fill the acme window with the contents of our
authentication information:

~~~~
key proto=pass role=client server=imap.mail_provider.com service=imap user=user@mail_provider.com !password=my_imap_password
~~~~

We need to save the file, close it, and press enter on the console where
ipso is waiting.

When we finish the process, we will have a file in
```$PLAN9/secstore/store/$USER/``` called ```factotum``` whose contents
we cannot read.

### Setting up factotum

factotum is the authentication agent that will identify us to the remote
servers. When started, if we have configured a secstore hostname properly,
it will try to load keys from a file called factotum stored in the
secstore server. We can also use ```ipso``` to load our keys using the
```-l``` option.

~~~~{.bash}
$ ipso -l
secstore password:
server: your_host_name
server: your_host_name
loading factotum keys
$
~~~~

After that, we can read the list of entries loaded into ```factotum``
with the following command:

~~~~{.bash}
$ 9 9p read factotum/ctl
key proto=pass role=client server=imap.mail_provider.com service=imap user=user@mail_provider.com !password?
~~~~

We can store credentials for more services in ````factotum```

### Accesing an imap inbox with ```mailfs```

If we have followed the secstore and factotum set up, mailfs will not ask
us for a password, but if we don't, mailfs will ask us for a password
and will fill factotum with our log in information. This information
will not be persisted, so the next time we access our imap service,
we are going to need to type our imap password again.

Now that we can identify ourselves to our imap service, we can instruct
mailfs to connect to our server:

~~~~{.bash}
$ 9 mailfs -t -u my_user@mail_provider.com imap.mail_provider.com
$ 9 9p ls mail
Drafts
Junk
Sent
Trash
ctl
mbox
~~~~

This has created a socket in ```$NAMESPACE``` called ```mail``` which
is serving a 9P connection to email clients like acme Mail and [ned].

If you want to explore the filesystem interface using regular Linux tool
you can use the 9pfuse tool to mount the ```mail``` socket into a folder
like $HOME/mail:

~~~~{.bash}
$ mkdir -p $HOME/mail/personal
$ 9pfuse $NAMESPACE/mail $HOME/mail/personal/
$ ls mail/personal/mbox/
1  2  3  4  6  7  ctl  search
$
~~~~

And here at last, my inbox as presented by [ned]:

~~~~{.bash}
$ $PLAN9/bin/upas/nedmail -S personal
6 messages
: ,h
1   H        0   6/12 22:12 info@mailer.netflix.com     What's playing next, Gabriel?
2   H        0   6/12 18:46 technews-editor@acm.org     ACM TechNews, Friday, June 12, 2020
3   H        0   6/12 18:02 mensajeria@phidias.es       Avisos de comunicados y mensajes
4   H        0   6/12 17:15 contact@communaute.n-py.com Renovación de tu tarjeta No'Souci
5   H        0   6/12 13:06 mensajeria@phidias.es       Actividad de fin de curso - Infantil
6   H        0   6/12 11:58 mensajeria@phidias.es       Para la semana que viene y un articulito :)
:
~~~~

[ned] is a very neat program to work with email. It is easy to deal with multiple emails, and with attachments. For example:

 - ```: g/9fans/ s 9fans``` will save all emails with the 9fans word in
 the headers to the 9fans folder
 - ```: g/tuhs/ h``` will list all emails with tuhs in the headers
 - ```: 2,7 d``` will delete emails two to seven
 - ```: y``` will execute the commands againts the mail box, writting
 the changes the commands made

### Sending email

This set up will use a SMTP service from your email provider. For it to
work we need to configure the ```$HOME/mail/pipefrom``` file.

This script will be in charge to send the email as if it were the
system mailer:

~~~~{.bash}
#!/bin/bash

if [ -z "$upasname" ]; then
	upasname="my_user@my_email_domain"
fi
server="tcp!smtp.my_email_provider.com!smtp"

# the -sa options are for TLS and authentication against $server
cat | $PLAN9/bin/upas/smtp -sa -u $upasname $server $upasname $*
~~~~

Our mailer will use [upas/smtp] to send our email, and it will use
factotum credentials to authenticate against the smtp server of our
provider. We can use other mailers such as [msmtp], but it wont use
factotum to authenticate. Some mailers might be able to integrate with
secstore using scripts to get the secrets from it.

Also, acme Mail will complete our ```From``` address like our
```$USER@$HOSTNAME``` or using the ```upasname``` variable, if we want
to change this, which is almost always, we need to create a file in
```$HOME/mail/headers``` containing the ```From``` line of our emails:


~~~~{.bash}
$ cat headers
From: My Name and Surnames <my_user@my_email_domain>
~~~~

Or we need to export out ```upasname``` variable as you can see on the next section.

### Multiple accounts

Let's say you have, like me, multiple email accounts, one for work and
one for personal stuff for example.

Reading email is as simple as:

~~~~{.bash}
$ 9 mailfs -t -s personal -u my_personal@emailaddr.com imap.personal_provider.com
$ 9 mailfs -t -s work -u my_work@emailaddr.com imap.work_provider.com
~~~~

Now we have two sockets under $NAMESPACE: work and personal. To read
email with [ned][^2] we need to indicate it the name of the mailbox we
want to read:

[^2]: Please note the ```nedmail``` option ```-S``` is only present in
plan9port, it does not appear in then Plan9 man page, and ```nedmail```
does not have a man page on plan9port.

~~~~{.bash}
$ $PLAN9/bin/upas/nedmail -S personal
5 messages
: q
$ $PLAN9/bin/upas/nedmail -S work
1 message
: q
$
~~~~

When launching acme Mail we need to do something simmilar:

~~~~{.bash}
upasname=my_personal@emailaddr.com 9 Mail -n personal
upasname=my_work@emailaddr.com 9 Mail -n work
~~~~

To send emails we need to change our pipefrom script to select which
server to use:

~~~~{.bash}
#!/bin/bash

if [ -z "$upasname" ]; then
	upasname="my_personal@emailaddr.com"
fi

case "$upasname" in
"my_personal@emailaddr.com")
	server="tcp!imap.personal_provider.com!smtp"
	;;
"my_work@emailaddr.com")
	server="tcp!imap.work_provider.com!smtp"
	;;
esac

cat | $PLAN9/bin/upas/smtp -sa -u $upasname $server $upasname $*

~~~~

As you can see, the ```upasname``` variable is used when launching acme
Mail to know not only the ```From``` line, but also to know to which
server is going to send our email.

### Accepting calendar events using ```nedmail```

When editing a maibox with ```nedmail``` we can reply to messages. And when replying to these messages we can pass arguments to ```marshal``` to include files.

We have created a python script to generate a valid ical answer saving it in a temporary file which we will then attach to the reply of the email, answering to the event invitation with an accept, a decline, or tentatively accepted.

~~~~{.python}
#!/usr/bin/env python3

# A rewrite based on https://github.com/marvinthepa/mutt-ical

import vobject
import tempfile, time
import os, sys
import warnings
from datetime import datetime
from getopt import gnu_getopt as getopt

usage="""
It reads an ical event invitation from stdin and generates
an answer accepting, declining or tentatively accepting the event
invitation. The invitation is tentatively accepted by default.

It reads upasname environment variable by default, but other one
can be indicated, ignoring the environment variable.

It will output the nedmail command needed to reply to the message
including the ical event answered.
usage:
%s [OPTIONS] [-e your@email.address]
OPTIONS:
    -p print
    -a accept
    -d decline
    -t tentatively accept
    (print is default, last one wins)
""" % sys.argv[0]

def read_ics():
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            invitation = vobject.readOne(sys.stdin, ignoreUnreadable=True)
    except AttributeError:
        invitation = vobject.readOne(sys.stdin, ignoreUnreadable=True)
    return invitation

class Answer:
    def __init__(self, invitation, resp, email):
        # create
        ans = vobject.newFromBehavior('vcalendar')
        ans.add('method')
        ans.method.value = "REPLY"
        ans.add('vevent')

        for i in ["uid", "summary", "dtstart", "dtend", "organizer"]:
            if i in invitation.vevent.contents:
                ans.vevent.add( invitation.vevent.contents[i][0] )

        # new timestamp
        ans.vevent.add('dtstamp')
        ans.vevent.dtstamp.value = datetime.utcnow().replace(tzinfo = invitation.vevent.dtstamp.value.tzinfo)

        ans.vevent.add('attendee')
        ans.vevent.attendee_list.pop()

        if 'attendee' in invitation.vevent.contents:
            atts = invitation.vevent.contents['attendee']
            for a in atts:
                if self._get_email(a) == email:
                    ans.vevent.attendee_list.append(self._set_resp(a,resp))

        self.ans = ans

    @staticmethod
    def _get_email(att):
        if hasattr(att,'EMAIL_param'):
        	return att.EMAIL_param
        else:
            return att.value.split(':')[1]

    @staticmethod
    def _set_resp(att, resp):
        att.params['PARTSTAT'] = [resp]
        for i in ["RSVP","ROLE","X-NUM-GUESTS","CUTYPE"]:
            if i in att.params:
                del att.params[i]
        return att

    def write(self):
        tempdir = tempfile.mkdtemp()
        icsfile = tempdir+"/event-reply.ics"
        with open(icsfile,"w") as f:
            f.write(self.ans.serialize())
        return icsfile

class Invitation:
    def __init__(self,ical):
        self.ics = ical
        contents = ical.vevent.contents
        self.title = contents['summary'][0].value
        if 'organizer' in ical.vevent.contents:
            if hasattr(ical.vevent.organizer,'EMAIL_param'):
                self.sender = ical.vevent.organizer.EMAIL_param
            else:
                self.sender = ical.vevent.organizer.value.split(':')[1]

        if 'description' in contents:
            self.desc = contents['description'][0].value

        if 'dtstart' in contents:
            self.start = contents['dtstart'][0].value.strftime("%m/%d/%Y, %H:%M:%S")

        if 'dtend' in contents:
            self.end = contents['dtend'][0].value.strftime("%m/%d/%Y, %H:%M:%S")

        if 'attendee' in contents:
            self.attendees = contents['attendee']

    @staticmethod
    def _attendee(a):
        if hasattr(a, 'EMAIL_param'):
            att_mail = a.CN_param
            att_cn = a.EMAIL_param
        else:
            att_mail = a.value.split(':')[1]
            att_cn = a.value.split(':')[1]
            if a.CN_param:
                att_cn = a.CN_param

        return "\t" + att_cn + " <" + att_mail + ">"

    def __str__(self):
        r = map(self._attendee, self.attendees)
        to = "\n".join(r)
        return ("From: %s\n"
               "To:\n%s\n"
               "Title: %s\n"
               "When: from %s to %s\n"
               "Description:\n %s\n") % (self.sender, to, self.title, self.start, self.end, self.desc)

if __name__=="__main__":
    email = os.environ['upasname']
    resp = 'TENTATIVE'
    opts, args=getopt(sys.argv[1:],":epadt")

    invitation = Invitation(read_ics())

    for opt,arg in opts:
        if opt == '-e':
            email = arg
        if opt == '-p':
            print(invitation)
            sys.exit()
        if opt == '-a':
            resp = 'ACCEPTED'
        if opt == '-d':
            resp = 'DECLINED'
        if opt == '-t':
            resp = 'TENTATIVE'

    ans = Answer(invitation.ics, resp, email)

    icsfile, tempdir = ans.write()

    print('r -a'+icsfile)
~~~~

The following session is an example on how to use the sciprt which we called ```acal```:

~~~~{.bash}
$ upasname=gdiaz@-----.com nedmail -S work
9 messages
9: 9.2

!--- cannot display messages of type application/ics
9.2: | acal -a
r -a/tmp/tmpeiiutjwa/event-reply.ics
!
9.2: r -a/tmp/tmpeiiutjwa/event-reply.ics
!$PLAN9/bin/upas/marshal -s 'Re: Invitación: Testing mar 3 de nov de 2020 20:30 - 21 :30 (CET) (gdiaz@-----.com)' -R mbox/12/2 -a/tmp/tmpeiiutjwa/event-reply.ics g.diaz@-----.com
Accepting the message.
slayer Nov  5 21:25:45 gdiaz@-----.com sent 1198 bytes to g.diaz@-----.com
!
9.2:
$
~~~~


#### Todo

- Update ```ipso``` to work with an empty secstore
- Replying to an email from [ned] does not work, becasue ```upas/marshal``` fails due to mailer being incorrectly set up.
- How to work with calendar attachments, remainders and tasks, proposing new dates for a meeting, etc.
- How to work with PGP email signatures, validating remote signatures, signing and encrypting our emails.

[XDG_RUNTIME_DIR]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
[plan9port]: https://github.com/9fans/plan9port
[Plan9]: https://plan9.io
[secstored]: https:///plan9.io/magic/man2html/8/secstore
[factotum]: https:///plan9.io/magic/man2html/4/factotum
[upas/fs]: https://plan9.io/magic/man2html/4/upasfs
[mailfs]: https://github.com/9fans/plan9port/tree/master/src/cmd/upas/nfs
[upas/smtp]: https://plan9.io/magic/man2html/8/smtp
[upas]: http://doc.cat-v.org/bell_labs/upas_mail_system/upas.pdf
[acme]: https://plan9.io/magic/man2html/1/acme
[ned]: https://plan9.io/magic/man2html/1/nedmail
[msmtp]: https://marlam.de/msmtp/
[wiki]: https://plan9.io/wiki/plan9/mail_configuration/index.html
[ndb]: https://9fans.github.io/plan9port/man/man7/ndb.html
[network database]: https://plan9.io/magic/man2html/8/ndb
