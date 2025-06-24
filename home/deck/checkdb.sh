#!/usr/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/mssql-tools/bin:/root/bin:/opt/mssql-tools/bin
export PATH
(
  flock -n 222 || { exit 1; }
  echo "$(date) CHECKDB" 
  cd /home/deck
  # curl -X POST -H 'Content-Type: application/json'  -d '{"chat_id": "-1002805964119", "text": "TEST INFO", "disable_notification": false}' https://api.telegram.org/bot7495994507:AAFWMsjMLLlgWKxywrK1rezA68deR15AYb4/sendMessage
  # curl -X POST -H 'Content-Type: application/json'  -d '{"chat_id": "-4936678208", "text": "TEST ALERTAS", "disable_notification": false}' https://api.telegram.org/bot7934392704:AAEOhVgIUWq7QVNzi_otAHuO5MPNiZlVecA/sendMessage

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
            msg="😆$2"
            msgt="{\"chat_id\": \"$GALERTA\", \"text\": \"$msg\", \"disable_notification\": false}"
            curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_ALERTA
        else
            if [ $nv -le 4 ] && [ "$3" != "CLR" ]; then 
                let nv=nv+1
                echo $nv > /tmp/$1.event
                msg="📢[$nv/5]: $2"
                msgt="{\"chat_id\": \"$GALERTA\", \"text\": \"$msg\", \"disable_notification\": false}"
                curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_ALERTA
            fi
        fi
    fi
  }

  cd /root
  dateOK=$(date +"%H%M")
  date=$(date +"%Y-%m-%d %H:%M")
  OK=true
  GINFO=-1002805964119
  GALERTA=-4936678208
  URL_INFO="https://api.telegram.org/bot7495994507:AAFWMsjMLLlgWKxywrK1rezA68deR15AYb4/sendMessage"
  URL_ALERTA="https://api.telegram.org/bot7934392704:AAEOhVgIUWq7QVNzi_otAHuO5MPNiZlVecA/sendMessage"

  # EES
  i=$(echo "show databases" | mysql --defaults-extra-file=/root/.my.cfg | grep zoftcom | wc -l)
  if [ $i -eq 0 ] ; then
    msg="MYSQL EES DOWN"
    echo CHECKDB "$msg"
    echo ""  > /tmp/mysql.log.txt
    telegram "MYSQL-EES" "$msg"
    #php mail.php "$msg"
    OK=false
  else 
    msg="MYSQL EES [OK]"
    telegram "MYSQL-EES" "$msg" CLR
    echo CHECKDB 'MYSQL EES OK'
  fi

  # NEUTRALIDAD
  i=$(echo "show databases" | mysql --defaults-extra-file=/root/.myivc.cfg -h 192.168.33.33 | grep zabbix3_ivc | wc -l)
  if [ $i -eq 0 ] ; then
    msg="NEUTRALIDAD MYSQL DOWN"
    echo CHECKDB "$msg"
    echo ""  > /tmp/mysql.log.txt
    telegram "MYSQL-NEUTRALIDAD" "$msg"
    #php mail.php "$msg"
    OK=false
  else 
    msg="NEUTRALIDAD MYSQL [OK]"
    telegram "MYSQL-NEUTRALIDAD" "$msg" CLR
    echo CHECKDB 'NEUTRALIDAD MYSQL OK'
  fi

  # MSSQL 
  i=$(/opt/mssql-tools/bin/sqlcmd  -S 192.168.33.7 -Usa -P Iblau2015 -s -W -Q "select domainname  from MailServer.dbo.hm_domains"  | grep "local.com" | wc -l)
  if [ $i -eq 0 ] ; then
    msg="MSSQL DOWN"
    echo CHECKDB "$msg" 
    echo ""  > /tmp/mysql.log.txt
    #php mail.php "$msg"
    telegram "MSSQL" "$msg"
    OK=false
  else
    msg="MSSQL [OK]"
    telegram "MSSQL" "$msg" CLR
    echo CHECKDB 'MSSQL OK'
  fi
  if [ "$dateOK" == "1100" ] ; then
    msg="DB OK"
    msgt="{\"chat_id\": \"$GINFO\", \"text\": \"$msg\", \"disable_notification\": true}"
    curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_INFO
    # msgt="{\"chat_id\": \"$GALERTA\", \"text\": \"$msg\", \"disable_notification\": true}"
    # curl -X POST -H 'Content-Type: application/json' -d "$msgt" $URL_ALERTA
    # echo ""  > /tmp/mysql.log.txt
    # php mail.php "$msg"
  fi
) 222>/tmp/checkdb.lockfile
