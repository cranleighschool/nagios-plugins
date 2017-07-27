#!/bin/bash

EXPECTED_ARGS=3

if [ $# -ne $EXPECTED_ARGS ]
then
    echo "Usage :`basename $0` <host> <warn days> <critical days> (`basename $0` ldapserver1 90 30)"
    exit 1
fi

HOST=$1
WARN=$2
CRITICAL=$3

DAYS=$((($(date --date "$(date --date "$(echo "" |openssl s_client -showcerts -connect $HOST:636 < /dev/null 2>&1 | sed -n '/-----BEGIN CERTIFICATE-----/
,/-----END CERTIFICATE-----/p' | openssl x509 -noout -enddate |  sed -n 's/notAfter=//p')")" +%s)-$(date --date now +%s))/86400))

        if [ $DAYS -lt $CRITICAL ]
        then
            echo "CRITICAL - Less than $CRITICAL days (currently $DAYS) remaining validity";
            exit 2;
        else
        if [ $DAYS -eq $CRITICAL ]
        then
            echo "CRITICAL - Exactly $CRITICAL days (currently $DAYS) remaining validity";
            exit 2;
        else

            if [ $DAYS -lt $WARN ]
    then
            echo "WARNING - Less than $WARN days (currently $DAYS) remaining validity";
        exit 1;
    else
            if [ $DAYS -eq $WARN ]
    then
            echo "WARNING - Exactly $WARN days (currently $DAYS) remaining validity";
        exit 1;
    else

        if [ $DAYS -gt $WARN ]
then
    echo "OK - More than $WARN days (currently $DAYS) remaining validity";
    exit 0;
else
    echo "Error - Something broke";
            exit 3;
            fi
    fi
fi
fi
fi
