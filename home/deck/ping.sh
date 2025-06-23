#!/usr/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

(
    flock -n 228 || { exit 1; }
    cd /home/deck
    echo "$(date) PING" 
    
    telegram() {
        GINFO=-1002805964119
        GALERTA=-4936678208
        URL_INFO="https://api.telegram.org/bot7495994507:AAFWMsjMLLlgWKxywrK1rezA68deR15AYb4/sendMessage"
        URL_ALERTA="https://api.telegram.org/bot7934392704:AAEOhVgIUWq7QVNzi_otAHuO5MPNiZlVecA/sendMessage"

        touch /tmp/$1.event
        nv=$(cat /tmp/$1.event)
        if [ "$nv" == "" ] ; then 
            echo 0 > /tmp/$1.event
        else 
            if [ "$3" == "CLR" ] && [ $nv -ne 0 ]; then 
                echo 0 > /tmp/$1.event
                msg="$2"
                msgt="{\"chat_id\": \"$GALERTA\", \"text\": \"$msg\", \"disable_notification\": false}"
                curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_ALERTA
            else
                if [ $nv -le 4 ] && [ "$3" != "CLR" ]; then 
                    let nv=nv+1
                    echo $nv > /tmp/$1.event
                    msg="[$nv/5]: $2"
                    msgt="{\"chat_id\": \"$GALERTA\", \"text\": \"$msg\", \"disable_notification\": false}"
                    curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_ALERTA
                fi
            fi
        fi
    }

    pping(){
        v=$(ping -c 5 $1 | grep transmitted | awk '{gsub("%","");print $6}')
        if [ "$v" == "" ] ; then v=100; fi
        echo "$2 $1 LOST: $v%"
        if [ $v -ne 0 ] ; then
            telegram $1 "$2 $1 PING LOST: $v%"
        else 
            telegram $1 "$2 $1 PING [OK] %" CLR
        fi
    }

    TOROMILLO=192.168.44.28
    LENGA=192.168.44.76
    HUALLE=192.168.44.15
    ARAUCARIA=192.168.44.20
    RAULI=192.168.44.50
    CHOPO=192.168.44.48
    BOLDO=192.168.44.43
    LLEUQUE=192.168.44.60
    ROBLE=192.168.44.40
    LUMA=192.168.44.26
    ULMO=192.168.44.27
    ALERCE=192.168.44.55
    TINEO=192.168.44.78
    PEUMO=192.168.44.56
    LAUREL=192.168.44.70

    ROUTER1=192.168.33.253
    ROUTER2=192.168.33.249

    MIKROTIK_SW=192.168.33.2
    MSSQL=192.168.33.7

    pping $TOROMILLO TOROMILLO
    pping $LENGA LENGA
    pping $HUALLE HUALLE
    pping $ARAUCARIA ARAUCARIA
    pping $RAULI RAULI
    pping $CHOPO CHOPO
    pping $BOLDO BOLDO
    pping $LLEUQUE LLEUQUE
    pping $ROBLE ROBLE
    pping $LUMA LUMA
    pping $ULMO ULMO
    pping $ALERCE ALERCE
    pping $TINEO TINEO
    pping $PEUMO PEUMO
    pping $LAUREL LAUREL

    pping $ROUTER1 ROUTER1
    pping $ROUTER2 ROUTER2

    pping $MIKROTIK_SW MIKROTIK_SW

    pping $MSSQL MSSQL

) 228>/tmp/ping.lockfile