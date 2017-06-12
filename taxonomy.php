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
include_once dirname(__FILE__)."/CONFIG.php";
  
  
  
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
        /***
         * To find migrations, find species with species authories
         * younger than the modified date, but genus authories newer
         ***/
        ?>
      </div>      
        <?php
        echo $bodyClose;
?>
</html>
