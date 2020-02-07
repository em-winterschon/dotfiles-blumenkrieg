#!/usr/bin/env python
from socket import *
from binascii import *
from base64 import *
import sys

def encode(string):
    return urlsafe_b64encode(binascii.hexlify(str(string)))
    
HOST="192.168.200.133"
PORT=9192
ADDR = (HOST,PORT)
MAXCON = 20

serv = socket(AF_INET,SOCK_STREAM)    
serv.bind((ADDR)) #bind to address
serv.listen(MAXCON)  #qmax_connections limit
print 'listening on: %s:%i'%(HOST,PORT)

while 1:
    try:                            
        '''we'll just sit around serving forever unless interrupted.'''
        conn,addr = serv.accept() 
        print "something connected..."
        resp = conn.recv(BUFSIZE)
        print resp
        
    except (KeyboardInterrupt, SystemExit):
        print "killed!"
        serv.close()
        sys.exit(1)
        
    except:
        print "dead"
        serv.close()
        sys.exit(1)

