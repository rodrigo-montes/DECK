#!/usr/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

if [ "$1" == "MOVE" ] ; then
    echo "update syslog.dash set v23=v22,v22=v21,v21=v20,v20=v19,v19=v18,v18=v17,v17=v16,v16=v15,v15=v14,v14=v13,v13=v12,v12=v11,v11=v10,v10=v9,v9=v8,v8=v7,v7=v6,v6=v5,v5=v4,v4=v3,v3=v2,v2=v1,v1=v0,v0=0" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
    exit
fi 

(
    flock -n 734 || { exit 1; }
    cd /home/deck

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

    foo() {
        echo "foo $1 $2 $3 $4"
        h=$(date +%H | awk '{print $1*1}')
        if [ "$1" == "-1" ] ; then
            echo "update dash set value=$1,v0=$1 where (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        else 
            echo "update syslog.dash set value=$1 where (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
            echo "update syslog.dash set v0=value where sign=2 and value > v0 and (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
            echo "update syslog.dash set v0=value where (sign=1 and value < v0) or v0 = 0 and (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        fi
    }
 
    fooreplace() {
        echo "fooreplace $1 $2 $3 $4"
        h=$(date +%H | awk '{print $1*1}')
        echo "update dash set value=$1,v0=$1 where (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
    }

    fooadd() {
        echo "fooadd $1 $2 $3 $4"
        h=$(date +%H | awk '{print $1*1}')
        echo "update dash set value=value+$1,v0=v0+$1 where (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
    }

    footxt() {
        data=$(cat $1 | head -7)
        echo "update dash set txt='$data' where (servername='$2' or serverip='$2') and class='$3'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
    }

    disk() {
        h=$(date +%H | awk '{print $1*1}')
        v=$(timeout 15 sshpass -e ssh $1 "df -h /" | awk '{gsub("%","");print $5}' | grep -v Use)
        if [ "$v" == "" ] ; then v=-1; fi
        mm=$(echo $v | awk '{printf "%d",$1+0.5}')
        if [ $mm -ge 90 ] ; then 
            telegram "DISK-$3" "DISK: $1 $2 $mm %"
        else 
            telegram "DISK-$3" "DISK: $1 $2 $mm % [OK]" CLR
        fi

        echo "DISK $v $1"
        echo $v > /tmp/$p/tmp/$1-disk0.txt
        echo "update dash set value=$v where (servername='$1' or serverip='$1') and class='DISK0'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where sign=2 and value > v0 and (servername='$1' or serverip='$1') and class='DISK0'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where (sign=1 and value < v0) or v0 = 0 and (servername='$1' or serverip='$1') and class='DISK0'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog

        v=$(timeout 15 sshpass -e ssh $1 "df -h /home" | awk '{gsub("%","");print $5}' | grep -v Use)
        if [ "$v" == "" ] ; then v=-1; fi
        echo $v > /tmp/$p/tmp/$1-disk1.txt
        echo "update dash set value=$v where (servername='$1' or serverip='$1') and class='DISK1'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where sign=2 and value > v0 and (servername='$1' or serverip='$1') and class='DISK1'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where (sign=1 and value < v0) or v0 = 0 and (servername='$1' or serverip='$1') and class='DISK1'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
    }

    servercpu() {
        h=$(date +%H | awk '{print $1*1}')
        uptime=$(timeout 10 sshpass -e ssh $1 uptime | awk '{gsub(",","");print $(NF-2),$(NF-1),$(NF)'})
        v5=$(echo $uptime | awk '{print $1}')
        v10=$(echo $uptime | awk '{print $2}') 
        v15=$(echo $uptime | awk '{print $3}')
        echo "CPU $v5 $v10 $v15 $1"

        if [ "$v5" == "" ] ; then v5=-1; fi
        if [ "$v10" == "" ] ; then v10=-1; fi
        if [ "$v15" == "" ] ; then v15=-1; fi
        mm=$(echo $v10 | awk '{printf "%d",$1+0.5}')
        if [ $mm -ge 10 ] ; then 
            telegram "CPU-$3" "CPU: $1 $2 5m:$v5 10m:$v10 15m:$v15"
        else 
            telegram "CPU-$3" "CPU: $1 $2 5m:$v5 10m:$v10 15m:$v15 [OK]" CLR
        fi
        echo "update dash set value=$v5 where (servername='$1' or serverip='$1') and class='5'"   | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where sign=2 and value > v0 and (servername='$1' or serverip='$1') and class='5'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where (sign=1 and value < v0) or v0 = 0 and (servername='$1' or serverip='$1') and class='5'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog

        echo "update dash set value=$v10 where (servername='$1' or serverip='$1') and class='10'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where sign=2 and value > v0 and (servername='$1' or serverip='$1') and class='10'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where (sign=1 and value < v0) or v0 = 0 and (servername='$1' or serverip='$1') and class='10'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog

        echo "update dash set value=$v15 where (servername='$1' or serverip='$1') and class='15'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where sign=2 and value > v0 and (servername='$1' or serverip='$1') and class='15'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
        echo "update syslog.dash set v0=value where (sign=1 and value < v0) or v0 = 0 and (servername='$1' or serverip='$1') and class='15'" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL syslog
    }

    #echo -n "."
    IVC_MYSQL=192.168.33.33
    IVC=192.168.33.30
    IVC_ETL=192.168.33.14
    EES_CLOUD_DEVEL=192.168.33.50
    EES_CLOUD_MYSQL=192.168.33.9
    EES_CLOUD_NF2057=192.168.33.11
    EES_CLOUD_NF2056=192.168.33.23
    EES_CLOUD_POST1=192.168.33.12
    EES_CLOUD_WS1=192.168.33.15
    EES_CLOUD_ETL=192.168.33.14
    EES_CLOUD_WEB=192.168.33.18
    EES_CLOUD_DNS1=192.168.33.16
    EES_CLOUD_NF=192.168.33.16
    EES_CLOUD_NF2055=192.168.33.16
    EES_CLOUD_DNS2=192.168.33.17
    EES_CLOUD_INGBELL=192.168.33.41
    INGBELL_MYSQL=192.168.201.44
    INGBELL_NF=192.168.201.60
    INGBELL_WS=192.168.201.51
    INGBELL_DNS1=192.168.201.248
    INGBELL_DNS2=192.168.201.247
    INGBELL_ETL=192.168.201.51
    HOTSPOT=192.168.33.60
    DEVEL=192.168.33.50

    MSSQL=192.168.33.7
    R510=192.168.44.76

    LINES=-6

    SSHPASS=iblau2015
    export SSHPASS

    dt=$(date +"%Y-%m-%d %H")
    dt2=$(date +"%b %d %H")
    p=$(ls -1 /tmp/ | grep httpd | tail -1)
    timeout 5 sshpass -e ssh $IVC mpstat | grep all |awk '{print "u:"$4" n:"$5" s:"$5" i:"$6}' > /tmp/ivc_cpu_used.txt
    mv /tmp/ivc_cpu_used.txt /tmp/$p/tmp/ivc_cpu_used.txt
    timeout 5  sshpass -e  ssh $IVC_MYSQL mpstat | grep all |awk '{print "u:"$4" n:"$5" s:"$5" i:"$6}' > /tmp/ivcmysql_cpu_used.txt
    mv /tmp/ivcmysql_cpu_used.txt /tmp/$p/tmp/ivcmysql_cpu_used.txt

    #echo -n "." 

    # NEUTRALIDAD VTR FIJO
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=1 and host not like '%OLD%'and groupname='NEUTRALIDAD_CABLE'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a  > /tmp/$p/tmp/neutralidad-fijo-available.txt
    foo $a MYSQLIVC CABLEUP
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=2 and host not like '%OLD%'and groupname='NEUTRALIDAD_CABLE'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a > /tmp/$p/tmp/neutralidad-fijo-dead.txt
    foo $a MYSQLIVC CABLEDOWN
    echo "SELECT host as HOSTNAME FROM viewHosts where status=0 and available=2 and host not like '%OLD%'and groupname='NEUTRALIDAD_CABLE' order by 1" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | grep -v HOSTNAME | awk '{print $0,"<br>";}' | head $LINES > /tmp/$p/tmp/neutralidad-fijo-dead-host.txt
    footxt /tmp/$p/tmp/neutralidad-fijo-dead-host.txt MYSQLIVC CABLEDOWN

    if [ $a -ge 20 ] ; then
        telegram NEU-FIJO-VTR "NEU FIJO VTR $a DOWN"
    else 
        telegram NEU-FIJO-VTR "NEU FIJO VTR $a [OK]" CLR
    fi
    
    # NEUTRALIDAD CLARO FIJO
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=1 and host not like '%OLD%'and groupname='NEUTRALIDAD_CLARO'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a  > /tmp/$p/tmp/neutralidad-fijo-available.txt
    foo $a MYSQLIVC CLAROUP
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=2 and host not like '%OLD%'and groupname='NEUTRALIDAD_CLARO'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a > /tmp/$p/tmp/neutralidad-fijo-dead.txt
    foo $a MYSQLIVC CLARODOWN
    echo "SELECT host as HOSTNAME FROM viewHosts where status=0 and available=2 and host not like '%OLD%'and groupname='NEUTRALIDAD_CLARO' order by 1" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | grep -v HOSTNAME | awk '{print $0,"<br>";}' | head $LINES > /tmp/$p/tmp/neutralidad-fijo-dead-host.txt
    footxt /tmp/$p/tmp/neutralidad-fijo-dead-host.txt MYSQLIVC CLARODOWN

    if [ $a -ge 20 ] ; then
        telegram NEU-FIJO-CLARO "NEU FIJO CLARO $a DOWN"
    else 
        telegram NEU-FIJO-CLARO "NEU FIJO CLARO $a [OK]" CLR
    fi

    # NEUTRALIDAD VTR MOVIL
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=1 and host not like '%OLD%' and groupname='NEUTRALIDAD_MOVIL'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a  > /tmp/$p/tmp/neutralidad-movil-available.txt
    foo $a MYSQLIVC MOVILUP
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=2 and host not like '%OLD%' and groupname='NEUTRALIDAD_MOVIL'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a  > /tmp/$p/tmp/neutralidad-movil-dead.txt
    foo $a MYSQLIVC MOVILDOWN
    echo "SELECT host as HOSTNAME FROM viewHosts where status=0 and available=2 and host not like '%OLD%' and groupname='NEUTRALIDAD_MOVIL' order by 1" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | grep -v HOSTNAME | awk '{print $0,"<br>"'}  | head $LINES > /tmp/$p/tmp/neutralidad-movil-dead-host.txt
    footxt /tmp/$p/tmp/neutralidad-movil-dead-host.txt MYSQLIVC MOVILDOWN

    if [ $a -ge 10 ] ; then
        telegram NEU-MOVIL-VTR "NEU MOVIL VTR $a DOWN"
    else 
        telegram NEU-MOVIL-VTR "NEU MOVIL VTR $a [OK]" CLR
    fi

    # NEUTRALIDAD CLARO MOVIL
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=1 and host not like '%OLD%' and groupname='NEUTRALIDAD_MOVIL_CLARO'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a  > /tmp/$p/tmp/neutralidad-movil-available.txt
    foo $a MYSQLIVC CLAROMOVILUP
    a=$(echo "SELECT count(*) as cnt FROM viewHosts where status=0 and available=2 and host not like '%OLD%' and groupname='NEUTRALIDAD_MOVIL_CLARO'" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | tail -1)
    echo $a  > /tmp/$p/tmp/neutralidad-movil-dead.txt
    foo $a MYSQLIVC CLAROMOVILDOWN
    echo "SELECT host as HOSTNAME FROM viewHosts where status=0 and available=2 and host not like '%OLD%' and groupname='NEUTRALIDAD_MOVIL_CLARO' order by 1" | timeout 15 mysql --defaults-extra-file=/home/deck/.ivc.cfg zabbix3_ivc | grep -v HOSTNAME | awk '{print $0,"<br>"'}  | head $LINES > /tmp/$p/tmp/neutralidad-movil-dead-host.txt
    footxt /tmp/$p/tmp/neutralidad-movil-dead-host.txt MYSQLIVC CLAROMOVILDOWN

     if [ $a -ge 10 ] ; then
        telegram NEU-MOVIL-CLARO "NEU MOVIL CLARO $a DOWN"
    else 
        telegram NEU-MOVIL-CLARO "NEU MOVIL CLARO $a [OK]" CLR
    fi

    echo "SELECT code,updated FROM HOTSPOT.iden where id <> 897704 and updated <= date_add(now(), interval -1 hour)" | timeout 15 mysql --defaults-extra-file=/home/deck/.ees.cfg -h 192.168.33.9 | grep -v updated | awk '{print $2,$3,$1,"<br>";}' > /tmp/$p/tmp/hp.txt
    v=$(cat /tmp/$p/tmp/hp.txt | wc -l)
    foo $v HOTSPOT DOWN
    echo "SELECT code,updated FROM HOTSPOT.iden where id <> 897704 and updated <= date_add(now(), interval -1 hour)" | timeout 15 mysql --defaults-extra-file=/home/deck/.ees.cfg -h 192.168.33.9 | grep -v updated | head $LINE | awk '{print $2,$3,"<strong>",$1,"</strong><br>";}' > /tmp/$p/tmp/hp.txt
    footxt  /tmp/$p/tmp/hp.txt HOTSPOT DOWN
    
    # NEUTRALIDAD
    timeout 5 sshpass -e ssh $IVC zcat  /var/log/ivcserver-neutralidad.log-$(date +"%Y%m%d").gz | grep DONE  | grep -v TEST | grep -v Q | grep STATS | tail -4 | awk '{gsub("NEUTRALIDAD_","");print $1,$2,substr($4,13),$5," MES<br>"}' | tail -2 > /tmp/$p/tmp/stats-neutralidad.txt
    timeout 5 sshpass -e ssh $IVC zcat  /var/log/ivcserver-neutralidad.log-$(date +"%Y%m%d").gz | grep DONE  | grep -v TEST | grep Q | grep STATS | tail -4 | awk '{gsub("NEUTRALIDAD_","");print $1,$2,substr($4,13),$5," Q<br>"}' | tail -2 >> /tmp/$p/tmp/stats-neutralidad.txt
    a=$(cat /tmp/$p/tmp/stats-neutralidad.txt | wc -l)
   
    foo $a IVC NEUTRALIDAD
    if [ $a -ne 4 ] ; then
        echo '<span#style="color:blue">' >> /tmp/$p/tmp/stats-neutralidad.txt
        timeout 5 sshpass -e ssh $IVC zcat  /var/log/ivcserver-neutralidad.log-$(date +"%Y%m%d").gz  | grep -v TEST | grep -v wp_options | grep '\[STATS\]' | tail -2 | awk '{gsub(" NEUTRALIDAD_","");gsub("\\[STATS\\] ","");gsub("done ","");print $0,"<br>";}' >> /tmp/$p/tmp/stats-neutralidad.txt
        echo '</span>' >> /tmp/$p/tmp/stats-neutralidad.txt
    fi  
    echo '<span#style="color:blue">' >> /tmp/$p/tmp/stats-neutralidad.txt
    timeout 5 sshpass -e ssh $IVC zcat  /var/log/ivcserver-neutralidad.log-$(date +"%Y%m%d").gz  | grep -v TEST | grep -v wp_options | grep '\[STATS\]' | grep " All done in" | tail -1 | awk '{gsub(" NEUTRALIDAD_","");gsub("\\[STATS\\] ","");gsub("done ","");print $0,"<br>";}' >> /tmp/$p/tmp/stats-neutralidad.txt
    echo '</span>' >> /tmp/$p/tmp/stats-neutralidad.txt
    
    footxt /tmp/$p/tmp/stats-neutralidad.txt IVC NEUTRALIDAD

    timeout 5 sshpass -e ssh $IVC zcat  /var/log/ivcserver-neutralidad.log-$(date +"%Y%m%d").gz | grep DONE  | grep -v TEST | grep STI | tail -2 | awk '{gsub(" NEUTRALIDAD_","");gsub("\\[STATS\\] ","");gsub("done ","");print $6,$7,$8,"",$1,$2,"<br>"}' > /tmp/$p/tmp/stats-sti.txt
    touch /tmp/$p/tmp/stats-sti.txt
    a=$(cat /tmp/$p/tmp/stats-sti.txt | wc -l)
    foo $a IVC STI
    if [ $a -ne 2 ] ; then
        echo '<span#style="color:blue">' >> /tmp/$p/tmp/stats-sti.txt
        timeout 5 sshpass -e ssh $IVC zcat  /var/log/ivcserver-neutralidad.log-$(date +"%Y%m%d").gz | grep -v TEST | grep '\[STI\]' | grep All | tail -1 | awk '{gsub(" NEUTRALIDAD_","");gsub("\\[STATS\\] ","");gsub("done ","");print $0,"<br>";}' >> /tmp/$p/tmp/stats-sti.txt
        echo '</span>' >> /tmp/$p/tmp/stats-sti.txt
    fi 
    footxt /tmp/$p/tmp/stats-sti.txt IVC STI
    touch /tmp/$p/tmp/stats-sti-movil.txt
    a=$(cat /tmp/$p/tmp/stats-sti-movil.txt | wc -l)
    foo $a IVC STIMOVIL
    footxt /tmp/$p/tmp/stats-sti-movil.txt IVC STIMOVIL

    timeout 5 sshpass -e ssh $IVC ps -fea | grep http | wc -l > /tmp/$p/tmp/httpd.txt
    a=$(cat /tmp/$p/tmp/httpd.txt)
    foo $a IVC HTTPD

    # BACKUP
    timeout 5 sshpass -e ssh $IVC find /home/ivcserver/backup/ -mtime -1 -ls| grep sql  | awk '{gsub("/home/ivcserver/backup/","");print $8,$9,$10,$11,"<br>"}' > /tmp/$p/tmp/bkpivc.txt
    a=$(cat /tmp/$p/tmp/bkpivc.txt| wc -l)
    foo $a IVC BACKUP
    footxt /tmp/$p/tmp/bkpivc.txt IVC BACKUP

    timeout 5 sshpass -e ssh $EES_CLOUD_MYSQL find /home/backup -mtime -1 -ls | grep sql | grep -v "dns\|domain\|month\|ping\|rx_tx\|rx-tx" | awk '{gsub("/home/backup/","");print $8,$9,$10,$11,"<br>"}' > /tmp/$p/tmp/bkpees.txt
    a=$(cat /tmp/$p/tmp/bkpees.txt| wc -l)
    foo $a EES BACKUP
    footxt /tmp/$p/tmp/bkpees.txt EES BACKUP

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_DNS1 cat /var/log/dnsparse.log | grep logfile | grep "^$dt" | awk '{print $8}' | grep queries | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD DNS1

    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_DNS2 cat /var/log/dnsparse.log | grep logfile | grep "^$dt" | awk '{print $8}' | grep queries | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    #if [ "$v" == "" ] ; then v=-1; fi
    #fooreplace $v CLOUD DNS2

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_DNS1 cat /var/log/dnsparse.log | grep "log-file" | grep "^$dt" | awk '{print $8}' | grep consultas | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD T-DNS1

    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_DNS2 cat /var/log/dnsparse.log | grep "log-file" | grep "^$dt" | awk '{print $8}' | grep consultas | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    #if [ "$v" == "" ] ; then v=-1; fi
    #fooreplace $v CLOUD T-DNS2

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_POST1 cat /var/log/post.log | grep "^$dt" | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD POST

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_WS1 cat /var/log/ws.log | grep "^$dt" | grep slot | grep -v FINISH |  wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD WS

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_WS1 cat /var/log/ws.log | grep "^$dt" | grep slot | grep -v FINISH | grep -v "33 OK\|: 33-"  |  wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD WS33NOOK

    line=$(timeout 10 sshpass -e ssh $HOTSPOT cat /var/log/dnsparse.log | grep logfile | grep "^$dt")
    v=$(echo $line | awk '{gsub("queries:","");print $8*1}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD MOVISTAR_DNS

    v=$(timeout 20 sshpass -e ssh  $EES_CLOUD_ETL cat /var/log/etlivc.log | grep -v "[eE]rror" | grep "^$dt" | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v EES_CLOUD_ETL LOGIVC 

    v=$(timeout 20 sshpass -e ssh  $EES_CLOUD_ETL cat /var/log/etl.log | grep -v "[eE]rror" | grep "^$dt" | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v EES_CLOUD_ETL LOGEES 

    v=$(timeout 20 sshpass -e ssh  $EES_CLOUD_ETL cat /var/log/etlivc.log | grep "[eE]rror" | grep "^$dt" | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v EES_CLOUD_ETL LOGIVCERROR 

    v=$(timeout 20 sshpass -e ssh  $EES_CLOUD_ETL cat /var/log/etl.log | grep "[eE]rror" | grep "^$dt" | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v EES_CLOUD_ETL LOGEESERROR 

    v=$(timeout 20 sshpass -e ssh  $IVC cat /etc/openvpn/server/openvpn-status.log  | grep CLIENT_LIST | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v IVC OPENVPN.10 

    v=$(timeout 20 sshpass -e ssh  $IVC cat  /var/log/httpd/local-error_log | grep "$dt2" | grep DATA | wc -l )
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v IVC IVCDATAPOST 

    v=$(timeout 20 sshpass -e ssh  $IVC cat  /var/log/httpd/local-error_log | grep "$dt2" | grep chunk | wc -l )
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v NAVIS NAVISCHUNKPOST 

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_POST1 cat /var/log/expire.log | grep "DONE" | grep "^$dt" | grep dns | awk 'BEGIN{sum=0}{sum=sum+$7}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD EXPIRE-DNS

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_POST1 cat /var/log/expire.log | grep "DONE" | grep "^$dt" | grep -v dns | awk 'BEGIN{sum=0}{sum=sum+$6}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD EXPIRE-RXTX
    
    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_POST1 cat /var/log/expire.log | grep "ERROR" | grep "^$dt" | grep dns | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD EXPIRE-DNS-ERROR

    v=$(timeout 10 sshpass -e ssh $EES_CLOUD_POST1 cat /var/log/expire.log | grep "ERROR" | grep "^$dt" | grep rx_tx | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v CLOUD EXPIRE-RXTX-ERROR

    a=$(timeout 5 sshpass -e ssh  $IVC ls -al /usr/share/zabbix/navis/upload/upload1/ 2>/dev/null | wc -l)
    b=$(timeout 5 sshpass -e ssh  $IVC ls -al /usr/share/zabbix/navis/upload/upload2/ 2>/dev/null | wc -l) 
    c=$(timeout 5 sshpass -e ssh  $IVC ls -al /usr/share/zabbix/navis/upload/upload3/ 2>/dev/null | wc -l) 
    d=$(timeout 5 sshpass -e ssh  $IVC ls -al /usr/share/zabbix/navis/upload/upload4/ 2>/dev/null | wc -l) 
    e=$(timeout 5 sshpass -e ssh  $IVC ls -al /usr/share/zabbix/navis/upload/upload5/ 2>/dev/null | wc -l) 
    f=$(timeout 5 sshpass -e ssh  $IVC ls -al /usr/share/zabbix/navis/upload/upload6/ 2>/dev/null | wc -l) 
    replica=$(timeout 5 sshpass -e ssh  $IVC ls -alR /usr/share/zabbix/navis/replica/ | grep chunk | wc -l)
    if [ "$replica" == "" ]; then replica=-1; fi
    let a=a-3
    let b=b-3
    let c=c-3
    let d=d-3
    let e=e-3
    let f=f-3
    let s=a+b+c+d+e+f
    echo "$s" > /tmp/$p/tmp/qos_queue.txt
    if [ "$s" == "" ]; then s=-1; fi
    foo $s IVC QUEUE
    echo "$replica" > /tmp/$p/tmp/qos_replica.txt
    foo $replica IVC REPLICA 
    #echo -n "."
    
    uptime=$(timeout 5 sshpass -e ssh  $IVC uptime | awk '{gsub(",","");print $(NF-2),$(NF-1),$(NF)'})
    echo $uptime | awk '{print $1}' >  /tmp/$p/tmp/ivc-uptime05.txt
    echo $uptime | awk '{print $2}' >  /tmp/$p/tmp/ivc-uptime10.txt
    echo $uptime | awk '{print $3}' >  /tmp/$p/tmp/ivc-uptime15.txt
    uptime=$(timeout 5 sshpass -e ssh  $IVC_MYSQL "uptime" | awk '{gsub(",","");print $(NF-2),$(NF-1),$(NF)'})
    echo $uptime | awk '{print $1}' >  /tmp/$p/tmp/mysql-uptime05.txt
    echo $uptime | awk '{print $2}' >  /tmp/$p/tmp/mysql-uptime10.txt
    echo $uptime | awk '{print $3}' >  /tmp/$p/tmp/mysql-uptime15.txt
    #echo "."
    servercpu $IVC IVC 
    servercpu $IVC_MYSQL IVC_MYSQL
    servercpu $EES_CLOUD_MYSQL EES_MYSQL
    servercpu $EES_CLOUD_NF EES_NETFLOW
    #ervercpu $EES_CLOUD_NF2056
    servercpu $EES_CLOUD_NF2055 EES_NF2055
    servercpu $EES_CLOUD_POST1 EES_POST
    servercpu $EES_CLOUD_WS1 EES_WS
    servercpu $EES_CLOUD_DEVEL EES_DEVEL
    servercpu $EES_CLOUD_DNS1 EES_DNS
    
    #echo  "MYSQL PROC"
    v=$(timeout 10 echo "SHOW processlist" | mysql --defaults-extra-file=/home/deck/.local.cfg  -h MYSQL 2>&1 |  wc -l)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    echo $v  > /tmp/$p/tmp/mysql-processlist.txt
    foo $v MYSQLIVCLOCAL MYSQLPL
    v=$(timeout 10 echo "SHOW processlist" | mysql --defaults-extra-file=/home/deck/.ivc.cfg  -h $IVC_MYSQL 2>&1 | wc -l)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    echo $v  > /tmp/$p/tmp/cloud_IVC_MYSQL-processlist.txt
    foo $v MYSQLIVC MYSQLPL
    v=$(timeout 10 echo "SHOW processlist" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.50  2>&1 | wc -l)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/cloud_DEVEL_CLOUD_MYSQL-processlist.txt
    foo $v MYSQLDEVEL MYSQLPL
    v=$(timeout 15 echo "SHOW processlist" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9  2>&1 | wc -l)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/cloud_EES_CLOUD_MYSQL-processlist.txt
    foo $v MYSQLEES MYSQLPL
    v=$(timeout 15 echo "SHOW processlist" | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44  2>&1 | wc -l)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/ingbell_mysql-processlist.txt
    foo $v MYSQLINGBELL MYSQLPL
    v=$(timeout 15 echo "SHOW processlist" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h $EES_CLOUD_INGBELL 2>&1 | wc -l)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    echo $v  > /tmp/$p/tmp/cloud_EES_INGBELL_MYSQL-processlist.txt
    foo $v CLOUDMYSQLINGBELL MYSQLPL

    v=$(timeout 10 echo "SELECT count(*) as cnt  FROM syslogng.logs where facility='user' and datetime> date_add(now(),interval -1 hour) and msg like '%WIFI: IDEN %'" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    fooreplace $v HOTSPOT WIFI

    v=$(timeout 10 echo "SELECT count(*) as cnt FROM HOTSPOT.login where updated> date_add(now(),interval -1 hour) and mac is not null and logout is not null" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    fooreplace $v HOTSPOT LOGIN

    v=$(timeout 10 echo " SELECT count(*) FROM HOTSPOT.iden where id <> 897704 and updated> date_add(now(),interval -4 hour)" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "1" ]; then v=-1; fi
    fooreplace $v HOTSPOT AVAILABILITY

    v=$(timeout 10 echo " select round(sum(inter)/1000/1000,0) as s from ISP_VTR.rx_tx  where datetime>=from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(now(),INTERVAL 0 MINUTE))/(60*60))*(60*60)))" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    fooreplace $v VTR INTDOWN

    v=$(timeout 10 echo " select round(sum(inter)/1000/1000,0) as s from ISP_CTVC.rx_tx  where datetime>=from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(now(),INTERVAL 0 MINUTE))/(60*60))*(60*60)))" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    fooreplace $v CTVC INTDOWN

    v=$(timeout 10 echo " select round(sum(inter)/1000/1000,0) as s from ISP_MI_INTERNET.rx_tx  where datetime>=from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(now(),INTERVAL 0 MINUTE))/(60*60))*(60*60)))" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    fooreplace $v MI INTDOWN

    #echo  "IVC"

    tm=$(timeout 5 sshpass -e ssh  $IVC ls -al --time-style=+%s /var/log/zuceso.log | awk '{print $6}')
    v=$(echo $(date +%s) $tm | awk '{print $1-$2}')
    if [ "$v" == "" ]; then v=-1; fi
    timeout 5 sshpass -e ssh $IVC tail -100 /var/log/zuceso.log | grep processed | tail -1  | awk '{print $5,$9,$10,"s<br>",$1,$2}' > /tmp/navis-post.txt
    timeout 5 sshpass -e ssh $IVC tail -100 /var/log/zuceso.log | grep processed | tail $LINES  | awk '{print $1,$2,$5,$9,$10,"s<br>"}' > /tmp/nvtxt.txt
    foo $v IVC NAVISPOST
    footxt /tmp/nvtxt.txt IVC NAVISPOST
    mv /tmp/navis-post.txt /tmp/$p/tmp/navis-post.txt
    
    tm=$(timeout 5 sshpass -e ssh $IVC ls -al --time-style=+%s /var/log/ivcserver.log | awk '{print $6}')
    v=$(echo $(date +%s) $tm | awk '{print $1-$2}')
    timeout 5 sshpass -e ssh $IVC tail -1000 /var/log/ivcserver.log | grep postlong  | grep Processed  | awk 'BEGIN{a=0}{a=a+$8}END{print a,"<br>",$1,$2}' > /tmp/neutralidad-post.txt
    timeout 5 sshpass -e ssh $IVC tail -1000 /var/log/ivcserver.log | grep postlong  | grep Processed  | tail $LINES | awk '{print $1,$2,"P:"$4,"F:"$6,"T:"$8"<br>"}' > /tmp/itxt.txt
    if [ "$v" == "" ]; then v=-1; fi
    foo $v IVC IVCPOST
    footxt /tmp/itxt.txt IVC IVCPOST
    mv /tmp/neutralidad-post.txt  /tmp/$p/tmp/neutralidad-post.txt

    #tm=$(timeout 5  sshpass -e ssh  $EES_CLOUD_NF ls -al --time-style=+%s /var/log/netacc.log | awk '{print $6}')
    #v=$(echo $(date +%s) $tm | awk '{print $1-$2}')
    #timeout 10 sshpass -e ssh $EES_CLOUD_NF cat /var/log/netacc.log | grep Process  | tail $LINES | sort -r | awk '{print $1,$2,$4,$5,$7,$8,$9,$10,$11,"<br>"}' > /tmp/netacc.txt
    #foo $v CLOUDEES NETACC
    #footxt /tmp/netacc.txt CLOUDEES NETACC
    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2057 cat /var/log/netacc.log | grep Process | grep "$dt" | awk 'BEGIN{s=0}{s=s+$4}END{print s}')
    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2057 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$16}END{print s}')
    #if [ "$v" == "" ]; then v=-1; fi
    #fooreplace $v CLOUDEES2057 NETACC

    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2057 'for i in $(seq 2055 2057); do a=$(ls -al /var/log/pre/$i/ 2>/dev/null| wc -l);let a=a-3;  echo $a; done'  | awk 'BEGIN {s=0}{s=s+$1}END{print s}')
    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2057 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$20}END{print s}')
    #if [ "$v" == "" ]; then v=-1; fi
    #fooreplace $v CLOUDEES2057 NETACCTAIL

    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2056 cat /var/log/netacc.log | grep Process | grep "$dt" | awk 'BEGIN{s=0}{s=s+$4}END{print s}')
    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2056 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$16}END{print s}')
    #if [ "$v" == "" ]; then v=-1; fi
    #fooreplace $v CLOUDEES2056 NETACC

    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2056 'for i in $(seq 2055 2057); do a=$(ls -al /var/log/pre/$i/ 2>/dev/null| wc -l);let a=a-3;  echo $a; done'  | awk 'BEGIN {s=0}{s=s+$1}END{print s}')
    #v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2056 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$20}END{print s}')
    #if [ "$v" == "" ]; then v=-1; fi
    #fooreplace $v CLOUDEES2056 NETACCTAIL

    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2055 cat /var/log/netacc.log | grep Process | grep "$dt" | awk 'BEGIN{s=0}{s=s+$4}END{print s}')
    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2055 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$16}END{print s}')
    # if [ "$v" == "" ]; then v=-1; fi
    # fooreplace $v CLOUDEES2055 NETACC

    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2055 'for i in $(seq 2055 2057); do a=$(ls -al /var/log/pre/$i/ 2>/dev/null| wc -l);let a=a-3;  echo $a; done'  | awk 'BEGIN {s=0}{s=s+$1}END{print s}')
    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2055 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$20}END{print s}')
    # if [ "$v" == "" ]; then v=-1; fi
    # fooreplace $v CLOUDEES2055 NETACCTAIL

    # #EES_CLOUD_DNS1
    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_DNS1 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$16}END{print s}')
    # if [ "$v" == "" ]; then v=-1; fi
    # fooreplace $v CLOUDEES2055 NETACC

    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_NF2055 'for i in $(seq 2055 2057); do a=$(ls -al /var/log/pre/$i/ 2>/dev/null| wc -l);let a=a-3;  echo $a; done'  | awk 'BEGIN {s=0}{s=s+$1}END{print s}')
    # v=$(timeout 10 sshpass -e ssh $EES_CLOUD_DNS1 cat /var/log/t-netflow.log | grep FLUSHED | grep "$dt" | awk 'BEGIN{s=0}{s=s+$20}END{print s}')
    # if [ "$v" == "" ]; then v=-1; fi
    # fooreplace $v CLOUDEES2055 NETACCTAIL

    # timeout 5 sshpass -e ssh $IVC_ETL "tail -1000 /var/log/zuceso.log" | grep copy.php | tail -1 | awk '{print $9,$10,"<br>",$11,$12,"<br>",$13,$14,"<br>",$15,$16,"<br>",$1,$2}' > /tmp/neutralidad-copy.txt
    # mv /tmp/neutralidad-copy.txt /tmp/$p/tmp/neutralidad-copy.txt
    # timeout 5 sshpass -e ssh $IVC_ETL "tail -1000 /var/log/ivcserver.log" | grep etl | tail -1 | awk '{print $5,"<br>",$6,"<br>",$7,"<br>",$8,"<br>",$9,"<br>",$1,$2}' > /tmp/neutralidad-etl.txt
    # mv /tmp/neutralidad-etl.txt /tmp/$p/tmp/neutralidad-etl.txt

    disk $IVC_MYSQL IVC_MYSQL
    disk $EES_CLOUD_MYSQL EES_MYSQL 
    #disk $EES_CLOUD_NF2057
    #disk $EES_CLOUD_NF2056
    disk $EES_CLOUD_NF2055 EES_NF2055
    disk $EES_CLOUD_POST1 EES_POST
    disk $EES_CLOUD_WS1 EES_WS
    disk $EES_CLOUD_ETL EES_ETL
    disk $EES_CLOUD_WEB EES_WEB
    disk $EES_CLOUD_DNS1 EES_DNS
    ##disk $EES_CLOUD_DNS2
    ##disk $EES_CLOUD_DNS2
    disk $IVC IVC
    disk $IVC_ETL IVC_ETL
    disk $HOTSPOT HOTSPOT
    disk $EES_CLOUD_DEVEL EES_DEVEL

    #echo "."
    # WS SAGEC
    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_VTR.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response="33 OK"' | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/sagec_vtr.txt
    foo $v VTR SAGEC
    echo "SELECT datetime,sagec_response,count(*) as ees FROM ISP_VTR.rx_tx where datetime >= DATE_ADD(now(), interval -120 minute) and sagec_response is not null group by datetime,sagec_response order by 1 desc" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | awk '{print $0,"<br>";}' | grep -v datetime | head $LINES > /tmp/sagec_ws.txt 
    footxt /tmp/sagec_ws.txt  VTR SAGEC 

    if [ $v -le 0 ] ; then
        telegram SAGECWS-VTR "SAGECWS VTR $v"
    else 
        telegram SAGECWS-VTR "SAGEGWS VTR $v [OK]" CLR
    fi

    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_VTR.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response<>"33 OK"' | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    fooreplace $v VTR SAGECERROR

    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_MI_INTERNET.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response="33 OK"' | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/sagec_mi.txt
    foo $v MI_INTERNET SAGEC
    echo "SELECT datetime,sagec_response,count(*) as ees FROM ISP_MI_INTERNET.rx_tx where datetime >= DATE_ADD(now(), interval -120 minute) and sagec_response is not null group by datetime,sagec_response order by 1 desc" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | awk '{print $0,"<br>";}' | grep -v datetime | head $LINES > /tmp/sagec_ws.txt 
    footxt /tmp/sagec_ws.txt  MI_INTERNET SAGEC 

    if [ $v -le 0 ] ; then
        telegram SAGECWS-MI "SAGECWS MI $v"
    else 
        telegram SAGECWS-MI "SAGEGWS MI $v [OK]" CLR
    fi
    
    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_MI_INTERNET.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response<>"33 OK"' | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ] ; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    fooreplace $v MI_INTERNET SAGECERROR


    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_CTVC.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response="33 OK"' | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/sagec_ctvc.txt
    foo $v CTVC SAGEC
    echo "SELECT datetime,sagec_response,count(*) as ees FROM ISP_CTVC.rx_tx where datetime >= DATE_ADD(now(), interval -120 minute) and sagec_response is not null group by datetime,sagec_response order by 1 desc" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | awk '{print $0,"<br>";}' | grep -v datetime | head $LINES > /tmp/sagec_ws.txt 
    footxt /tmp/sagec_ws.txt  CTVC SAGEC

    if [ $v -le 0 ] ; then
        telegram SAGECWS-CTVC "SAGECWS CTVC $v"
    else 
        telegram SAGECWS-CTVC "SAGEGWS CTVC $v [OK]" CLR
    fi

    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_CTVC.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response<>"33 OK"' | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    fooreplace $v CTVC SAGECERROR


    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_INGBELL.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response="33 OK"' | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 zoftcom  2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/sagec_ingbell.txt
    foo $v INGBELL SAGEC
    echo "SELECT datetime,sagec_response,count(*) as ees FROM ISP_INGBELL.rx_tx where datetime >= DATE_ADD(now(), interval -120 minute) and sagec_response is not null group by datetime,sagec_response order by 1 desc" | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 zoftcom  2>&1 | awk '{print $0,"<br>";}' | grep -v datetime | head $LINES > /tmp/sagec_ws.txt 
    footxt /tmp/sagec_ws.txt  INGBELL SAGEC

    if [ $v -le 0 ] ; then
        telegram SAGECWS-INGBELL "SAGECWS INGBELL $v (Puedría ser problema de VPN)"
    else 
        telegram SAGECWS-INGBELL "SAGEGWS INGBELL $v [OK]" CLR
    fi

    v=$(timeout 10 echo 'SELECT count(*)  FROM ISP_INGBELL.rx_tx,zoftcom.ees,zoftcom.isp where rx_tx.datetime>=ees.fechainstalacion and ees.fechainstalacion is not null and ees.fechabaja is null  and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and  datetime >=  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -65 minute))/(60*15))*(60*15))) and sagec_sent is not null and sagec_response<>"33 OK"' | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 zoftcom  2>&1 | tail -1 | awk '{print $1}')
    if [ "$v" == "" ]; then v=-1; fi
    if [ "$v" == "ERROR" ]; then v=-1; fi
    echo $v > /tmp/$p/tmp/sagec_ingbell.txt
    fooreplace $v INGBELL SAGECERROR

    v=$(timeout 10 echo " select round(sum(inter)/1000/1000,0) as s from ISP_INGBELL.rx_tx  where datetime>=from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(now(),INTERVAL 0 MINUTE))/(60*60))*(60*60)))" | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 2>&1 | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    fooreplace $v INGBELL INTDOWN

    
    #echo "."

    export SSHPASS=NyayknRAyafVVWhFtR5j
    disk $INGBELL_NF INGBELL_NF
    disk $INGBELL_WS INGBELL_WS
    disk $INGBELL_MYSQL INGBELL_MYSQL
    disk $INGBELL_DNS1 INGBELL_DNS1 
    disk $INGBELL_DNS2 INGBELL_DNS2
    disk $INGBELL_ETL INGBELL_ETL

    dt=$(date -d '5 minute ago' "+%Y-%m-%d %H")
    
    timeout 5 sshpass -e ssh $INGBELL_MYSQL find /home/backup -mtime -1 -ls | grep sql | grep -v "dns\|domain\|month\|ping\|rx_tx\|rx-tx" | awk '{gsub("/home/backup/","");print $8,$9,$10,$11,"<br>"}' > /tmp/$p/tmp/bkpees.txt
    a=$(cat /tmp/$p/tmp/bkpees.txt| wc -l)
    if [ "$a" == "" ]; then a=-1; fi
    foo $a INGBELL BACKUP
    footxt /tmp/$p/tmp/bkpees.txt INGBELL BACKUP

    v=$(timeout 15 sshpass -e ssh $INGBELL_NF cat /var/log/netacc.log | grep Process | grep "$dt" | awk 'BEGIN{s=0}{s=s+$4}END{print s}')
    if [ "$v" == "" ]; then v=-1; fi
    fooreplace $v INGBELL NETACC
     
    v=$(timeout 10 sshpass -e ssh $INGBELL_DNS1 cat /var/log/dnsparse.log | grep logfile | grep "^$dt" | awk '{print $8}' | grep queries | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL DNS1

    v=$(timeout 10 sshpass -e ssh $INGBELL_DNS2 cat /var/log/dnsparse.log | grep logfile | grep "^$dt" | awk '{print $8}' | grep queries | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL DNS2

    v=$(timeout 10 sshpass -e ssh $INGBELL_DNS1 cat /var/log/dnsparse.log | grep "log-file" | grep "^$dt" | awk '{print $8}' | grep consultas | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL T-DNS1

    v=$(timeout 10 sshpass -e ssh $INGBELL_DNS2 cat /var/log/dnsparse.log | grep "log-file" | grep "^$dt" | awk '{print $8}' | grep consultas | awk 'BEGIN{sum=0;FS=":"}{sum=sum+$2}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL T-DNS2

    v=$(timeout 10 sshpass -e ssh $INGBELL_NF cat /var/log/expire.log | grep "DONE" | grep "^$dt" | grep dns | awk 'BEGIN{sum=0}{sum=sum+$7}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL EXPIRE-DNS

    v=$(timeout 10 sshpass -e ssh $INGBELL_NF cat /var/log/expire.log | grep "DONE" | grep "^$dt" | grep -v dns | awk 'BEGIN{sum=0}{sum=sum+$6}END{print sum}')
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL EXPIRE-RXTX

    v=$(timeout 10 sshpass -e ssh $INGBELL_NF cat /var/log/expire.log | grep "ERROR" | grep "^$dt" | grep dns | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL EXPIRE-DNS-ERROR

    v=$(timeout 10 sshpass -e ssh $INGBELL_NF cat /var/log/expire.log | grep "ERROR" | grep "^$dt" | grep rx_tx | wc -l)
    if [ "$v" == "" ] ; then v=-1; fi
    fooreplace $v INGBELL EXPIRE-RXTX-ERROR

    v=$(echo "SELECT count(*) as cnt FROM ISP_VTR.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx_tx.inter=0 and rx>0 " | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v VTR NETFLOW
    v=$(echo "SELECT count(*) as cnt FROM ISP_MI_INTERNET.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx_tx.inter=0 and rx>0" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v MI_INTERNET NETFLOW
    v=$(echo "SELECT count(*) as cnt FROM ISP_CTVC.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx_tx.inter=0 and rx>0" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v CTVC NETFLOW
    v=$(echo "SELECT count(*) as cnt FROM ISP_INGBELL.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx_tx.inter=0 and rx>0" | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v INGBELL WS1

    v=$(echo "SELECT count(*) as cnt FROM ISP_INGBELL.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx_tx.inter=0 and rx>0" | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v INGBELL NETFLOW

    v=$(echo "SELECT count(*) as cnt FROM ISP_VTR.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx=0" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v VTR NODATA
    v=$(echo "SELECT count(*) as cnt FROM ISP_MI_INTERNET.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx=0" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v MI_INTERNET NODATA
    v=$(echo "SELECT count(*) as cnt FROM ISP_CTVC.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx=0" | mysql --defaults-extra-file=/home/deck/.ees.cfg  -h 192.168.33.9 zoftcom  2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v CTVC NODATA
    v=$(echo "SELECT count(*) as cnt FROM ISP_INGBELL.rx_tx,zoftcom.ees,zoftcom.isp  where ees.fechainstalacion is not null and ees.fechabaja is null and ees.fechainstalacion <= now() and rx_tx.ees=zoftcom.ees.rbd and isp.id=ees.idisp and datetime =  from_unixtime(round(FLOOR(unix_timestamp(DATE_ADD(NOW(),INTERVAL -15 MINUTE))/(60*15))*(60*15)))  and rx=0" | mysql --defaults-extra-file=/home/deck/.ingbell.cfg  -h 192.168.201.44 zoftcom 2>>null | tail -1)
    if [ "$v" == "" ]; then v=-1; fi
    foo $v INGBELL NODATA

    v=$(timeout 15 sshpass -e ssh $INGBELL_NF cat /var/log/post.log 2>&1 | grep ssh | wc -l )

    if [ "$v" == "0" ] ; then 
       v=$(timeout 10 sshpass -e ssh $INGBELL_NF cat /var/log/post.log | grep "$dt" | wc -l)
       if [ "$v" == "" ] ; then v=-1; fi
    else 
       v=-1
    fi
    fooreplace $v INGBELL POST

    v=$(timeout 15 sshpass -e ssh $INGBELL_WS cat /var/log/ws.log 2>&1 | grep ssh |  wc -l)
    if [ "$v" == "0" ] ; then 
       v=$(timeout 10 sshpass -e ssh $INGBELL_WS cat /var/log/ws.log | grep "$dt" | grep slot | grep -v FINISH |  wc -l)
       if [ "$v" == "" ] ; then v=-1; fi
    else 
       v=-1
    fi
    fooreplace $v INGBELL WS

    v=$(timeout 15 sshpass -e ssh $INGBELL_WS cat /var/log/ws.log 2>&1 | grep ssh |  wc -l)
    if [ "$v" == "0" ] ; then 
       v=$(timeout 10 sshpass -e ssh $INGBELL_WS cat /var/log/ws.log | grep "$dt" | grep -v FINISH | grep slot | grep -v "33 OK\|: 33-"  |  wc -l)
       if [ "$v" == "" ] ; then v=-1; fi
    else 
       v=-1
    fi
    fooreplace $v INGBELL WS33NOOK

    timeout 10 wget --timeout 10 -q -O /tmp/perf.txt "http://192.168.33.7/perf.txt"
    dos2unix /tmp/perf.txt
    a=$(cat /tmp/perf.txt  | grep DISKSizeRemaining | awk '{printf "%.2f",$2/1024/1024/1024}')
    if [ "$a" == "" ] ; then  a=-1; fi
    fooreplace $a $MSSQL DISKC

    a=$(cat /tmp/perf.txt  | grep MEM | awk '{printf "%.2f",$2/1024}')
    if [ "$a" == "" ] ; then  a=-1; fi
    fooreplace $a $MSSQL MEM
    
    a=$(cat /tmp/perf.txt  | grep CPU | awk '{printf "%.2f",$2}')
    if [ "$a" == "" ] ; then  a=-1; fi
    fooreplace $a $MSSQL CPU


    #timeout 10 wget --timeout 10 -q -O /tmp/perf.txt "http://192.168.44.76/perf.txt"
    #dos2unix /tmp/perf.txt
    #a=$(cat /tmp/perf.txt  | grep DISKSizeRemaining | awk '{printf "%.2f",$2/1024/1024/1024}')
    #if [ "$a" == "" ] ; then  a=-1; fi
    #fooreplace $a $R510 DISKC

    #a=$(cat /tmp/perf.txt  | grep MEM | awk '{printf "%.2f",$2/1024}')
    #if [ "$a" == "" ] ; then  a=-1; fi
    #fooreplace $a $R510 MEM
    
    #a=$(cat /tmp/perf.txt  | grep CPU | awk '{printf "%.2f",$2}')
    #if [ "$a" == "" ] ; then  a=-1; fi
    #fooreplace $a $R510 CPU

    #STORAGE
    curl -s -q -o /tmp/md3200.01.txt http://192.168.44.55/MD3200-01.txt
    curl -s -q -o /tmp/md3200.02.txt http://192.168.44.55/MD3200-02.txt
    status1=$(cat /tmp/md3200.01.txt  | grep "Storage array health status" | awk 'BEGIN{FS="="}{gsub("\\.","");print substr($2,2,length($2)-2)}')
    status2=$(cat /tmp/md3200.02.txt  | grep "Storage array health status" | awk 'BEGIN{FS="="}{gsub("\\.","");print substr($2,2,length($2)-2)}')
   
    if [ "$status1" != "optimal" ] && [ "$status1" != "fixing" ] ; then 
        status1=$(cat /tmp/md3200.01.txt  | grep "Component reporting problem" | awk '{gsub("Component reporting problem: ","");print "Fail",$1,$2,$5}')
    else 
        telegram MD3200-01-STATUS "MD3200-01 [HP] : $status1 [OK]" CLR
    fi
    if [ "$status2" != "optimal" ] && [ "$status2" != "fixing" ] ; then 
        status2=$(cat /tmp/md3200.02.txt | grep "Component reporting problem" | awk '{gsub("Component reporting problem: ","");print "Fail",$1,$2,$5}')
    else 
        telegram MD3200-02-STATUS "MD3200-02 [DELL] : $status2 [OK]" CLR
    fi
    
    echo "MD3200-01 [HP]  : $status1<br>" >  /tmp/md.txt    
    echo "MD3200-02 [DELL]: $status2"    >>  /tmp/md.txt 
    n=$(cat /tmp/md.txt | wc -l)
    no=$(cat /tmp/md.txt | grep -v optimal | wc -l)
    let v=n-no
    fooreplace $v  MD3200 STATUS
    footxt /tmp/md.txt MD3200 STATUS

    cat /tmp/md3200.01.txt | grep "VDISK\|SSD" | grep Host | awk '{if ($4 = "Optimal") print $1,$4,"<br>"; else print $1,$4," !!!! <br>";}' > /tmp/md.txt
    n=$(cat /tmp/md.txt | wc -l)
    no=$(cat /tmp/md.txt | grep "!!!" | wc -l)
    let v=n-no
    fooreplace $v MD3200-01 VDISK
    footxt /tmp/md.txt MD3200-01 VDISK

    cat /tmp/md3200.02.txt | grep "VDISK\|SSD" | grep Host | awk '{if ($4 = "Optimal") print $1,$4,"<br>"; else print $1,$4," !!!! <br>";}' > /tmp/md.txt
    n=$(cat /tmp/md.txt | wc -l)
    no=$(cat /tmp/md.txt | grep "!!!" | wc -l)
    let v=n-no
    fooreplace $v MD3200-02 VDISK
    footxt /tmp/md.txt MD3200-02 VDISK

    curl -s -q http://192.168.44.55/csvfs.txt | grep CSVFS | grep "CLUSTER-DELL" | sort | awk 'BEGIN{FS=","}{gsub("\"","");if ($7/$6*100 < 12) printf("%-12s=>%8.2f %8.2f %6.2f%% FREE !!!!<br>\n",$3,$6/1000/1000/1000,$7/1000/1000/1000,$7/$6*100); else printf("%-12s=>%8.2f %8.2f %6.2f%% FREE<br>\n",$3,$6/1000/1000/1000,$7/1000/1000/1000,$7/$6*100)}' > /tmp/DELL-SPACE.txt
    n=$(cat /tmp/DELL-SPACE.txt |  wc -l)
    no=$(cat /tmp/DELL-SPACE.txt |  grep "!!" | wc -l)
    let v=n-no
    fooreplace $v MD3200-02 SPACE
    footxt /tmp/DELL-SPACE.txt MD3200-02 SPACE

    curl -s -q http://192.168.44.55/csvfs.txt | grep CSVFS | grep "CLUSTER-HP" | sort | awk 'BEGIN{FS=","}{gsub("\"","");if ($7/$6*100 < 12) printf("%-12s=>%8.2f %8.2f %6.2f%% FREE !!!!<br>\n",$3,$6/1000/1000/1000,$7/1000/1000/1000,$7/$6*100); else printf("%-12s=>%8.2f %8.2f %6.2f%% FREE<br>\n",$3,$6/1000/1000/1000,$7/1000/1000/1000,$7/$6*100)}' > /tmp/HP-SPACE.txt
    n=$(cat /tmp/HP-SPACE.txt |  wc -l)
    no=$(cat /tmp/HP-SPACE.txt |  grep "!!" | wc -l)
    let v=n-no
    fooreplace $v MD3200-01 SPACE
    footxt /tmp/HP-SPACE.txt MD3200-01 SPACE

    cat /tmp/md3200.01.txt | grep "Host Group" | grep -v QUORUM | awk '{if ($4 = "Optimal") print $1,$4,$5,$6"<br>"; else print $1,$4,$5,$6" !!!!<br>";}' > /tmp/HP-SPACE.txt
    n=$(cat /tmp/HP-SPACE.txt | wc -l)
    no=$(cat /tmp/HP-SPACE.txt | grep "!!!" | wc -l)
    let v=n-no
    fooreplace $v MD3200-01 STATUS
    footxt /tmp/HP-SPACE.txt MD3200-01 STATUS

    cat /tmp/md3200.02.txt | grep "Host Group" | grep -v QUORUM | awk '{if ($4 = "Optimal") print $1,$4,$5,$6"<br>"; else print $1,$4,$5,$6" !!!!<br>";}' > /tmp/DELL-SPACE.txt
    n=$(cat /tmp/DELL-SPACE.txt | wc -l)
    no=$(cat /tmp/DELL-SPACE.txt | grep "!!!" | wc -l)
    let v=n-no
    fooreplace $v MD3200-02 STATUS
    footxt /tmp/DELL-SPACE.txt MD3200-02 STATUS

    # FAILED DISK
    cat /tmp/md3200.01.txt  | grep "SAS" | grep -v Slot | grep -v Serial | grep -v Optimal | awk '{print "Disk "$2,$3,$4" GB !!!<br>"}' > /tmp/md3200.01.disk.txt
    n=24
    no=$(cat /tmp/md3200.01.disk.txt | wc -l)
    if [ $no -eq 0 ] ; then
        echo "24 super duper disks OK<br>" > /tmp/md3200.01.disk.txt
    else 
        curl -s -q http://192.168.44.55/MD3200-01V1.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
        curl -s -q http://192.168.44.55/MD3200-01V2.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
        curl -s -q http://192.168.44.55/MD3200-01V3.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
        curl -s -q http://192.168.44.55/MD3200-01V4.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
        curl -s -q http://192.168.44.55/MD3200-01V5.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
        curl -s -q http://192.168.44.55/MD3200-01V6.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
        curl -s -q http://192.168.44.55/MD3200-01V7.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.01.disk.txt
    fi
    for i in $(seq 1 7) ; do 
        nx=$(curl -s -q http://192.168.44.55/MD3200-01.V0$i.task.txt | grep "No action in progress" | wc -l)
        if [ $nx -ne 1 ] ; then 
            curl -s -q -o /tmp/task.txt http://192.168.44.55/MD3200-01.V0$i.task.txt  
            dos2unix  /tmp/task.txt
            cat /tmp/task.txt | awk '{print "<br><span#style=\"font-weight:600;\">"$0"</span>"}' >> /tmp/md3200.01.disk.txt
        fi 
    done 
    let v=n-no
    fooreplace $v MD3200-01 DISK
    footxt /tmp/md3200.01.disk.txt MD3200-01 DISK

    cat /tmp/md3200.02.txt  | grep "SAS" | grep -v Slot | grep -v Serial | grep -v Optimal | awk '{print "Disk "$2,$3,$4" GB !!!<br>"}' > /tmp/md3200.02.disk.txt
    n=24
    no=$(cat /tmp/md3200.02.disk.txt | wc -l)
    if [ $no -eq 0 ] ; then
        echo "24 super duper disks OK<br>" > /tmp/md3200.02.disk.txt
    else 
        curl -s -q http://192.168.44.55/MD3200-02V1.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
        curl -s -q http://192.168.44.55/MD3200-02V2.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
        curl -s -q http://192.168.44.55/MD3200-02V3.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
        curl -s -q http://192.168.44.55/MD3200-02V4.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
        curl -s -q http://192.168.44.55/MD3200-02V5.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
        curl -s -q http://192.168.44.55/MD3200-02V6.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
        curl -s -q http://192.168.44.55/MD3200-02V7.txt | grep "hot spare" | awk '{gsub("]","");print "Disk "$2" sparing Disk "$14}' >> /tmp/md3200.02.disk.txt
    fi
    for i in $(seq 1 7) ; do 
        nx=$(curl -s -q http://192.168.44.55/MD3200-02.V0$i.task.txt | grep "No action in progress" | wc -l)
        if [ $nx -ne 1 ] ; then 
            curl -s -q -o /tmp/task.txt http://192.168.44.55/MD3200-02.V0$i.task.txt  /tmp/task.txt
            dos2unix  /tmp/task.txt
            cat /tmp/task.txt | awk '{print "<br><span#style=\"font-weight:600;\">"$0"</span>"}' >> /tmp/md3200.02.disk.txt
        fi 
    done 
    let v=n-no
    fooreplace $v MD3200-02 DISK
    footxt /tmp/md3200.02.disk.txt MD3200-02 DISK

    MD="MD3200-01"
    curl -s -q -o /tmp/MD3200-01.events.txt "http://192.168.44.55/$MD.events.txt" 
    dos2unix /tmp/$MD.events.txt 
    touch /tmp/$MD.last-event.txt 
    last=$(cat /tmp/$MD.last-event.txt)
    # ev=$(cat /tmp/$MD.events.txt | grep -v 00 | grep -v Raw | head -2 | tail -1 | awk '{print $3}')
    ev=$(cat /tmp/$MD.events.txt | grep -v 00 | grep -v Raw | awk '{if ($1=="Logged") print ""; else printf("%s ",$0);}' | grep -v "Battery fully charged" | grep -v "Media scan started Virtual Disk " | grep -v "Media scan completed Virtual Disk" | head -1 | awk '{print $7}')
    if [ "$ev" != "$last" ] ; then
        echo $ev > /tmp/$MD.last-event.txt
        cat /tmp/$MD.events.txt | awk '{if ($1=="Date/Time:") printf("%s: ",$0); if ($2=="category:") printf("%s ",$3); if ($1=="Description:") printf("%s ",$0); if ($1=="Priority:") printf("%s ",$0); if ($2=="location:") printf("%s ",$0); if ($1=="Logged") printf("[C%s]",$8); if ($1=="Raw") print "";}' | awk '{gsub("Date/Time: ","");gsub("Description: ","");gsub("location: ","");gsub("Component ","");gsub("Priority: ","");print $0}' | awk 'BEGIN{FS="/";print "EVENTOS STORAGE MD3200-01 [DELL]\n------------------------------------------------------";}{m=$1;d=$2;if (m<10) m="0"m;if (d<10) d="0"d;print "20" substr($3,1,2)"/"m"/"d,substr($3,4)}' > /tmp/$MD.e.txt
        txt=$(cat /tmp/$MD.e.txt | awk 'BEGIN{print "<!DOCTYPE html><span style=\"font-size:12px;\">";}{gsub("Failure","<span style=\"color:red;font-weight:600;\">Failure</span>");gsub("Error","<span style=\"color:red;font-weight:600;\">Error</span>");print $0"<br>";}END{print "</span>";}' )
        sendemail -f "<reportes@zoftcom.com>" -t "andres@zoftcom.com;rodrigo@zoftcom.com" -s smtp.office365.com:587  -u "EVENTS MD3200-01" -m "$txt"  -v -xu reportes@zoftcom.com   -xp Zc0m#2021_ -o
    fi

    MD="MD3200-02"
    curl -s -q -o /tmp/$MD.events.txt "http://192.168.44.55/$MD.events.txt"
    dos2unix /tmp/$MD.events.txt
    touch /tmp/$MD.last-event.txt 
    last=$(cat /tmp/$MD.last-event.txt)
    # ev=$(cat /tmp/$MD.events.txt | grep -v 00 | grep -v Raw | head -2 | tail -1 | awk '{print $3}')
    ev=$(cat /tmp/$MD.events.txt | grep -v 00 | grep -v Raw | awk '{if ($1=="Logged") print ""; else printf("%s ",$0);}' | grep -v "Battery fully charged" | grep -v "Media scan started Virtual Disk " | grep -v "Media scan completed Virtual Disk" | head -1 | awk '{print $7}')
    if [ "$ev" != "$last" ] ; then
        echo $ev > /tmp/$MD.last-event.txt
        cat /tmp/$MD.events.txt | awk '{if ($1=="Date/Time:") printf("%s: ",$0); if ($2=="category:") printf("%s ",$3); if ($1=="Description:") printf("%s ",$0); if ($1=="Priority:") printf("%s ",$0); if ($2=="location:") printf("%s ",$0); if ($1=="Logged") printf("[C%s]",$8); if ($1=="Raw") print "";}' | awk '{gsub("Date/Time: ","");gsub("Description: ","");gsub("location: ","");gsub("Component ","");gsub("Priority: ","");print $0}' | awk 'BEGIN{FS="/";print "EVENTOS STORAGE MD3200-02 [DELL]\n------------------------------------------------------";}{m=$1;d=$2;if (m<10) m="0"m;if (d<10) d="0"d;print "20" substr($3,1,2)"/"m"/"d,substr($3,4)}' > /tmp/$MD.e.txt
        txt=$(cat /tmp/$MD.e.txt | awk 'BEGIN{print "<!DOCTYPE html><span style=\"font-size:12px;\">";}{gsub("Failure","<span style=\"color:red;font-weight:600;\">Failure</span>");gsub("Error","<span style=\"color:red;font-weight:600;\">Error</span>");print $0"<br>";}END{print "</span>";}')
        sendemail -f "<reportes@zoftcom.com>" -t "andres@zoftcom.com;rodrigo@zoftcom.com" -s smtp.office365.com:587  -u "EVENTS MD3200-02" -m "$txt"  -v -xu reportes@zoftcom.com   -xp Zc0m#2021_ -o
    fi
    
    touch /tmp/replica.old.txt
    replica=$(curl -s -q -o /tmp/cluster.txt "http://192.168.44.55/cluster.txt"; dos2unix /tmp/cluster.txt;  cat /tmp/cluster.txt  | grep -v Normal | grep -v ",,,," | grep -v DATE | wc -l )
    if [ $replica -ne 0 ] ; then 
        cat /tmp/cluster.txt  | grep -v Normal | grep -v ",,,," > /tmp/replica.txt
        txt=$(cat /tmp/replica.txt | awk '{print "<!DOCTYPE html>"$0"<br>";}' )
        x=$(diff /tmp/replica.txt /tmp/replica.old.txt | wc -l)
        if [ $x -ne 0 ] ; then
            sendemail -f "<reportes@zoftcom.com>" -t "andres@zoftcom.com;rodrigo@zoftcom.com" -s smtp.office365.com:587  -u "REPLICA WARNING" -m "$txt"  -v -xu reportes@zoftcom.com   -xp Zc0m#2021_ -o
        fi
        cp /tmp/replica.txt /tmp/replica.old.txt 
    fi

    # Reduced for dash paint in web
    # cat /tmp/$MD.events.txt | awk '{if ($1=="Date/Time:") printf("%s: ",$0); if ($2=="category:") printf("%s ",$3); if ($1=="Description:") printf("%s ",$0); if ($1=="Priorityx:") printf("%s ",$0); if ($2=="location:") printf("%s ",$0); if ($1=="Logged") printf("[C%s]",$8); if ($1=="Raw") print "";}' | awk '{gsub("Date/Time: ","");gsub("Description: ","");gsub("location: ","");gsub("Component ","");gsub("Priority: ","");gsub("Enclosure 0, ","");gsub("Controller Module 0, Slot 0 ","");gsub("Controller Module 1, Slot 0 ","");print $0}' | awk 'BEGIN{FS="/";print "EVENTOS STORAGE MD3200-01 [DELL]\n------------------------------------------------------";}{m=$1;d=$2;if (m<10) m="0"m;if (d<10) d="0"d;print "20" substr($3,1,2)"/"m"/"d,substr($3,4)}' 

)  734>/tmp/deck.lock

