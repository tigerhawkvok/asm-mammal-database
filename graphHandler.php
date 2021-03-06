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


$client = ClientBuilder::create()
->addConnection('default', $graphProtocol . "://" . $graphUser . ":" . $graphPassword . "@" . $graphUrl . ":" .$graphPorts[$graphProtocol])
->setDefaultTimeout(60)
->build();



switch ($_REQUEST["action"]) {
    case "id_details":
        getTaxonDetailsFromID($_REQUEST["id"]);
    case "children":
        getChildNodes($_REQUEST["taxon"]);
    case "load":
        # Authenticate
        require_once(dirname(__FILE__)."/admin/async_login_handler.php");
        $login_status = getLoginState($_REQUEST);
        if ($login_status !== true) {
            returnAjax(array(
                "status" => false,
                "error" => "You need to be logged in with admin credentials to perform this action"
            ));
        }
        returnAjax($login_status);
        # Check flag

        returnAjax(loadDatabase());
    default:
        getRelatedness();
}




function resultToGraphJSON($resultObj, $asNode = false) {
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    header('Content-type: application/json; charset=utf-8');
    $graphJson = array(
        "nodes" => array(),
        "edges" => array()
    );
    $treeRank = array(
        "Species" => 0,
        "Genus" => 1,
        "Family" => 2,
        "Order" => 3,
        "Superorder" => 4,
        "Magnaorder" => 5,
        "Cohort" => 6,
    );
    $highestRank = 0;
    $rootIndex = 0;
    foreach($resultObj->records() as $recordBase) {
        foreach ($recordBase->values() as $record) {
            $i = 0;
            if (!$asNode) {
                foreach ($record->nodes() as $node) {
                    $type = $node->labels()[0];
                    $graphJson["nodes"][] = array(
                        "root" => False,
                        "id" => $node->identity(),
                        "type" => $type,
                        "label" => $node->value("label"),
                        "caption" => $type != "Species" ? $node->value("label") : $node->value("binomial"),
                        "values" => $node->values(),
                        "x" => $i,
                        "y" => $i,
                        "size" => 1,
                        "color" => "#58e",
                    );
                    try {
                        if ($treeRank[$node->value("rank")] > $highestRank) {
                            $highestRank = $treeRank[$node->value("rank")];
                            $rootIndex = $i;
                        }
                    } catch (Exception $e) {
                        $rootIndex = $i;
                        $highestRank = 999;
                    }
                    $i++;
                }
                foreach ($record->relationships() as $relationship) {
                    $graphJson["edges"][] = array(
                        "source" => $relationship->startNodeIdentity(),
                        "target" => $relationship->endNodeIdentity(),
                        "caption" => $relationship->type(),
                        "label" => $relationship->type(),
                        "type" => $relationship->type(),
                        "values" => $relationship->values(),
                        "id" => $relationship->identity(),
                        "color" => "#999",
                    );
                }
            } else {
                $node = $record;
                $type = $node->labels()[0];
                $graphJson["nodes"][] = array(
                    "root" => False,
                    "id" => $node->identity(),
                    "type" => $type,
                    "label" => $node->value("label"),
                    "caption" => $type != "Species" ? $node->value("label") : $node->value("binomial"),
                    "values" => $node->values(),
                );
                if ($treeRank[$node->value("rank")] > $highestRank) {
                    $highestRank = $treeRank[$node->value("rank")];
                    $rootIndex = $i;
                }
                $i++;
            }
        }
    }
    $graphJson["nodes"][$rootIndex]["root"] = True;
    $json = json_encode($graphJson, JSON_PARTIAL_OUTPUT_ON_ERROR | JSON_UNESCAPED_UNICODE);
    if ($json === false) {
        $json = json_last_error();
    }
    $replace_array = array("&quot;","&#34;");
    print str_replace($replace_array, "\\\"", $json);
    exit();
}


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

function updateTaxonomy($changeDetails, $taxonomyLevel = "clade") {
    /***
     * Update a taxon changed on the main site.
     *
     * @param array $changeType -> Details the change type.
     *   array(
     *     "type" => [RENAME, MOVE]
     *     "update" => For rename, a string of the new name. For move, string of the new parent (must be of same rank of previous parent)
     *   )
     * @param str $taxonomyLevel -> controlled vocabulary. "genus", "species", or null/"clade"
     ***/
    global $db, $client;
    if(empty($taxonomyLevel)) {
        $taxonomyLevel = "clade";
    }
    $taxonomyLevel = ucwords($taxonomyLevel);
    $validLevels = array(
        "Genus",
        "Species",
        "Clade"
    );
    if(!in_array($taxonomyLevel, $validLevels, True)) {
        return array(
            "status" => False,
            "error" => "Invalid taxonomy level '".$taxonomyLevel."'"
        );
    }
    # Operations
}


function getChildNodes($taxonLabel) {
    /***
     * From a given taxon label, find all the children and return
     * a graphJSON
     ***/
    global $db, $client;
    $cypher = "MATCH path = (t {label:'$taxonLabel'})-[:CONTAINS_CLADE]->(r) RETURN path";
    $neo4jResults = $client->run($cypher);
    resultToGraphJSON($neo4jResults);

}

function getTaxonDetailsFromID($nodeID) {
    /***
     *
     */
    $cleanNodeID = intval($nodeID);
    if (!is_numeric($cleanNodeID)) {
        return False;
    }
    global $client;
    $cypher = "MATCH (c) WHERE ID(c) = $cleanNodeID RETURN c.label, c.rank";
    # Do the thing
    $result = $client->run($cypher);
    $recordBase = $result->records();
    $resultDetails = $recordBase[0]->values();
    # Return it
    returnAjax(array(
        "label" => $resultDetails[0],
        "rank" => $resultDetails[1]
    ));
}



function getRelatedness($taxon1, $taxon2) {
    /***
     *
     ***/
    global $client, $db;
    $taxon1 = empty($taxon1) ? $_REQUEST["taxon1"] : $taxon1;
    $taxon2 = empty($taxon2) ? $_REQUEST["taxon2"] : $taxon2;
    /**
     *  Sample:
     *
     * match (start:Species {binomial: 'rhinoceros unicornis'}), (end:Species {binomial: 'bradypus tridactylus'})
     * call apoc.algo.dijkstraWithDefaultWeight(start, end, 'CLADE_CONTAINS|DESCENDANT_OF', 'distance', 1) YIELD path, weight
     * return path
     *
     */
    # Do a regex check on the taxa
    # execute query
    $cypher = "
    MATCH (start:Species {binomial: '$taxon1'}), (end:Species {binomial: '$taxon2'})
    CALL apoc.algo.dijkstraWithDefaultWeight(start, end, 'CLADE_CONTAINS|DESCENDANT_OF', 'distance', 1) YIELD path, weight
    RETURN path
    ";
    $result = $client->run($cypher);
    resultToGraphJSON($result);

}



?>
