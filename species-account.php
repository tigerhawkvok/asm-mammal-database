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



try {
    $r = mysqli_query($db->getLink(), "SELECT id FROM `".$db->getTable()."` LIMIT 1");
    if($r === false) {
        $badDBAccess = true;

        $output = buildHeader("Problem Connecting to Database");
        $error = mysqli_error($db->getLink());
        if($error == "Table '".$db->getDB().".".$db->getTable()."' doesn't exist") {
            # Try to create it
            $result = $db->testSettings(null, true);
            if($result["status"]) {
                # Should be OK, but let's check again
                $r = mysqli_query($db->getLink(), "SELECT id FROM `".$db->getTable()."` LIMIT 1");
                if($r !== false) $bdDBAccess = false;
                else {
                    $error .= " We tried to create it, but couldn't verify access.";
                }
            } else {
                $error .= " We tried to create it, but failed.";
            }
            # Next line is unsafe. Enable only for debugging, never in production.
            # $error .= "\n\n".print_r($result, true);
        }
        if($badDBAccess) {
            $content = "<h1 class='col-xs-12'>Problem connecting to database</h1>
<p class='col-xs-12'>
Oops! The system had a problem. The system said:
</p>
<code class='col-xs-12 col-md-8 col-lg-6 col-md-offset-2 col-lg-offset-3'>
".$error."
</code>
<p class='col-xs-12'>Please try again in a few minutes. If the problem persists, contact support.</p>";
            $output .= getBody($content);
            echo $output;
            exit();
        }

    }

} catch (Exception $e) {
    $output = buildHeader("Problem Connecting to Database");
    $content = "<h1 class='col-xs-12'>Problem connecting to database</h1>
<p class='col-xs-12'>
Oops! The system had a problem. The system said:
</p>
<code class='col-xs-12 col-md-8 col-lg-6 col-md-offset-2 col-lg-offset-3'>
ERROR: ".$e->getMessage()."
</code>
<p class='col-xs-12'>Please try again in a few minutes. If the problem persists, contact support.</p>";
             $output .= getBody($content);
             echo $output;
             exit();

}



function getCanonicalSpecies($speciesRow, $short = false) {
    $output = ucwords($speciesRow["genus"]);
    $short = ucwords(substr($speciesRow["genus"], 0, 1)) . ". ";
    $output .= " " . $speciesRow["species"];
    if(!empty($speciesRow["subspecies"])) {
        $output .= " " . $speciesRow["subspecies"];
        $short .= substr($speciesRow["species"], 0, 1) . ". " . $speciesRow["subspecies"];
    } else {
        $short .= $speciesRow["species"];
    }
    if(!empty($speciesRow["canonical_sciname"])) $output = $speciesRow["canonical_sciname"];
    return $short === true ? $short : $output;
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
<code class='col-xs-12 col-md-8 col-lg-6 col-md-offset-2 col-lg-offset-3'>
SCIENTIFIC_SEARCH_NO_SPECIES
</code>
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
<code class='col-xs-12 col-md-8 col-lg-6 col-md-offset-2 col-lg-offset-3'>
INVALID_LOOKUP_REFERENCE
</code>
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
    $rows = $db->getQueryResults($lookup, "*", "AND", $loose, false, false, true);
} catch (Exception $e) {
    $output = buildHeader("Database Error");
    $content = "<h1 class='col-xs-12'>Database Error</h1>
<p class='col-xs-12'>
Sorry, you tried to do an invalid species search. The system said:
</p>
<div class='col-xs-hidden'></div>
<code class='col-xs-12 col-md-8 col-lg-6 col-md-offset-2 col-lg-offset-3'>
".$e->getMessage()."
</code>
<p class='col-xs-12'>Please try searching above for a new species.</p>";
    $output .= getBody($content);
    echo $output;
    exit();
}

$orig_rows = $rows;

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
<code class='col-xs-12 col-md-8 col-lg-6 col-md-offset-2 col-lg-offset-3'>
NO_ROWS_RETURNED

