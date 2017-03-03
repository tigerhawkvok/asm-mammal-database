<!DOCTYPE html>
<html>
  <head>
    <?php
      $title = "American Society Of Mammalogists - Species Account Database";
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
  <body class="container-fluid">
    <main class="row">
      <h1 id="title" class="col-xs-12">
        <span class="hidden-xs"><a href="https://mammaldiversity.org" class="newwindow"><img src="assets/logo.svg" alt="SSAR logo" id="title-logo"/></a></span>
        ASM Species <span class="hidden-xs hidden-sm">Account</span> Database
      </h1>
      <form id="search_form" onsubmit="event.preventDefault()" class="col-xs-12">
        <div class="row">
          <paper-input label="Search" id="search" name="search" required autofocus floatingLabel class="col-xs-7 col-sm-9"></paper-input>
          <div class="col-xs-5 col-sm-3">
            <paper-fab id="do-search" icon="search" raisedButton class="asm-blue"></paper-fab>
            <paper-fab id="do-search-all" icon="list" raisedButton class="asm-blue hidden-xs" data-toggle="tooltip" title="Show all results" data-placement="bottom"></paper-fab>
            <paper-fab id="do-reset-search" icon="cancel" raisedButton class="asm-blue" data-toggle="tooltip" title="Reset search" data-placement="right"></paper-fab>
          </div>
        </div>
        <fieldset class="fullwidth">
          <legend>Options</legend>
          <div class="row">
            <div class="col-md-4 col-xs-6">
              <label for="loose">Loose</label> <paper-icon-button icon="info-outline" data-toggle="tooltip" title="Check this to do a partial-string search, rather than a strict exact match."></paper-icon-button>
              <paper-toggle-button id="loose"></paper-toggle-button>
            </div>
            <div class="col-md-4 col-xs-6">
              <label for="fuzzy">Fuzzy</label>  <paper-icon-button icon="info-outline" data-toggle="tooltip" title="Check this to do a 'close match' search. Check this if you're unsure of your spelling or only have part of the name, for example."></paper-icon-button>
              <paper-toggle-button id="fuzzy"></paper-toggle-button>
            </div>
            <div class="col-md-4 col-sm-6 col-xs-12">
              <!-- This is a filter column. We need a radio button for
                   AND/OR, and then to walk through the filters and append the object to the query. -->
              <?php
                $as_include = true;
                include_once dirname(__FILE__)."/api.php";
                $groups = fetchMajorMinorGroups(true);
                echo "<script type='text/javascript'> _asm.mammalGroupsBase = ".json_encode($groups["minor"])." ; </script>"
                ?>
              <label for="type" class="sr-only">Clade Restriction</label>
              <paper-menu-button id="simple-linnean-groups">
                <paper-button class="dropdown-trigger"><iron-icon icon="icons:filter-list"></iron-icon><span id="filter-what" class="dropdown-label"></span></paper-button>
                <paper-menu label="Group" data-column="simple_linnean_group" class="cndb-filter dropdown-content" id="linnean" name="type" attrForSelected="data-type" selected="0">
                  <paper-item data-type="any">All</paper-item>
                  <?php
                    try {
                    echo "<!--".print_r($groups, true)."-->\n\n";
                    foreach($groups["major"] as $major) {
                    echo "<paper-item data-type='$major'>".ucwords($major)."</paper-item>\n";
                    }
                    } catch (Exception $e) {
                    # Do nothing
                    echo "<!-- ".$e->getMessage()."  -->";
                    }
                  ?>
                </paper-menu>
              </paper-menu-button>
            </div>
          </div>
          <div>
            <!-- Now, elements that are hidden by default -->
            <paper-button data-toggle="collapse" data-target="#collapse-advanced" aria-expanded="false" aria-controls="collapse-advanced" class="asm-blue-light" id="collapse-button" raised>Advanced Options <iron-icon icon="icons:unfold-more" id="collapse-icon"></iron-icon></paper-button>
            <div class="collapse form-group" id="collapse-advanced">
              <!-- Clade -->
              <paper-input label="Clade" id="major-type-filter" name="major-type-filter" class="cndb-filter col-md-4 col-xs-6" data-column="major_type"></paper-input>
              <!-- Subtype -->
              <paper-input label="Subtype" id="major-subtype-filter" name="major-subtype-filter" class="cndb-filter col-md-4 col-xs-6" data-column="major_subtype"></paper-input>
              <!-- Family -->
              <paper-input label="Minor Type / Family" id="minor-type-filter" name="minor-type-filter" class="cndb-filter col-md-4 col-xs-6" data-column="minor_type"></paper-input>
              <!-- Genus authority -->
              <paper-input label="Genus Authority" id="genus-authority-filter" name="species-authority-filter" class="cndb-filter col-md-4 col-xs-6" data-column="genus_authority"></paper-input>
              <!-- Species authority -->
              <paper-input label="Species Authority" id="species-authority-filter" name="species-authority-filter" class="cndb-filter col-md-4 col-xs-6" data-column="species_authority"></paper-input>
              <br/>
              <div>
                <label for="alien-filter" class="sr-only">Alien Species</label>
                <paper-radio-group id="alien-filter" selected="both">
                  <paper-radio-button name="both" id="radio-both">Show both alien and native species</paper-radio-button>
                  <paper-radio-button name="native-only" id="radio-native">Show only native species</paper-radio-button>
                  <paper-radio-button name="alien-only" id="radio-alien">Show only alien species</paper-radio-button>
                </paper-radio-group>
              </div>
            </div>
          </div>
        </fieldset>
        <input type="submit" style="display:none;" value="Search"/>
      </form>
      <paper-toast id="search-status"></paper-toast>
      <br/>
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
    </main>
    <footer class="row  hidden-xs">
      <div class="col-lg-7 col-sm-6">
        <copyright-statement copyrightStart="2017">American Society of Mammalogists</copyright-statement>
      </div>
      <div class="col-sm-2" id="git-footer">
        <paper-icon-button icon="icons:cloud-download" class="click" data-function="showDownloadChooser" data-toggle="tooltip" title="Download the complete list (HTML or CSV)"></paper-icon-button>
        <paper-icon-button icon="glyphicon-social:github" class="click" data-url="https://github.com/tigerhawkvok/asm-mammal-database" data-toggle="tooltip" title="Visit us on GitHub"></paper-icon-button>
      </div>
      <div class="col-lg-1 col-sm-2" id="bug-footer">
        <paper-icon-button icon="icons:bug-report" class="click" data-url="https://github.com/tigerhawkvok/asm-mammal-database/issues/new" data-toggle="tooltip" title="Report a bug"></paper-icon-button>
      </div>
      <div class="col-sm-2" id="polymer-footer">
        Written with <paper-icon-button icon="icons:polymer" class="click" data-url="https://www.polymer-project.org"></paper-icon-button>
      </div>
    </footer>
  </body>
</html>
