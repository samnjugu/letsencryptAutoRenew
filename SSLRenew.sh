#!/bin/bash

## REMAINING DAYS TO EXPIRE BEFORE RENEW
DAYSTORENEW=5

##   REMAINING DAYS TO EXPIRE BEFORE ALERT
DAYSTOALERT=3

## EMAIL TO ALERT IF CERT CLOSE TO EXPIRY
ALERTEMAIL=root@localhost

## EMAIL ACCOUNT TO NOTIFY
LEEMAIL=root@localhost,primary@mygmail.com,mycell@myprovider.net

LEBIN=/root/.local/share/letsencrypt/bin/letsencrypt

CERTFILE=/etc/letsencrypt/live/domain.com/cert.pem

#Header example - "$(echo -e "SSL Renew Error\nFrom: Someguy <root@domain.com> \nContent-Type: text/html\n")"
ERRORHEADER="SSL Renew Error\nFrom: Someguy <root@domain.com>\n"
SUCCESSHEADER="SSL Renew Success\nFrom: Someguy <root@domain.com>\n"

d1=$(date -d "`openssl x509 -in $CERTFILE -text -noout|grep "Not After"|cut -c 25-`" +%s)
d2=$(date -d "now" +%s)
DAYS=` echo \( $d1 -  $d2 \)  / 86400 |bc `
#echo -n `date` DOMAIN domain.com will expire in $DAYS days " "

if test $DAYS -lt $DAYSTORENEW ; then
    #echo Trying to renew ;
    /root/.local/share/letsencrypt/bin/letsencrypt -c /root/domain.com.ini -d domain.com -d www.domain.com auth

    #Restart Apache gracefully
    apachectl -k graceful

    #Success email
     echo ALERT DOMAIN CERTIFICATE RENEWAL PROBLEM|mail -s "$(echo -e $SUCCESSHEADER)"  $LEEMAIL ;
#else
# Echo for test only comment it out afterwards
#    echo cert not close to expire ;
fi

if test $DAYS -lt $DAYSTOALERT ; then
    echo ALERT DOMAIN CERTIFICATE RENEWAL PROBLEM|mail -s "$(echo -e $ERRORHEADER)"  $LEEMAIL ;
    #echo ALERT DOMAIN CERTIFICATE RENEWAL PROBLEM ;
fi;