".print_r($lookup, true)."

".print_r($orig_rows, true)."

</code>
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

if(empty($speciesRow["common_name"])) {
    try {
    $endpoint = "http://apiv3.iucnredlist.org/api/v3/species/common_names/";
    $destUrl = $endpoint.urlencode(getCanonicalSpecies($speciesRow))."token=".$iucnToken;
    $opts = array(
        'http' => array(
            'method' => 'GET',
            #'request_fulluri' => true,
            'ignore_errors' => true,
            'timeout' => 3.5, # Seconds
        ),
    );
    $context = stream_context_create($opts);
    $response = file_get_contents($destUrl, false, $context);
    $decoded = json_decode($response, true);
    foreach($decoded["result"] as $result) {
        if($result["primary"] === true || $result["language"] == "eng") {
            $speciesRow["common_name"] = $result["taxonname"];
            break;
        }
    }
    if(empty($speciesRow["common_name"])) {
        throw new Exception("NO_IUCN_RESULT_ERROR");
    } else {
        # Save this common name to the database
        try {
            $db->updateEntry( array("common_name" => $speciesRow["common_name"]), array("id" => $speciesRow["id"]));
        } catch (Exception $e) {
            $output .= "<!-- Warning: Unable to save common name to database -->";
        }
    }
    } catch (Exception $e) {
        $output .= "<!-- Warning: Unable to generate common name: ". $e->getMessage() . " -->";
    }
}

$entryTitle = "<h1 class='species-title col-xs-12'>".getCanonicalSpecies($speciesRow)."</h1><h2 class='species-common col-xs-offset-1 col-xs-11'>".$speciesRow["common_name"]."</h2>";

# Taxonomy notes
$englishMap = array(
    "eutheria" => "placental mammals",
        "metatheria" => "marsupials",
        "prototheria" => "egg-laying mammals (monotremes)",
    );
$taxonomyNotes = "<section id='taxonomy' class='col-xs-12'>
<section class='scientific-taxonomy'><span class='clade'>".$speciesRow["simple_linnean_group"]."</span> &#187; <span class='clade'>".$speciesRow["linnean_order"]."</clade> &#187; <span class='clade'>".$speciesRow["linnean_family"]."</span></section>

<section class='common-taxonomy'>".$englishMap[$speciesRow["simple_linnean_group"]]." &#187; ".$speciesRow["simple_linnean_subgroup"]."</section>
</section>";

# Any aside / note for this species.
$entryNote = empty($speciesRow["entry"]) ? "" : "<section id='species-note' class='col-xs-12'><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["notes"]."</script></marked-element></section></section>";

## Build an image carousel
# The initial large image should be the one under 'image'
# Others should be linked ones from 'image_resources'

$images = "";


# The main entry.
$primaryEntry = "<section id='species-account' class='col-xs-12 col-md-10 col-lg-6 col-md-offset-2 col-lg-offset-3'><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["entry"]."</script></marked-element></section>";

# Credits
$creditTime = intval($speciesRow["taxon_credit_date"]);
if(!is_numeric($creditTime) || $creditTime == 0) {
    $creditTime = time();
}
$creditAuthor = empty($speciesRow["taxon_author"]) ? "your local ASM server" : $speciesRow["taxon_author"];
$credit = empty($speciesRow["taxon_credit"]) ? "Entry by ".$creditAuthor." on ".strftime("%d %B %Y", $creditTime) : $speciesRow["taxon_credit"];
$entryCredits = "<section id='entry-credits' class='col-xs-12 small'><p>".$credit."</p></section>";

$content = $entryTitle . $images . $taxonomyNotes. $entryNote . $primaryEntry . $entryCredits;

$content .= "<code class='col-xs-12'>Species: ". print_r($speciesRow, true) . "</code>";

$output .= getBody($content);

echo $output;

?>
