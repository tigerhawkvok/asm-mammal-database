<!DOCTYPE html>
<?php

/***
 *
 *
 * See:
 * https://github.com/tigerhawkvok/asm-mammal-database/issues/50
 ***/

# $show_debug = true;


if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('taxonomy is running in debug mode!');
    $debug = true;
    # compat
} else {
    # Rigorously avoid errors in production
    ini_set('display_errors', 0);
}
require dirname(__FILE__)."/CONFIG.php";
require_once(dirname(__FILE__)."/core/core.php");
$db = new DBHelper($default_database, $default_sql_user, $default_sql_password, $default_sql_url, $default_table, $db_cols);


$updatesSinceAssessmentYear = 2005;

?>
<html>
  <head>
    <?php
      $title = "Taxonomy Information";
      $pageDescription = "Information about recent taxonomy changes and mammal taxonomy assignment";
?>
    <title><?php echo $title;
?></title>
    <?php include_once dirname(__FILE__)."/modular/header.php";
?>
    <script type="text/javascript">
      (function(){var p=[],w=window,d=document,e=f=0;p.push('ua='+encodeURIComponent(navigator.userAgent));e|=w.ActiveXObject?1:0;e|=w.opera?2:0;e|=w.chrome?4:0;
      e|='getBoxObjectFor' in d || 'mozInnerScreenX' in w?8:0;e|=('WebKitCSSMatrix' in w||'WebKitPoint' in w||'webkitStorageInfo' in w||'webkitURL' in w)?16:0;
      e|=(e&16&&({}.toString).toString().indexOf("\n")===-1)?32:0;p.push('e='+e);f|='sandbox' in d.createElement('iframe')?1:0;f|='WebSocket' in w?2:0;
      f|=w.Worker?4:0;f|=w.applicationCache?8:0;f|=w.history && history.pushState?16:0;f|=d.documentElement.webkitRequestFullScreen?32:0;f|='FileReader' in w?64:0;
      p.push('f='+f);p.push('r='+Math.random().toString(36).substring(7));p.push('w='+screen.width);p.push('h='+screen.height);var s=d.createElement('script');
      s.src='//mammaldiversity.org/bower_components/whichbrowser/detect.php?' + p.join('&');d.getElementsByTagName('head')[0].appendChild(s);})();
      /*window.onerror = function(e) {
      console.warn("Error thrown: "+e);
      return true;
      }*/
    </script>
  </head>
    <?php
    require_once dirname(__FILE__)."/modular/bodyFrame.php";
    echo $bodyOpen;
?>
      <h1 id="title" class="col-xs-12">
        Taxonomy Information
      </h1>
      <h2 class="col-xs-12">Data Differences from MSW3</h2>
      <div class="col-xs-12 clearfix">
        <?php
        /***
         * To find new taxa, check the authories newer than $updatesSinceAssessmentYear
         ***/
        $yearsToCheck = array();
        # Because of the way we stored the authorities,
        # we want to enumerate all the years between then and now
        $thisYear = date("Y");
        $examinedYear = $updatesSinceAssessmentYear;
        while ($examinedYear < $thisYear) {
            $examinedYear++;
            $yearsToCheck[] = $examinedYear;
        }
        $taxa = array();
        foreach ($yearsToCheck as $year) {
            $searchCriteria = array(
                "authority_year" => strval($year),
                "species_authority" => strval($year),
                "genus_authority" => strval($year),
            );
            $results = $db->getQueryResults($searchCriteria, "*", "OR", true, true);
            $taxa = array_merge($taxa, $results);
        }

        $buffer = "";
        $migratedTaxa = array();
        $novelTaxa = array();
        foreach ($taxa as $taxon) {
            $years = json_decode($taxon["authority_year"], true);
            if (!is_array($years)) {
                $gYear = preg_replace('/^.*?([0-9]{4}).*$/im', '$1', $taxon["genus_authority"]);
                $sYear = preg_replace('/^.*?([0-9]{4}).*$/im', '$1', $taxon["species_authority"]);
            } else {
                $gYear = key($years);
                $sYear = current($years);
            }
            if (empty($gYear)) {
                $gYear = $sYear;
            } elseif (empty($sYear)) {
                $sYear = $gYear;
            }
            $sYear = intval($sYear);
            $gYear = intval($gYear);
            if ($sYear < $gYear) {
                # This is a migrated taxon
                $migratedTaxa[] = $taxon;
                continue;
            } else {
                # Either this was added to an existing genus
                # Or created at the same time
                # In either case, we want the species authority
                $novelTaxa[] = $taxon;
                $authority = preg_replace('/^(.*?)[,;:]? *(?:[0-9]{4})? *$/im', '$1', $taxon["species_authority"]);
                $authority = html_entity_decode($authority);
            }
            $year = $sYear > $gYear ? $sYear : $gYear;
            if (!empty($taxon["species_authority_citation"])) {
                if (stripos($taxon["species_authority_citation"], "isbn")) {
                    $citation = $taxon["species_authority_citation"];
                } else {
                    $citation = "<a href='http://dx.doi.org/".$taxon["species_authority_citation"]."' class='newwindow doi btn btn-xs btn-primary'>doi:".$taxon["species_authority_citation"]."</a>";
                }
            } else {
                $citation = "";
            }
            $buffer .= "\n<li><span class='sciname'><span class='genus'>".$taxon["genus"]."</span> <span class='species'>".$taxon["species"]."</span></span> in <span class='has-authority' data-toggle='tooltip' title='$authority'>$year</span> <paper-icon-button class='click' data-href='$protocol://$domain/species-account/id=".$taxon["id"]."' icon='icons:visibility' title='See account for ".ucwords($taxon["genus"])." ".$taxon["species"]."' data-toggle='tooltip'></paper-icon-button> $citation</li>\n";
        }
        echo "<h3>There have been ".sizeof($novelTaxa)." taxa changes since $updatesSinceAssessmentYear</h3> <ul>";
        echo $buffer;
        echo "</ul>";
        /***
         * To find migrations, find species with species authories
         * younger than the modified date, but genus authories newer
         ***/
        echo "<h3>There have been ".sizeof($migratedTaxa)." taxa with genus migrations since $updatesSinceAssessmentYear</h3> <ul>";
        foreach ($migratedTaxa as $taxon) {
            # Do the thing, Ju-Li!
            continue;
        }
        echo "</ul>"
        ?>
      </div>
        <?php
        echo $bodyClose;
?>
</html>
