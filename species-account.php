<?php

/*************
 * Species account page
 *
 * This page accounts for all the individual species listing
 *************/

require_once dirname(__FILE__) . "/core/core.php";

# Check the species being looked up

$lookupId = null;
$lookupRef = null;

$validIdKeys = array(
    "id", # Internal unique ID
    "species-id", # ASM species UID
    "genus", # Expects 'species' as a co-key
    "common", # May do a common lookup if the key 'unique-common' is set
);

foreach($validIdKeys as $tentativeRef) {
    if(isset($_REQUEST[$tentativeRef]) && !empty($_REQUEST[$tentativeRef])) {
        $lookupRef = $tentativeRef;
        break;
    }
}



function buildHeader($pageTitle, $prerender, $prefetch) {
    $html = "<!doctype html>
<html lang=\"en\">
  <head>
    <title>
    $pageTitle
    </title>";
    $html .= get_include_contents("modular/header.php");
    $html .= "\n</head>";
    return $html;
}

function getBody($content) {
    include "modular/bodyFrame.php";
    $html = $bodyOpen . $content . $bodyClose;
    return $html;
}


switch($lookupRef) {
  case "genus":
      break;
  case "common":
      break;
  case null:
      # The request was invalid
      $output = buildHeader("Species Not Found");
      
      break;
  default:
      # The lookup isn't picky
}


?>