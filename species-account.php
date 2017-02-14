<?php

/*************
 * Species account page
 *
 * This page accounts for all the individual species listing
 *************/

require_once("CONFIG.php");
require_once dirname(__FILE__) . "/core/core.php";

$db = new DBHelper($default_database,$default_sql_user,$default_sql_password,$default_sql_url,$default_table,$db_cols);


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
      if(empty($_REQUEST['species'])) {
          $output = buildHeader("Species Not Found");
          $content = "<h1 class='col-xs-12'>Species Not Found</h1>
<p class='col-xs-12'>
Sorry, you tried to do an invalid species search. The system said:
</p>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<code class='col-xs-12 col-md-8 col-lg-6'>
SCIENTIFIC_SEARCH_NO_SPECIES
</code>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<p class='col-xs-12'>Please try searching above for a new species.</p>";
          $output .= getBody($content);
          echo $output;
          exit();
      }
      $lookup = array(
          "genus" => $_REQUEST['genus'],
          "species" => $_REQUEST['species'],
      );
      if(!empty($_REQUEST["ssp"])) {
          $lookup["ssp"] = $_REQUEST["ssp"];
      }
      break;
  case "common":
      # Ensu
      break;
  case null:
      # The request was invalid
      $output = buildHeader("Species Not Found");
      $content = "<h1 class='col-xs-12'>Species Not Found</h1>
<p class='col-xs-12'>
Sorry, you tried to do an invalid species search. The system said:
</p>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<code class='col-xs-12 col-md-8 col-lg-6'>
INVALID_LOOKUP_REFERENCE
</code>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<p class='col-xs-12'>Please try searching above for a new species.</p>";
      $output .= getBody($content);
      echo $output;
      exit();
      break;
  default:
      # The lookup isn't picky
      $lookup = array($lookupRef => $_REQUEST[$lookupRef]);
}

$rows = $db->getQueryResults($lookup);


?>