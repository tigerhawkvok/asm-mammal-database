<?php
require dirname(__FILE__) . "/../CONFIG.php";

$protocol = isset($_SERVER['HTTPS']) ? "https" : "http";

$lastIcon = "<paper-icon-button icon=\"glyphicon-social:playing-dice\" class=\"click visible-xs logged-in-hidden\" data-fn=\"getRandomEntry\" data-toggle=\"tooltip\" title=\"Random Entry\" data-placement=\"bottom\"></paper-icon-button>
<paper-button class=\"click hidden-xs\" data-fn=\"getRandomEntry\">Random <iron-icon icon=\"glyphicon-social:playing-dice\"></iron-icon></paper-button>";

if (basename($_SERVER["PHP_SELF"]) == "index.php") {
    # lastIcon is fine
} else {
    $lastIcon .= "<paper-icon-button icon=\"icons:home\" class=\"click\" data-href=\"$protocol://$domain\" data-toggle=\"tooltip\" title=\"Home\" data-placement=\"bottom\"></paper-icon-button>";
}

$bodyOpen = "  <body fullbleed vertical layout class='container-fluid'>
    <header id=\"header-bar\" class=\"fixed-bar clearfix row\">
      <div class=\"logo-container col-xs-2\">
        <div class=\"square-object\">
          <div class=\"square tile\">
            <img src=\"assets/favicon512.png\" alt=\"ASM logo\" class=\"content click\" data-href=\"http://www.mammalsociety.org/\" data-newtab=\"true\" title='Visit MammalogySociety.org' data-toggle='tooltip' data-placement='bottom'/>
          </div>
          </div>
          </div>
          <p class=\"col-xs-10 text-right\">
          <span class=\"logged-in-values\" hidden>
          <span class='hidden-xs'>Logged in as </span><span class=\"fill-user-fullname header-bar-user-name click\" data-href=\"$protocol://$domain/admin-page.html\" ></span>
          </span>
          <paper-icon-button icon=\"icons:dashboard\" class=\"click logged-in-values hidden-xs\" data-href=\"$protocol://$domain/admin-page.html\" data-toggle=\"tooltip\" title=\"Administration Dashboard\" data-placement=\"bottom\" hidden> </paper-icon-button>
          <paper-icon-button icon='icons:settings-applications' class=\"click logged-in-values hidden-xs\" data-href=\"$protocol://$domain/admin\" data-toggle=\"tooltip\" title=\"Account Settings\" data-placement=\"bottom\" hidden></paper-icon-button>
          <paper-icon-button icon='icons:info-outline' class=\"click visible-xs\" data-href=\"$protocol://$domain/about\" data-toggle=\"tooltip\" title=\"About\" data-placement=\"bottom\"></paper-icon-button>
          <paper-button class=\"click hidden-xs\" data-href=\"$protocol://$domain/about\">About <iron-icon icon='icons:info-outline'></iron-icon></paper-button>
          <paper-icon-button icon='editor:insert-chart' class=\"click visible-xs\" data-href=\"$protocol://$domain/summary\" data-toggle=\"tooltip\" title=\"Summary Statistics\" data-placement=\"bottom\"></paper-icon-button>
          <paper-button class=\"click hidden-xs\" data-href=\"$protocol://$domain/summary\" >Statistics <iron-icon icon='editor:insert-chart'></iron-icon></paper-button>
          <paper-icon-button icon='social:people' class=\"click visible-xs\" data-href=\"$protocol://forum.$domain\" data-toggle=\"tooltip\" title=\"Forum\" data-placement=\"bottom\"></paper-icon-button>
          <paper-button class=\"click hidden-xs\" data-href=\"$protocol://forum.$domain\" >Forum <iron-icon icon='social:people'></iron-icon></paper-button>
          ".$lastIcon."
          </p>
          </header>
<main class='row'>";
$bodyClose = "\n\t\t</main>\n\n".get_include_contents(dirname(__FILE__) . "/footer.php")."\n\n\t</body>";
