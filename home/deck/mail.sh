#!/usr/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
 
cat /tmp/MD3200-01.events.txt | awk '{if ($1=="Date/Time:") printf("%s ",$0); if ($2=="category:") printf("%s ",$3); if ($1=="Description:") printf("%s ",$0); if ($1=="Priority:") printf("%s ",$0); if ($2=="location:") printf("%s ",$0); if ($1=="Raw") print "";}' | awk 'BEGIN{print "EVENTOS STORAGE MD3200-01 [HP]\n------------------------------------------------------";}{gsub("Date/Time: ","");gsub("Description: ","");gsub("location: ","");gsub("Component ","");gsub("Priority: ","");print $0}'  > /tmp/MD3200-01.e.txt
txt=$(cat /tmp/MD3200-01.e.txt | awk '{gsub("Failure","<span style=\"color:red;font-weight:600;\">Failure</span>");gsub("Error","<span style=\"color:red;font-weight:600;\">Error</span>");print "<!DOCTYPE html>"$0"<br>";}' )
sendemail -f "<reportes@zoftcom.com>" -t "andres@zoftcom.com;rodrigo@zoftcom.com" -s smtp.office365.com:587  -u "EVENTS MD3200-01" -m "$txt"  -v -xu reportes@zoftcom.com   -xp Zc0m#2021_ -o

cat /tmp/MD3200-02.events.txt | awk '{if ($1=="Date/Time:") printf("%s ",$0); if ($2=="category:") printf("%s ",$3); if ($1=="Description:") printf("%s ",$0); if ($1=="Priority:") printf("%s ",$0); if ($2=="location:") printf("%s ",$0); if ($1=="Raw") print "";}' | awk 'BEGIN{print "EVENTOS STORAGE MD3200-02 [DELL]\n------------------------------------------------------";}{gsub("Date/Time: ","");gsub("Description: ","");gsub("location: ","");gsub("Component ","");gsub("Priority: ","");print $0}'  > /tmp/MD3200-02.e.txt
txt=$(cat /tmp/MD3200-02.e.txt | awk '{gsub("Failure","<span style=\"color:red;font-weight:600;\">Failure</span>");gsub("Error","<span style=\"color:red;font-weight:600;\">Error</span>");print "<!DOCTYPE html>"$0"<br>";}' )
sendemail -f "<reportes@zoftcom.com>" -t "andres@zoftcom.com;rodrigo@zoftcom.com" -s smtp.office365.com:587  -u "EVENTS MD3200-02" -m "$txt"  -v -xu reportes@zoftcom.com   -xp Zc0m#2021_ -o
