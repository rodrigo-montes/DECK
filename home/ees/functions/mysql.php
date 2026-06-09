<?php
define('MYSQLDB_SERVER','EESMYSQL');
define('MYSQLDB_USER','ees');
define('MYSQLDB_PASSWORD','Iblau2015!');
define('MYSQLDB_DATABASE','zoftcom');

function MYSQLConnect()
{
    $mysql=null;
    try {
        $mysql=new PDO('mysql:host=' . MYSQLDB_SERVER . ';dbname=' . MYSQLDB_DATABASE, MYSQLDB_USER, MYSQLDB_PASSWORD);
    } catch (Exception $e) {
        
    }
    return $mysql;
}

function MYSQLDisconnect($mysql) {
    $mysql=null;
}

function mysqlQ($mysql,$query, $debug = false)
{
    $query = str_replace('.dbo.','.',$query);
    try
    {
        if ($debug)
        {
            var_dump($query);
            error_log($query);
            echo "<br>";
        }
  
        $dataset=$mysql->query($query);
        if ($dataset)
        {
            return $dataset;
        }
    } catch (Exception $e)
    {
    }
    error_log(date('Y-m-d H:i:s') . " ERROR IN: " . $query);
    return false;
}

function mysqlF($dataset)
{
    return $dataset -> fetch(PDO::FETCH_ASSOC);
}
function mysqlN($mysql, $query)
    {
        $dataset=$mysql->query($query);
        return $dataset -> rowCount();   
    }
function mysqlV($dataset)
    { 
        return $dataset -> fetchColumn();
    }

function mysqlE($mysql, $query, $debug=false)
    {
        $dataset=mysqlQ($mysql,$query,$debug);
        return $dataset -> rowCount();
    }
?>
