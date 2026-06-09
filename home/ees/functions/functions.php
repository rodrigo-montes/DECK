<?php

function getFieldsTypes($mssql,$table) {
    $tbl=explode('.',$table);
    $DATABASE=$tbl[0];
    $TABLENAME=$tbl[2];
    mssqlQ($mssql,"USE " . $DATABASE);
    $sql="SELECT COLUMN_NAME, DATA_TYPE 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = '" . $TABLENAME . "'";

    $query=mssqlQ($mssql,$sql);
    $data=array();
    $type='string';
    while ($row = mssqlF( $query )) {
        if ($row['COLUMN_NAME'] == "md5") continue;
        if ($row['COLUMN_NAME'] == 'ssma\$rowid') continue;
        switch ( $row['DATA_TYPE'] ) {
            case 'bigint'   : $type='number'; break;
            case 'int'      : $type='number'; break;
            case 'numeric'  : $type='number'; break;
            case 'float'    : $type='float'; break;
            case 'datetime' : $type='datetime'; break;
            case 'date'     : $type='date'; break;
            case 'char'     : $type='string'; break;
            case 'varchar'  : $type='string'; break;
            case 'nvarchar' : $type='string'; break;
            case 'time'     : $type='time'; break;
            case 'text'     : $type='string'; break;
        }
        $data[$row['COLUMN_NAME']] = $type;
    }
    return $data;

}

function quote($fields,$field,$value) {
    $value=str_replace("'","",$value);
    $value=str_replace("\n","",$value);
    $value=str_replace("\r","",$value);
    switch ($fields[$field]) {
        case 'number'   : if ($value == "") $ret='null'; else $ret=$value; break;
        case 'float'    : $ret=$value;
                        if ($value == "") $ret='null'; 
                        if ($value == '.00') $ret='0'; 
                        break;
        case 'string'   : $ret="'" . $value . "'"; break;
        case 'datetime' : if ($value=='') $ret='null'; else $ret="'" . $value . "'";  break;
        case 'date'     : if ($value=='') $ret='null'; else $ret="'" . $value . "'";  break;
        case 'time'     : if ($value=='') $ret='null'; else $ret="'" . $value . "'";  break;
        default         : $ret="'" . $value . "'";  break;
    }
    return $ret;
}

?>