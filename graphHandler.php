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


require_once 'vendor/autoload.php';

use GraphAware\Neo4j\Client\ClientBuilder;

$client = ClientBuilder::create()
        ->addConnection('default', 'http://neo4j:password@localhost:7474') // Example for HTTP connection configuration (port is optional)
        ->addConnection('bolt', 'bolt://neo4j:password@localhost:7687') // Example for BOLT connection configuration (port is optional)
        ->build();


function syncTaxa() 
{
    
}





?>