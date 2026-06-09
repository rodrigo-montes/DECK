<?php
include_once("/home/ees/functions/mssql.php");

$mssql=MSSQLConnect();
$query=mssqlQ($mssql,"SELECT hosts.id,hosts.hostname,mac,count(*) as q
        FROM DATA.dbo.data_value2
        inner join DATA.dbo.tests on tests.id= data_value2.testid and tests.packageid=data_value2.packageid
        inner join DATA.dbo.items on items.id=data_value2.itemid and items.packageid=data_value2.packageid
		inner join DATA.dbo.hosts on data_value2.hostid=hosts.id
        where clockdate > DATEADD(minute,-15,sysdatetime()) and hostid in (SELECT id
        FROM DATA.dbo.hosts where mac in('D83ADD7E37CF','DCA6327FF009','E45F01BE9C06','E45F01BE73DF','E45F01DCE7E2'))
		and data_value2.itemid=4
        and data_value2.testid in (138)
        and data_value2.testid not in (2,187)
		group by hosts.hostname,hosts.id,mac");
while ($row = mssqlF($query)) {
    echo "{$row['id']} {$row['hostname']} {$row['q']}\n"; 
}
MSSQLDisconnect($mssql);
?>