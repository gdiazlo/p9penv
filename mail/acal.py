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

    icsfile = ans.write()

    print('r -a'+icsfile)
