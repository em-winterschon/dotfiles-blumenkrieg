#!/usr/bin/env python

'''http://code.activestate.com/recipes/409689-icmplib-library-for-creating-and-reading-icmp-pack/'''

import dpkt
import socket, random

echo = dpkt.icmp.ICMP.Echo()
echo.id = random.randint(0, 0xffff)
echo.seq = random.randint(0, 0xffff)
echo.data = 'hello world'

icmp = dpkt.icmp.ICMP()
icmp.type = dpkt.icmp.ICMP_ECHO
icmp.data = echo

sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, dpkt.ip.IP_PROTO_ICMP)
sock.connect(('192.168.200.133', 9192))
sent = sock.send(str(icmp))

print 'sent %d bytes' % sent
