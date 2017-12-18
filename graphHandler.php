<?php


/***
 *
 *
 * Connection docs:
 * https://github.com/graphaware/neo4j-php-client
 *
 * @author Philip Kahn
 * @date 2017.11.22
 ***/

/*****************
* Setup
 *****************/

#$show_debug = true;

if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('API is running in debug mode!');
    $debug = true; # compat
} else {
    # Rigorously avoid errors in production
    ini_set('display_errors', 0);
    $debug = false;
}

require dirname(__FILE__)."/CONFIG.php";
require_once(dirname(__FILE__)."/core/core.php");
# This is a public API
header("Access-Control-Allow-Origin: *");

$db = new DBHelper($default_database, $default_sql_user, $default_sql_password, $default_sql_url, $default_table, $db_cols);

if (isset($_SERVER['QUERY_STRING'])) {
    parse_str($_SERVER['QUERY_STRING'], $_REQUEST);
}

$start_script_timer = microtime_float();
$_REQUEST = array_merge($_REQUEST, $_GET, $_POST);

if (!function_exists('elapsed')) {
    function elapsed($start_time = null)
    {
        /***
         * Return the duration since the start time in
         * milliseconds.
         * If no start time is provided, it'll try to use the global
         * variable $start_script_timer
         *
         * @param float $start_time in unix epoch. See http://us1.php.net/microtime
         ***/
        if (!is_numeric($start_time)) {
            global $start_script_timer;
            if (is_numeric($start_script_timer)) {
                $start_time = $start_script_timer;
            } else {
                return false;
            }
        }
        return 1000*(microtime_float() - (float)$start_time);
    }
}


# Setup graph connection
require_once 'vendor/autoload.php';


use GraphAware\Neo4j\Client\ClientBuilder;


$config = \GraphAware\Bolt\Configuration::newInstance()
->withCredentials($graphUser, $graphPassword)
->withTimeout(10)
->withTLSMode(\GraphAware\Bolt\Configuration::TLSMODE_REQUIRED);

$driver = \GraphAware\Bolt\GraphDatabase::driver($graphEndpoint, $config);
$client = $driver->session();


function loadDatabase() {
    global $db, $client;
    # Create nodes for the high level taxa
    $looper = array(
        "simple_linnean_group" => "Cohort",
        "major_type" => "Magnaorder",
        "major_subtype" => "Superorder",
        "linnean_order" => "Order",
        "linnean_family" => "Family",
    );
    $l = $db->getLink();
    $errors = array();
    $i = 0;
    $dbKeys = array_keys($looper);
    reset($looper);
    $client->run("MATCH n DETACH DELETE n");
    $client->run("CREATE (:Mammals {label: 'mammalia'})");
    while ($nodeLabel = current($looper)) {
        # Create an array of parameters to pass to the graph database
        $dbKey = $dbKeys[$i];
        $query = "SELECT DISTINCT `$dbKey` FROM `".$db->getTable()."` ORDER BY id";
        $r = mysqli_query($l, $query);
        if ($r === false) {
            $errors[] = mysqli_error($l);
            continue;
        }
        # Build the parameters
        $data = array();
        while($row = mysqli_fetch_row($r)) {
            $data[] = array("label"=>$row[0]);
        }
        # Start the cypher query
        $cypher = "
        UNWIND {data as attr}
        CREATE (n:$nodeLabel {label: attr.label})
        ";
        $i++;
        # If we have defineable children, let's specify them
        $childNodeLabel = next($looper);
        if ($childNodeLabel !== null) {
            $childDBKey = $dbKeys[$i];
            $query = "SELECT DISTINCT `$childDBKey` FROM `".$db->getTable()."` ORDER BY id";
            $r2 = mysqli_query($l, $query);
            if ($r2 !== false) {
                $j = 0;
                while ($childRow = mysqli_fetch_row($r2)) {
                    $data[$j]["childLabel"] = $childRow[0];
                    $j++;
                }
                $cypher .= "-[:CONTAINS_CLADE]->(cn:$childNodeLabel {label: attr.childLabel)";
            }
        }
        $client->run($cypher, $data);
    }
    # Link the top level back
    $client->run("MERGE (:Mammals)-[:CONTAINS_CLADE]->(:Cohort)<-[:DESCENDANT_OF]-(:Mammals)");
    return true;
}

function syncTaxa()
{

}


returnAjax(loadDatabase());


?>
