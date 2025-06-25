#!/bin/bash/bash
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/home/backup

date=$(date | awk '{print $1,$2,$3,$4}')

if [ "$1" == "backup" ] ; then 
    curl --silent -q -H "Content-type: application/json" \
    --data '{"channel":"backup","attachments": [ {"color": "good","fields": [ { "value": "'"$2"'", "short": false } ] } ],"icon_emoji": ":ghost:"}' \
    -X POST https://hooks.slack.com/services/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 >> /dev/null
fi

if [ "$1" == "critico" ] ; then 
    curl --silent -q -H "Content-type: application/json" \
    --data '{"channel":"critico","attachments": [ {"color": "good","fields": [ { "title": "SERVERS", "value": "'"$2"'", "short": false } ] } ],"icon_emoji": ":ghost:"}' \
    -X POST https://hooks.slack.com/services/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 >> /dev/null
fi
