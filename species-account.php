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
    $html = $bodyOpen . $content . $bodyClose . "\n</html>";
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

$nameCitation = "";
$citationYears = json_decode($speciesRow["authority_year"], true);
if(!empty($speciesRow["genus_authority"])) {
    if(!empty($citationYears)) {
        $citation = $speciesRow["genus_authority"]." ".key($citationYears);
        if(toBool($speciesRow["parens_auth_genus"])) $citation = "($citation)";
    } else {
        $citation = "";
    }
    $nameCitation = "<span class='genus'>".$speciesRow["genus"]."</span>, <span class='citation person'>".$citation."</span>; ";
}
if(!empty($speciesRow["species_authority"])) {
    if(!empty($citationYears)) {
        $citation = $speciesRow["species_authority"]." ".current($citationYears);
        if(toBool($speciesRow["parens_auth_species"])) $citation = "($citation)";
    } else {
        $citation = "";
    }
    if(!empty($citation)) {
        $nameCitation .= "<span class='species'>".$speciesRow["species"]."</span>, <span class='citation person'>".$citation."</span>";
    } else {
        # What if we got it from the IUCN?
        if(empty($nameCitation)) {
            $nameCitation = "<span class='sciname'>".getCanonicalSpecies($speciesRow)."</span>, <span class='citation person iucn-citation'>".$speciesRow["species_authority"]."</span>";
        }
    }
}

$entryTitle = "<h1 class='species-title col-xs-12'>".getCanonicalSpecies($speciesRow)." <small id='species-authority-citation' class='text-muted'>$nameCitation</small></h1><h2 class='species-common col-xs-12'>".$speciesRow["common_name"]."</h2>\n\n";

# Taxonomy notes
$englishMap = array(
    "eutheria" => "placental mammals",
        "metatheria" => "marsupials",
        "prototheria" => "egg-laying mammals (monotremes)",
    );
$taxonomyNotes = "<section id='taxonomy' class='col-xs-12'>
<section class='scientific-taxonomy'><span class='clade'>".$speciesRow["simple_linnean_group"]."</span> &#187; <span class='clade'>".$speciesRow["linnean_order"]."</clade> &#187; <span class='clade'>".$speciesRow["linnean_family"]."</span></section>

<section class='common-taxonomy'>".$englishMap[$speciesRow["simple_linnean_group"]]." &#187; ".$speciesRow["simple_linnean_subgroup"]."</section>
</section>\n\n";

# Any aside / note for this species.
$entryNote = empty($speciesRow["notes"]) ? "" : "<section id='species-note' class='col-xs-12'><h3>Taxon Notes</h3><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["notes"]."</script></marked-element></section>\n\n"; #"<section id='species-note' class='col-xs-12'><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["notes"]."</script></marked-element></section>\n\n";


/***********************************************************************************
 * Images!
 ***********************************************************************************/
## Build an image carousel
# The initial large image should be the one under 'image'
# Others should be linked ones from 'image_resources'

