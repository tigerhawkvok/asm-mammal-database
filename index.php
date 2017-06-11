<!DOCTYPE html>
<?php
# $show_debug = true;


if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('Index is running in debug mode!');
    $debug = true; # compat
} else {
    # Rigorously avoid errors in production
    ini_set('display_errors', 0);
}
?>
<html>
  <head>
    <?php
      $title = "ASM Mammal Diversity Database";
      $pageDescription = "The American Society of Mammalogists' searchable database of mammals across the world. Species accounts, photos, geolocation, and more.";
        ?>
    <title><?php echo $title; ?></title>

    <?php include_once dirname(__FILE__)."/modular/header.php"; ?>


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
        <span class="hidden-xs"><a href="https://mammaldiversity.org" class="newwindow"><img src="assets/logo.svg" alt="ASM logo" id="title-logo"/></a></span>
        ASM Mammal <span class="hidden-xs hidden-sm">Diversity</span> Database
      </h1>
      <form id="search_form" onsubmit="event.preventDefault()" class="col-xs-12">
        <div class="row">
          <paper-input label="Search" id="search" name="search" autofocus floatingLabel class="col-xs-7 col-sm-9"></paper-input>
          <div class="col-xs-5 col-sm-3 search-control-container">
            <paper-fab id="do-search" icon="search" raisedButton class="asm-blue"></paper-fab>
            <paper-fab id="do-search-all" icon="list" raisedButton class="asm-blue hidden-xs" data-toggle="tooltip" title="Show all results" data-placement="bottom"></paper-fab>
            <paper-fab id="do-reset-search" icon="cancel" raisedButton class="asm-blue" data-toggle="tooltip" title="Reset search" data-placement="right"></paper-fab>
          </div>
        </div>
        <fieldset class="">
          <legend>Options</legend>
          <section id="search-options-container" class="row">
            <div class="col-md-3 col-xs-6 toggle-container bool-search-option clearfix">
              <paper-icon-button icon="info-outline" data-toggle="tooltip" title="Check this to search all fields with the general search, rather than just scientific and common names. Otherwise, use the advanced options below." class="pull-left"></paper-icon-button>
              <paper-toggle-button id="global_search" class="pull-left">All Fields</paper-toggle-button>
            </div>
            <div class="col-md-3 col-lg-2 col-xs-6 toggle-container bool-search-option">
              <paper-icon-button icon="info-outline" data-toggle="tooltip" title="Check this to do a partial-string search, rather than a exact match." class="pull-left"></paper-icon-button>
              <paper-toggle-button id="loose" class="pull-left">Partial</paper-toggle-button>
            </div>
            <div class="col-md-3 col-lg-2 col-xs-6 toggle-container bool-search-option">
              <paper-icon-button icon="info-outline" data-toggle="tooltip" title="Check this to do a 'close match' search. Check this if you're unsure of your spelling or only have part of the name, for example." class="pull-left"></paper-icon-button>
              <paper-toggle-button id="fuzzy" class="pull-left">Fuzzy</paper-toggle-button>
            </div>
            <div class="col-md-5 col-sm-6 col-xs-12">
              <!-- This is a filter column. We need a radio button for
                   AND/OR, and then to walk through the filters and append the object to the query. -->
              <div class="row">
                <div class="toggle-container col-xs-6 col-md-3">
                  <paper-toggle-button id="use-scientific" class="" checked>Scientific</paper-toggle-button>
                </div>
                <?php
                $renderPage = true;
                try {
                    $as_include = true;
                    include_once dirname(__FILE__)."/api.php";
                    $groups = fetchMajorMinorGroups(true);
                    echo "<script type='text/javascript'> _asm.mammalGroupsBase = ".json_encode($groups["minor"])." ; </script>";
                } catch (Exception $e) {
                    # Do nothing
                    if ($e->getMessage() == "DATABASE_CONNECTION_FAILURE") {
                        # Show an error message about connection
                        require_once dirname(__FILE__)."/admin/CONFIG.php"; ?>
                </div> <!-- Ends the column --></section>
                  <section id="error-db-connection" class="row">
                    <div class="bs-callout bs-callout-danger col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
                      There was a problem communicating with the database.
                      <br/><br/>
                      If this problem persists, <a href="mailto:<?php echo $service_email; ?>?subject=<?php echo urlencode($e->getMessage()); ?>" class="alert-link">email <?php echo $service_email; ?></a> to report the issue, or <a href="<?php echo $gitIssueUrl; ?>" class="newwindow">report a bug on Github</a>.
                    </div>
                  </section>
                    <?php
                      $renderPage = false;
                    } else {
                        # Show a generic "maybe error" message
                        echo "<!-- WARNING GOT ERROR: ".$e->getMessage()." --><pre>got $default_sql_user and $default_database \n\n";
                        throw($e);
                    }
                }
                if ($renderPage) {
                    ?>
              <label for="type" class="sr-only">Clade Restriction</label>
              <paper-menu-button id="simple-linnean-groups" class="col-xs-6 col-md-4">
                <paper-button class="dropdown-trigger"><iron-icon icon="icons:filter-list"></iron-icon><span id="filter-what" class="dropdown-label"></span></paper-button>
                <paper-menu label="Group" data-column="simple_linnean_group" class="cndb-filter dropdown-content" id="linnean" name="type" attrForSelected="data-type" selected="0">
                  <paper-item data-type="any" selected>All</paper-item>
                    <?php
                    try {
                        foreach ($groups["major"] as $major) {
                            echo "<paper-item data-type='$major'>".ucwords($major)."</paper-item>\n";
                        }
                    } catch (Exception $e) {
                        # Do nothing
                        echo "<!-- ".$e->getMessage()."  -->";
                    } ?>
                </paper-menu>
              </paper-menu-button>
              </div>
            </div>
          </section>
          <section id="default-hidden-search-option-container">
            <p class="text-muted">Click below to search specific fields</p>
            <!-- Now, elements that are hidden by default -->
            <paper-button data-toggle="collapse" data-target="#collapse-advanced" aria-expanded="false" aria-controls="collapse-advanced" class="asm-blue-light" id="collapse-button" raised>Advanced Options <iron-icon icon="icons:unfold-more" id="collapse-icon"></iron-icon></paper-button>
            <div class="collapse form-group" id="collapse-advanced">
              <!-- Clade: DWC cohort, magnaorder, and superorder -->
              <paper-input label="Clade" id="major-type-filter" name="major-type-filter" class="cndb-filter col-md-4 col-xs-6" data-column="major_type"></paper-input>
              <!-- Subtype -->
              <paper-input label="Linnean Order" id="major-subtype-filter" name="major-subtype-filter" class="cndb-filter col-md-4 col-xs-6" data-column="linnean_order"></paper-input>
              <!-- Family -->
              <paper-input label="Linnean Family" id="minor-type-filter" name="minor-type-filter" class="cndb-filter col-md-4 col-xs-6" data-column="linnean_family"></paper-input>
              <!-- Genus authority -->
              <paper-input label="Genus Authority" id="genus-authority-filter" name="species-authority-filter" class="cndb-filter col-md-4 col-xs-6" data-column="genus_authority"></paper-input>
              <!-- Species authority -->
              <paper-input label="Species Authority" id="species-authority-filter" name="species-authority-filter" class="cndb-filter col-md-4 col-xs-6" data-column="species_authority"></paper-input>

            </div>
            <?php
                    # Ends the renderPage block -- we close before the section so that the HTML is well formatted
                }
            ?>
          </section>
        </fieldset>
        <input type="submit" style="display:none;" value="Search"/>
      </form>
      <paper-toast id="search-status"></paper-toast>
      <br/>
        <?php
        if ($renderPage) {
            ?>
      <section id="results-section" class="col-xs-12">
        <div id="result-header-container" hidden>
          <h2>Results<span id="result-count"></span></h2>
          <p>Click on an entry for more information.</p>
        </div>
        <div id="result_container" class="table-responsive row">
          <div class="bs-callout bs-callout-info center-block col-xs-12 col-sm-8 col-md-5">
            Search for a common or scientific name above to begin, eg, "Brown Bear" or "<span class="sciname">Ursus arctos</span>"
          </div>
        </div>
      </section>
        <?php
        }
        echo $bodyClose;
        ?>
</html>
