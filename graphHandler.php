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

 # Setup graph connection
require_once __DIR__ . '/vendor/autoload.php';
use GraphAware\Neo4j\Client\ClientBuilder;

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



/* $config = \GraphAware\Bolt\Configuration::newInstance()
->withCredentials($graphUser, $graphPassword)
->withTimeout(10)
->withTLSMode(\GraphAware\Bolt\Configuration::TLSMODE_REQUIRED);

$driver = \GraphAware\Bolt\GraphDatabase::driver($graphEndpoint, $config); */
$client = ClientBuilder::create()
->addConnection('default', $graphProtocol . "://" . $graphUser . ":" . $graphPassword . "@" . $graphUrl . ":" .$graphPorts[$graphProtocol])
->setDefaultTimeout(60)
->build();


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
    try {
        $client->run("MATCH (n) DETACH DELETE n");
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
                if (empty($row[0])) {
                    continue;
                }
                $data[] = array($row[0]);
            }
            # Start the cypher query
            $cypher = "
            UNWIND {data} AS attr
            MERGE (:Clade {label: attr[0], rank: '$nodeLabel'})
            ";
            $client->run($cypher, array("data"=>$data));
            $i++;
            # If we have defineable children, let's specify them
            $childNodeLabel = next($looper);
            if ($childNodeLabel !== False) {
                $childDBKey = $dbKeys[$i];
                $origData = $data;
                foreach ($origData as $dataSet) {
                    $parentClade = $dataSet[0];
                    $query = "SELECT DISTINCT `$childDBKey` FROM `".$db->getTable()."` WHERE lower(`$dbKey`)=lower('$parentClade') ORDER BY id";
                    $r2 = mysqli_query($l, $query);
                    if ($r2 !== false) {

                        $data = array();
                        $j = 0;
                        while ($childRow = mysqli_fetch_row($r2)) {
                            if (empty($childRow[0])) {
                                continue;
                            }
                            $data[] = array(
                                            $parentClade,
                                            $childRow[0]
                                            );
                        }
                        $cypher = "
                        UNWIND {data} AS attr
                        MATCH (c:Clade {label: attr[0]})
                        MERGE (c)-[:CONTAINS_CLADE]->(:Clade {label: attr[1], rank: '$childNodeLabel', parent: '$parentClade'})-[:DESCENDANT_OF]->(c)";
                        $client->run($cypher, array("data"=>$data));
                    } else {
                        $errors[] = "No children found for child: ".$query;
                    }
                }
            } else {
                # No children
                $cypher = "
                MATCH c WHERE NOT (c:Clade)<-[:CONTAINS_CLADE]-(:Clade)
                ";
            }
        }
        # Link the top level back
        $client->run("MATCH (m:Mammals) WITH m AS m MATCH (c:Clade {rank:'Cohort'}) MERGE (m)-[:CONTAINS_CLADE]->(c)-[:DESCENDANT_OF]->(m)");
    } catch (\GraphAware\Neo4j\Client\Exception\Neo4jException $e) {
        return array(
            "status" => False,
            "error" => $e->getMessage(),
            "data" => $data
        );
    }
    # Tag out genus and species
    $query = "SELECT DISTINCT `genus`, `linnean_family` FROM `".$db->getTable()."`";
    $r = mysqli_query($l, $query);
    if ($r === false) {
        $errors[] = mysqli_error($l);
        return array(
            "status" => False,
            "error" => "Unable to assign genera"
        );
    }
    # Build the parameters
    $data = array();
    while($row = mysqli_fetch_row($r)) {
        if (empty($row[0])) {
            continue;
        }
        $data[] = array($row[0], $row[1]);
    }
    # Start the cypher query
    $cypher = "
    UNWIND {data} AS attr
    CREATE (g:Genus {label: attr[0], rank: 'Genus'})
    WITH g AS g, attr as attr
    MATCH (c:Clade {label: attr[1]})
    MERGE (g)<-[:CONTAINS_CLADE]-(c)<-[:DESCENDANT_OF]-(g)
    ";
    $client->run($cypher, array("data"=>$data));
    $query = "SELECT DISTINCT `species`, `genus`, CONCAT(genus, ' ', species) FROM `".$db->getTable()."`";
    $r = mysqli_query($l, $query);
    if ($r === false) {
        $errors[] = mysqli_error($l);
        return array(
            "status" => False,
            "error" => "Unable to assign species"
        );
    }
    # Build the parameters
    $data = array();
    while($row = mysqli_fetch_row($r)) {
        if (empty($row[0])) {
            continue;
        }
        $data[] = array($row[0], $row[1], $row[2]);
    }
    # Start the cypher query
    $cypher = "
    UNWIND {data} AS attr
    CREATE (g:Species {label: attr[0], rank: 'Species', binomial: attr[2] })
    WITH g AS g, attr as attr
    MATCH (c:Genus {label: attr[1]})
    MERGE (g)<-[:CONTAINS_CLADE]-(c)<-[:DESCENDANT_OF]-(g)
    ";
    $client->run($cypher, array("data"=>$data));
    return array(
        "status" => True,
        "errors" => $errors
    );
}

function syncTaxa()
{

}


returnAjax(loadDatabase());


?>
