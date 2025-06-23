#!/usr/bin/bash
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/soporte/.local/bin:/home/soporte/bin

rm -f *.tar
cd /home/soporte/carran
day=$(date +"%Y%m%d")
scp root@172.17.97.4:/home/paci/fileusers/cacti/subtel_$day.tar .
daydata=$(date +"%Y%m%d" -d "yesterday")
for i in $(cat enlaces.txt) ; do
    id=$(echo $i | awk 'BEGIN{FS="_id";}{print $2}' | awk 'BEGIN{FS="_"}{print "_id"$1"_";}')
    ok=$(tar tvf subtel_$day.tar | awk '{print $6}' | grep $id | wc -l)
    if [ $ok -eq 0 ] ; then 
        echo "ENLACES : $i [NO EN CACTI]"
    fi
done
for i in $(tar tvf subtel_$day.tar | awk '{print $6}' | grep -v Usage | grep -v Nac_) ; do
    e=$(echo $i | awk -vf=$daydata '{gsub(f,"");gsub(".csv","");print $0}')
    id=$(echo $i | awk 'BEGIN{FS="_id";}{print $2}' | awk 'BEGIN{FS="_"}{print "_id"$1"_";}')
    ok=$(cat enlaces.txt | grep $id | wc -l)
    if [ $ok -eq 0 ] ; then 
        echo "CACTI   : $i [NO EN ENLACES]"
    fi
done
echo ""
ssh root@172.17.97.4 df -h 
# rm -f subtel_$day.tar