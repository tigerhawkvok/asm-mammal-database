<?php

$lastIcon = "<paper-icon-button icon=\"glyphicon-social:playing-dice\" class=\"click\" data-fn=\"getRandomEntry\" data-toggle=\"tooltip\" title=\"Random Entry\" data-placement=\"bottom\"></paper-icon-button>";

if (basename($_SERVER["PHP_SELF"]) == "index.php") {
    # lastIcon is fine
} else {
    $lastIcon .= "<paper-icon-button icon=\"icons:home\" class=\"click\" data-href=\"https://mammaldiversity.org\" data-toggle=\"tooltip\" title=\"Home\" data-placement=\"bottom\"></paper-icon-button>";
}

$bodyOpen = "  <body fullbleed vertical layout class='container-fluid'>
    <header id=\"header-bar\" class=\"fixed-bar clearfix row\">
      <div class=\"logo-container col-xs-2\">
        <div class=\"square-object\">
          <div class=\"square tile\">
            <img src=\"assets/favicon512.png\" alt=\"ASM logo\" class=\"content click\" data-href=\"http://mammology.org/\" data-newtab=\"true\" title='Visit Mammalogy.org' data-toggle='tooltip' data-placement='bottom'/>
          </div>
          </div>
          </div>
          <p class=\"col-xs-10 text-right\">
          <span class=\"logged-in-values\" hidden>
          Logged in as <span class=\"fill-user-fullname header-bar-user-name\"></span>
          </span>
          <paper-icon-button icon=\"icons:dashboard\" class=\"click logged-in-values\" data-href=\"https://mammaldiversity.org/admin-page.html\" data-toggle=\"tooltip\" title=\"Administration Dashboard\" data-placement=\"bottom\" hidden> </paper-icon-button>
          <paper-icon-button icon='icons:settings-applications' class=\"click logged-in-values\" data-href=\"https://mammaldiversity.org/admin\" data-toggle=\"tooltip\" title=\"Account Settings\" data-placement=\"bottom\" hidden></paper-icon-button>
          <paper-icon-button icon='icons:info-outline' class=\"click\" data-href=\"https://mammaldiversity.org/about\" data-toggle=\"tooltip\" title=\"About\" data-placement=\"bottom\"></paper-icon-button>
          <paper-icon-button icon='editor:insert-chart' class=\"click\" data-href=\"https://mammaldiversity.org/summary\" data-toggle=\"tooltip\" title=\"Summary Statistics\" data-placement=\"bottom\"></paper-icon-button>
          ".$lastIcon."
          </p>
          </header>
<main class='row'>";
$bodyClose = "\n\t\t</main>\n\n".get_include_contents(dirname(__FILE__) . "/footer.php")."\n\n\t</body>";
