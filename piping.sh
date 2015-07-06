#!/bin/bash
##########################################################################################################
##   State:    Volatile
##  Author:    Andrew Hill
## Content:    PiAware monitoring script, to be run from a separate server
## Version:    0.0.1## Based on dump1090-tools by mutability.

## Copyright (c) 2015, Andrew Hill <andy@hillhome.org>
## 
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
## 
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#########################################################################################################

SERVERIP=w.x.y.z
NOTIFYEMAIL=youremail@server.com

ping -c 3 $SERVERIP > /dev/null 2>&1
if [ $? -ne 0 ]
then
   # Down - send an e-mail if one hasn't been sent already
      if [ ! -f /tmp/pipingfail.state ]
      then
      	mailx -s "Down: PiAware is down" "$NOTIFYEMAIL" < /dev/null 
      	touch /tmp/pipingfail.state
      fi
else
   # Up - Send up notification if previously down, otherwise check for incoming messages
      if [ -f /tmp/pipingfail.state ]
      then
      	mailx -s "Up: PiAware is back UP" "$NOTIFYEMAIL" < /dev/null
      	rm -f /tmp/pipingfail.state
      else # test dump1090 is receiving messages
        count=$(sleep 10 | telnet $SERVERIP 10001 | grep hexid | wc -l)
        if [ $count -eq 0 ]
        then
          if [ ! -f /tmp/pinomsgs.state ]
          then
            mailx -s "Down: PiAware not receiving messages" "$NOTIFYEMAIL" < /dev/null
            touch /tmp/pinomsgs.state
          fi
        else
          if [ -f /tmp/pinomsgs.state ]
          then
            mailx -s "Up: PiAware is receiving messages again" "$NOTIFYEMAIL" < /dev/null
            rm -f /tmp/pinomsgs.state
          fi 
        fi  
      fi
fi
