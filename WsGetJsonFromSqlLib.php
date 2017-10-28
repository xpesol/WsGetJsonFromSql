<?php

function getSqlrVars() {
    $a = array();

    $a['num_po'] = $GLOBALS['num_po'];
    $a['sku'] = $GLOBALS['sku'];
    return $a;
}

function replace_num_po_in_sql($aVars, $sqlr) {
    foreach ($aVars as $key => $value) {
        $sqlr = str_replace('[[' . $key . ']]', $value, $sqlr);
    }
    return $sqlr;
}

function convert_from_latin1_to_utf8_recursively($dat) {
    if (is_string($dat))
        return utf8_encode($dat);
    if (!is_array($dat))
        return $dat;
    $ret = array();
    foreach ($dat as $i => $d)
        $ret[$i] = self::array_utf8_encode($d);
    return $ret;
}

function getDbConn() {

    $serverHost = "localhost";
    $serverPort = "5432";
    $dbName = "yrocher";
    $userName = "postgres";
    $password = "postgres";

    $dbConnectionString = " host=" . $serverHost;
    $dbConnectionString .= " port=" . $serverPort;
    $dbConnectionString .= " dbname=" . $dbName;
    $dbConnectionString .= " user=" . $userName;
    $dbConnectionString .= " password=" . $password;

    $dbConnection = pg_connect($dbConnectionString)
            or die('Connexion impossible : ' . pg_last_error());
    return $dbConnection;
}
?>