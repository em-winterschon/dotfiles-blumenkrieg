#!/usr/bin/env python
''' @PACKAGE generic_ssh_login.py
    @AUTHOR Madeline Everett
    @COPYRIGHT (c) 2012-present Madeline Everett
    @LICENSE: GPLv3, docs/gpl-3.0.txt, http://www.gnu.org/licenses/gpl-3.0.txt
'''
import pexpect

ssh_newkey = 'Are you sure you want to continue connecting'
p=pexpect.spawn('ssh user@host uname -a')
i=p.expect([ssh_newkey,'password:',pexpect.EOF])

if i==0:
    print "sending yes..."
    p.sendline('yes')
    i=p.expect([ssh_newkey,'password:',pexpect.EOF])

if i==1:
    print "sending password...",
    p.sendline("password-here")
    p.expect(pexpect.EOF)

elif i==2:
    print "we got a key or a timeout"
    pass

print p.before # print out the result