$mammalDomain = "http://www.mammalogy.org";
if(empty($speciesRow["image"])) {
    # Get a picture from the Mammalogy database
    try {
        include_once dirname(__FILE__) . "/phpquery/phpQuery/phpQuery.php";
        if(!class_exists("phpQuery")) throw(new Exception("BadPHPQuery"));
        $url = $mammalDomain . "/search/asm_custom_search/" . urlencode(getCanonicalSpecies($speciesRow));
        $images = "<section id='images-block' class='text-center col-xs-12'><!-- Image from search $url -->";
        $html = file_get_contents($url);
        phpQuery::newDocumentHTML($html);
        $imgElement = pq("#imageLibraryContent #current_image img");
        $imgRelPath = $imgElement->attr("src");
        if(!empty($imgRelPath)) {
        #if(false) {
            $imgPath = $mammalDomain . $imgRelPath;
            $imgHtml = "<img src='$imgPath' />";
            $captionDescription = trim(pq("#imageLibraryContent #image-description")->text());
                $captionDescription = substr($captionDescription, -1) == "." ? $captionDescription : $captionDescription . ".";
            $caption = $captionDescription . " Image credit " . pq("#imageLibraryContent #image-photographer")->text() . " " . pq("#imageLibraryContent #image-date")->text() . ".";
            $figure = "
<figure class='from-mammalogyorg center-block text-center'>
<picture>
$imgHtml
</picture>
<figcaption>
$caption
</figcaption>
</figure>
";
            $images .= $figure;
        } else {
            # We couldn't find a picture in the mammal library. Try
            # iNaturalist.
            #
            # Sample:
            # https://www.inaturalist.org/observations.json?taxon_name=ursus+arctos&quality_grade=research&photo_license=any&iconic_taxa[]=Mammalia&has[]=photos
            $endpoint = "https://www.inaturalist.org/observations.json";
            $postArgs = array(
                "taxon_name" => urlencode(getCanonicalSpecies($speciesRow)),
                "quality_grade" => "research",
                "photo_license" => "any",
                "iconic_taxa[]" => "Mammalia",
                "has[]" => "photos",
            );
            $result = do_post_request($endpoint, $postArgs, "GET");
            $response = json_decode($result["response"], true );
            $images .= "<!-- Pinging iNat: ".$endpoint."?".http_build_query($postArgs)." \n\n Got back from args: ".print_r($postArgs, true)."-->";#" \n\n Result: ".print_r($response, true)." -->";
            $inat = 0;
            if(sizeof($response) > 0) {
                shuffle($response);
                $useObservation = $response[0];
                # First, we have to check that there was a match, and
                # iNat didn't return an unhelpful blob
                $obsTaxon = explode(" ",$useObservation["taxon"]["name"]);
                $refMatchGenus = strlen(substr($speciesRow["genus"], 0, -3)) < 3 ? $speciesRow["genus"] : substr($speciesRow["genus"], 0, -3);
                $refMatchSpecies = strlen(substr($speciesRow["species"], 0, -3)) < 3 ? $speciesRow["species"] : substr($speciesRow["species"], 0, -3);
                $obsMatchGenus = strlen(substr($obsTaxon[0], 0, -3)) < 3 ? strtolower($obsTaxon[0]) : substr(strtolower($obsTaxon[0]), 0, -3);
                $obsMatchSpecies = strlen(substr($obsTaxon[1], 0, -3)) < 3 ? $obsTaxon[1] : substr($obsTaxon[1], 0, -3);
                if($refMatchGenus == $obsMatchGenus || $refMatchSpecies == $obsMatchSpecies) {
                #if(false) {
                    $images .= "\n\n\n<!-- Using observation ".print_r($useObservation, true)." -->\n\n\n";
                    $time = empty($useObservation["time_observed_at_utc"]) ? $useObservation["created_at_utc"] : $useObservation["time_observed_at_utc"];
                    $date = strftime("%d %B %Y", strtotime($time));
                    $photoObj = $useObservation["photos"];
                    // loop?
                    $photo = $photoObj[0];
                    $imageCredit = "Image credit ".$photo["attribution"]." on ". $date . " (<a href='".$useObservation["uri"]."' class='newwindow'>via iNaturalist</a>)";
                    $captionDescription = trim($useObservation["description"]);
                    if(!empty($captionDescription)) {
                        $captionDescription = substr($captionDescription, -1) == "." ? $captionDescription : $captionDescription . ".";
                    }
                    $caption = $captionDescription . " ".$imageCredit;
                    $imgHtml = "<img src='".$photo["small_url"]."'/>";
                    $figure = "
<figure class='from-inaturalist center-block text-center'>
<picture>
<source
sizes='(max-width: 480px) 25vw, (max-width: 768px) 33vw, (max-width: 1024px) 35w, (min-width: 1025px) 40w'
srcset='".$photo["thumb_url"]." 100w,
".$photo["small_url"]." 240w,
".$photo["medium_url"]." 500w,
".$photo["large_url"]." 1024w'
/>
$imgHtml
</picture>
<figcaption>
$caption
</figcaption>
</figure>
";
                    $images .= $figure;
                    $inat++;
                } else {
                    $images .= "\n\n<!-- iNat returned non-matching taxa: checked ".$useObservation["taxon"]["name"]." => $refMatchGenus/$obsMatchGenus|$refMatchSpecies/$obsMatchSpecies -->\n\n";
                }
            }
            if($inat == 0) {
                # iNaturalist failed us too.
                # Last attempt: calPhotos
                # Queries of format: http://calphotos.berkeley.edu/cgi/img_query?getthumbinfo=1&num=all&taxon=ursus+arctos&format=xml
                $endpoint = "http://calphotos.berkeley.edu/cgi/img_query";
                $postArgs = array(
                    "getthumbinfo" => 1,
                    "cconly" => 1,
                    "num" => "all",
                    "taxon" => getCanonicalSpecies($speciesRow),
                    "format" => "xml",
                );
                $dest = $endpoint."?".http_build_query($postArgs);
                $xmlContent = file_get_contents($dest);
                $xml = new Xml();
                $xml->setXml($xmlContent);
                $imgArr = $xml->getAllTagContents("enlarge_jpeg_url");
                if(sizeof($imgArr) > 0) {
                    $copyrightArr = $xml->getAllTagContents("copyright");
                    $licenseArr = $xml->getAllTagContents("license");
                    $enlarge_urlArr = $xml->getAllTagContents("enlarge_url");
                    $images .= "\n\n<!-- Calphotos via $dest : \n\n\n".print_r($imgArr, true)." -->\n\n";
                    $key = array_rand($imgArr);
                    $img = $imgArr[$key];
                    $copyright = $copyrightArr[$key];
                    $license = $licenseArr[$key];
                    $enlarge_url = $enlarge_urlArr[$key];
                    $imgHtml = "<img src='$img' />";
                    $caption = "Image credit " . $copyright . " " . $license . " (via <a href='$enlarge_url' class='newwindow'>CalPhotos</a>).";
                    $figure = "
<figure class='from-mammalogyorg center-block text-center'>
<picture>
$imgHtml
</picture>
<figcaption>
$caption
</figcaption>
</figure>
";
                    $images .= $figure;
                } else {
                    $images .= "<div class='no-image'><p class='text-muted'><em>Sorry, we have no images for this taxon</em></p></div>";
                }
            }
        }
        $images .= "</section>";
    } catch (Exception $e) {
        $images = "<!-- System had exception ".$e->getMessage()." making image block -->";
    }


} else {

$images = "";

}

