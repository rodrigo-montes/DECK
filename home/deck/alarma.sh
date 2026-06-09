#!/usr/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

(
    flock -n 268 || { exit 1; }
    cd /home/deck
    echo "$(date) ALARMA" 
    
    telegram() {
        GINFO=-1002805964119
        GALERTA=-4936678208
        GSONDA=-4941009387
        URL_INFO="https://api.telegram.org/bot7495994507:AAFWMsjMLLlgWKxywrK1rezA68deR15AYb4/sendMessage"
        URL_ALERTA="https://api.telegram.org/bot7934392704:AAEOhVgIUWq7QVNzi_otAHuO5MPNiZlVecA/sendMessage"
        URL_SONDA="https://api.telegram.org/bot7704935885:AAGUcb0HLa3cXP5jyL0esdZg9wfqDbYEdko/SendMessage"

        touch /tmp/$1.event
        nv=$(cat /tmp/$1.event)
        if [ "$nv" == "" ] ; then 
            echo 0 > /tmp/$1.event
        else 
            if [ "$3" == "CLR" ] && [ $nv -ne 0 ]; then 
                echo 0 > /tmp/$1.event
                msg="😆$1:$2"
                msgt="{\"chat_id\": \"$GSONDA\", \"text\": \"$msg\", \"disable_notification\": false}"
                #curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_SONDA
            else
                if [ $nv -le 4 ] && [ "$3" != "CLR" ]; then 
                    let nv=nv+1
                    echo $nv > /tmp/$1.event
                    msg="📢[$nv/5] $1:$2"
                    msgt="{\"chat_id\": \"$GSONDA\", \"text\": \"$msg\", \"disable_notification\": false}"
                    #curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_SONDA
                fi
            fi
        fi
    }

    dispara() {
        GINFO=-1002805964119
        GALERTA=-4936678208
        GSONDA=-4941009387
        URL_INFO="https://api.telegram.org/bot7495994507:AAFWMsjMLLlgWKxywrK1rezA68deR15AYb4/sendMessage"
        URL_ALERTA="https://api.telegram.org/bot7934392704:AAEOhVgIUWq7QVNzi_otAHuO5MPNiZlVecA/sendMessage"
        URL_SONDA="https://api.telegram.org/bot7704935885:AAGUcb0HLa3cXP5jyL0esdZg9wfqDbYEdko/SendMessage"

        msg="📢: $1"
        msgt="{\"chat_id\": \"$GSONDA\", \"text\": \"$msg\", \"disable_notification\": false}"
        #curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_SONDA
    }

    secayo() {
        d="$1"
        e=$(cat /tmp/shosts.txt | grep $d | wc -l)
        if [ $e -eq 0 ] ; then 
            telegram $d " NO RESPONDE" 
        else 
            telegram $d " RESPONDE OK" CLR 
        fi
    }

    nomed() {
        d="$1"
        e=$(cat /tmp/nomed.txt | grep $d | wc -l)
        if [ $e -eq 0 ] ; then 
            telegram $d " SIN MEDICION" 
        else 
            telegram $d " MEDICION OK" CLR 
        fi
    }

    # NEUTRALIDAD VTR MOVIL
    IFS=$'\n'
    touch /tmp/alarma.txt
    php alarma1.php > /tmp/alarma.txt
    e=$(cat /tmp/alarma.txt | wc -l)
    if [ $e -ne 0 ] ; then 
        for c in $(cat /tmp/alarma.txt); do
            dispara $c
        done
    fi

    php alarma2.php > /tmp/shosts.txt
    secayo Dispositivo_1
    secayo Dispositivo_3
    secayo FTTH-M900-900-VALLENAR
    secayo B2B_FTTH-M300-300-VALLENAR
    secayo B2B_FTTH-M500-500-VALLENAR

    php alarma3.php > /tmp/nomed.txt
    nomed Dispositivo_1
    nomed Dispositivo_3
    nomed FTTH-M900-900-VALLENAR
    nomed B2B_FTTH-M300-300-VALLENAR
    nomed B2B_FTTH-M500-500-VALLENAR
    
) 268>/tmp/alarma.lockfile