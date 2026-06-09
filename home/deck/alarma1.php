<?php
include_once("/home/ees/functions/mssql.php");

$mssql=MSSQLConnect();
$query=mssqlQ($mssql,"SELECT items.description, sitename,clock,clockdate,hostid,itemid,data_value2.value,tests.packageid,testid,hostname,mac
        FROM DATA.dbo.data_value2 
        inner join DATA.dbo.tests on tests.id= data_value2.testid and tests.packageid=data_value2.packageid
        inner join DATA.dbo.items on items.id=data_value2.itemid and items.packageid=data_value2.packageid
		inner join DATA.dbo.hosts on data_value2.hostid=hosts.id
        where clockdate > DATEADD(minute,-15,sysdatetime()) and hostid in (SELECT id
        FROM DATA.dbo.hosts where mac in('D83ADD7E37CF','DCA6327FF009','E45F01BE9C06','E45F01BE73DF','E45F01DCE7E2'))
        and data_value2.itemid=4
        and data_value2.value>=80
        and data_value2.testid in (138)
        and data_value2.testid not in (2,187)");
while ($row = mssqlF($query)) {
    $row['clockdate']=substr($row['clockdate'],0,16);
    echo "{$row['hostname']} {$row['description']} {$row['sitename']}={$row['value']}\n"; 
}
MSSQLDisconnect($mssql);
?>