/***********************************************************************************
 * Wrap up the entry
 ***********************************************************************************/

$speciesRow["entry"] = empty($speciesRow["entry"]) ? "No entry exists for this taxon." : $speciesRow["entry"];

# The main entry.
#  col-md-10 col-lg-6 col-md-offset-2 col-lg-offset-3
$primaryEntry = "<section id='species-account' class='col-xs-12'><h3>Taxon Entry</h3><marked-element><div class='markdown-html'></div><script type='text/markdown'>".$speciesRow["entry"]."</script></marked-element></section>\n\n";

# Credits
$creditTime = strtotime($speciesRow["taxon_credit_date"]);
if($creditTime === false) $creditTime = intval($speciesRow["taxon_credit_date"]);
if(!is_numeric($creditTime) || $creditTime == 0) {
    $creditTime = time();
}


$creditAuthor = empty($speciesRow["taxon_author"]) ? "your local ASM server" : $speciesRow["taxon_credit"];
$credit = "Entry by ".$creditAuthor." on ".strftime("%d %B %Y", $creditTime);
$entryCredits = "<section id='entry-credits' class='col-xs-12 small'><p>".$credit."</p></section>\n\n";

$content = $entryTitle . $images . $taxonomyNotes. $entryNote . $primaryEntry . $entryCredits;

$content .= "<code class='col-xs-12'>Species: ". print_r($speciesRow, true) . "</code>";

$output .= getBody($content);

echo $output;

?>
