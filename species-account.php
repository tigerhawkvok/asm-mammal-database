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

function getCanonicalSpecies($speciesRow, $short = false) {
    $output = ucwords($speciesRow["genus"]);
    $short = substr(ucwords($speciesRow["genus"], 0, 1)) . ". ";
    $output.= " ".$speciesRow["species"];
    if(!empty($speciesRow["subspecies"])) {
        $output .= " " . $speciesRow["subspecies"];
        $short .= substr($speciesRow["species"], 0, 1) . ". " . $speciesRow["subspecies"];
    } else {
        $short .= $speciesRow["species"];
    }
}

$loose = false;

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
          $lookup["subspecies"] = $_REQUEST["ssp"];
      }
      break;
  case "common":
      $lookup = array(
          "common_name" => $_REQUEST["common-name"],
      );
      $loose = true;
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

# Attempt the search
try {
    $rows = $db->getQueryResults($lookup, null, null, $loose);
} catch (Exception $e) {
    $output = buildHeader("Database Error");
    $content = "<h1 class='col-xs-12'>Database Error</h1>
<p class='col-xs-12'>
Sorry, you tried to do an invalid species search. The system said:
</p>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<code class='col-xs-12 col-md-8 col-lg-6'>
".$e->getMessage()."
</code>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<p class='col-xs-12'>Please try searching above for a new species.</p>";
    $output .= getBody($content);
    echo $output;
    exit();
}

if ( sizeof($rows) < 1 ) {
    $bad = true;
    if($lookupRef == "genus") {
        # Search is good, no results? Maybe it's an old name.
        $tentativeDeprecated = strtolower(getCanonicalSpecies($_REQUEST));
        $rows = $db->getQueryResults( array( "deprecated_scientific", $db->sanitize($tentativeDeprecated) ), null, null, true, true );
        if( sizeof($rows) > 0 ) {
            $bad = false;
        }        
    }
    if($bad) {
        $output = buildHeader("Invalid Species");
        $content = "<h1 class='col-xs-12'>Species Not Found</h1>
<p class='col-xs-12'>
Sorry, you tried to do an invalid species search. The system said:
</p>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<code class='col-xs-12 col-md-8 col-lg-6'>
NO_ROWS_RETURNED
</code>
<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>
<p class='col-xs-12'>Please try searching above for a new species.</p>";
        $output .= getBody($content);
        echo $output;
        exit();
    }
}

if ( sizeof($rows) >1 ) {
    $output = buildHeader("Ambiguous Species");
    $content = "<h1 class='col-xs-12'>Species Not Found</h1>
<p class='col-xs-12'>
Sorry, the search you tried to execute returned ".sizeof($rows)." results and couldn't be implicitly refined.
</p>
<p class='col-xs-12'>
Please refine your search and try again.
</p>";
    $output .= getBody($content);
    echo $output;
    exit();
}

# We have a valid species lookup and no errors occured

$speciesRow = $rows[0];

$output = buildHeader(getCanonicalSpecies($speciesRow));


$entryTitle = "<h1 class='species-title'>".getCanonicalSpecies($speciesRow)."</h1><h2 class='species-common'>".$speciesRow["common_name"]."</h2>";

# Taxonomy notes
$taxanomyNotes = "";

# Any aside / note for this species.
$entryNote = empty($speciesRow["entry"]) ? "" : "<section id='species-note' class='col-xs-12'><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["notes"]."</script></marked-element></section></section>";

# The main entry.
$primaryEntry = "<div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div><section id='species-account' class='col-xs-12 col-md-10 col-lg-6'><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["entry"]."</script></marked-element></section><div class='col-xs-hidden col-md-offset-2 col-lg-offset-3'></div>";
$entryCredits = "";

$content = $entryTitle . $taxonomyNotes. $entryNote . $primaryEntry . $entryCredits;

$output .= getBody($content);

echo $output;

?>

