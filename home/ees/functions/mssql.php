<?php
include_once "functions.php";
define('MSSQLDB_SERVER','EESMSSQL');
define('MSSQLDB_USER','sa');
define('MSSQLDB_PASSWORD','Iblau2015');
define('MSSQLDB_DATABASE','zoftcom');

function MSSQLConnect()
{
    try {
        $mssql = sqlsrv_connect(MSSQLDB_SERVER,array('Database'=>MSSQLDB_DATABASE,'UID'=>MSSQLDB_USER,'PWD'=>MSSQLDB_PASSWORD,'ReturnDatesAsStrings'=> true,'CharacterSet' => "UTF-8"));
    } catch (Exception $e) {
        echo $e . "\n";
    }

    return $mssql;
}

function MSSQLDisconnect($mssql) {
    sqlsrv_close($mssql);
}

function mssqlQ($mssql,$query, $debug = false)
{
    try
    {
        if ($debug)
        {
            var_dump($query);
            error_log($query);
            echo "<br>";
        }
  
        $q=sqlsrv_query($mssql,$query);
        if ($q)
        {
            return $q;
        }
    } catch (Exception $e)
    {
    }
    error_log(date('Y-m-d H:i:s') . " ERROR IN: " . $query);
    return false;
}

function mssqlF($dataset)
{
    return sqlsrv_fetch_array( $dataset, SQLSRV_FETCH_ASSOC);
}

function mssqlE($mssql,$sql,$debug=false) {
  $stm=mssqlQ($mssql,$sql,$debug);
  return sqlsrv_rows_affected($stm);
}

?>
