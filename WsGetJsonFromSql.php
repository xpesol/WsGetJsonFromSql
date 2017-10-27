<?php

//POUR TESTER
//http://test-cotyr.fcsystem.com/ws/WsGetQfPolWithTarif.ws_json?apikey=595c015a-98c4-4097-9d89-c5b83ed28ff1

$dbug = 0;
$title = "Liste des ports de départ avec tarifs";
$release = "1.0.1";
$release_date = "20170605";
$ws = preg_replace('/(\w+)\.\w+$/i', '$1', basename(__FILE__));
//https://phea.fr/outils/generateur-cle-aleatoire-random-key
$apiKey = "595c015a-98c4-4097-9d89-c5b83ed28ff1";

$getApiKey = $_GET["apikey"];
$getPortCode = $_GET["portcode"];
$getCountryName = $_GET["countryname"];
$getPortName = $_GET["portname"];
$getisPol = $_GET["ispol"];
$getisPod = $_GET["ispod"];
$getColumns = $_GET["columns"];
$getExtension = $_GET["ext"];
$getIsOnlyResult = $_GET["isonlyresult"];
$sSqlrFilePath = $_GET["sqlrfilepath"];

$sqlr = file_get_contents($sSqlrFilePath, FILE_USE_INCLUDE_PATH);

header('content-type:application/json;charset=SQL_ASCII');

define('PGHOST', "localhost");
define('PGPORT', "5432");
define('PGDATABASE', "yrocher");
define('PGUSER', "postgres");
define('PGPASSWORD', "postgres");
define('PGCLIENTENCODING', 'UNICODE');
define('ERROR_ON_CONNECT_FAILED', 'Sorry, can not connect the database server now!');

$dbconn = pg_connect("host=" . PGHOST . " port=" . PGPORT . " dbname=" . PGDATABASE . " user=" . PGUSER . " password=" . PGPASSWORD)
        or die('Connexion impossible : ' . pg_last_error());

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

$result = pg_query($sqlr) or die('Echec de la requete : ' . pg_last_error());
$resultRows = pg_num_rows($result);
$arrayData = array();
while ($data = pg_fetch_object($result)) {
    $tmpData = array();
    if ($getColumns == '') {
        $vars = get_object_vars($data);
        foreach ($vars as $key => $var) {
            $tmpData[$key] = convert_from_latin1_to_utf8_recursively($data->$key);
        }
    } else {
        $arrayColumns = split(',', $getColumns);
        foreach ($arrayColumns as $value) {
            $tmpData["\"" . $value . "\""] = $data->$value;
        }
    }
    array_push($arrayData, $tmpData);
}
pg_free_result($result);
pg_close($dbconn);

$arrayMain = array(
    "\"release_version\"" => $release,
    "\"release_date\"" => $release_date,
    "\"dataset\"" => $title,
    "\"ws\"" => $ws,
    "\"format\"" => "json",
    "\"timestamp\"" => date("Ymd-H:i:s"),
    "\"parameters\"" => array(
        "\"columns\"" => "columns=code_port,nom_pays,nom_port,is_pol,is_pod",
        "\"filters\"" => array(
            "portcode=[a-Z]",
            "countryname=[a-Z]",
            "portname=[a-Z]",
            "ispol=[TRUE|FALSE]",
            "ispod=[TRUE|FALSE]",
            "ext=[extension]( pour une génération  )",
            "isonlyresult=[TRUE|FALSE]"
        )
    ),
    "\"rows\"" => $resultRows,
    "\"results\"" => $arrayData,
);


if ($getApiKey != $apiKey) {
    $arrayMain["\"errors\""] = array(
        message => "=Wrong apikey!!!",
        code => 1
    );
}

if ($dbug) {
    $arrayMain["\"sqlr\""] = $sqlr;
}

$arrayToEncode = $arrayMain;
if ($getIsOnlyResult) {
    $arrayToEncode = $arrayData;
}
$strJson = json_encode($arrayToEncode, JSON_PRETTY_PRINT);
$error = json_last_error_msg();
$errorNumber = json_last_error();
if ($errorNumber > 0) {
    print $errorNumber . ':' . $error;
}

if ($getExtension != '') {

    $outPutFile = preg_replace('/(\w+)\.\w+$/i', '$1', $_SERVER["SCRIPT_FILENAME"]) . "." . $getExtension;
    print $outPutFile;

    $fp = @fopen($outPutFile, 'w'); // open or create the file for writing and append info
    fputs($fp, $strJson); // write the data in the opened file
    fclose($fp); // close the file	
} else {
    echo $strJson;
}
?>	
