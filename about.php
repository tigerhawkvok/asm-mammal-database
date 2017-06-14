<!DOCTYPE html>
<?php
# $show_debug = true;


if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('about is running in debug mode!');
    $debug = true;
    # compat
} else {
    # Rigorously avoid errors in production
    ini_set('display_errors', 0);
}
include_once dirname(__FILE__)."/CONFIG.php";
?>
<html>
  <head>
    <?php
      $title = "About the Mammal Diversity Database";
      $pageDescription = "About the Mammal Diversity Database";
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
      s.src='//<?php echo $shortUrl; ?>/bower_components/whichbrowser/detect.php?' + p.join('&');d.getElementsByTagName('head')[0].appendChild(s);})();
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
        About the  Database
      </h1>
      <div class="col-xs-12 clearfix">
        <img src="assets/asm-collage-lowres.jpg" class="pull-right" alt="ASM collage"/>
        <p>
          Development for this work was funded by the <a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=1441737" class="newwindow">NSF</a> <a href="http://vertlife.org/" class="newwindow">Vertlife</a> grant and commissioned by the <a href="http://www.mammalsociety.org/about-asm">American Society of Mammalogists</a>.
        </p>
        <p>
          The American Society of Mammalogists (ASM) was founded in 1919. Its primary purpose is to encourage the study of mammals and professions studying mammals. There are over 2,500 members in the composed society,  primarily professional scientists who emphasize the importance of public policy and education.
        </p>
        <p>
          There are several ASM meetings held each year and the society maintains several publications. The flagship publication of the ASM is <i><a href="https://academic.oup.com/jmammal" class="newwindow">The Journal of Mammalogy</a></i>, published six times a year. Other journals include <i>Special Publications</i> and <i><a href="https://academic.oup.com/mspecies" class="newwindow">Mammalian Species</a></i>.
        </p>
      </div>
      <h2 class="col-xs-12">API</h2>
      <p class="col-xs-12">
        Please view <a href="<?php echo $gitUrl; ?>/blob/master/README.md#api"><code>README.md</code> in the Github repository</a> for information on how to use our public taxon API. The API endpoint can be found at <code><a href="<?php echo $protocol; ?>://$shortUrl/api/q=ursus+arctos" class="newwindow"><?php echo $protocol; ?>://$shortUrl/api</a></code>.
        </p>
      <h2 class="col-xs-12">Legal Notices</h2>
      <h3 class="col-xs-12">Application</h3>
      <p class="col-xs-12">
      This software is released under the <a href="https://choosealicense.com/licenses/gpl-3.0/" class="newwindow">GNU GPL v3 license</a>, and the source code is available <a href="<?php echo $gitUrl;
?>" class="newwindow">on Github</a>. Licenses for dependencies and are either included in the directory for the package, or in the file <code>PACKAGE-LICENSES</code> in the respository.
      </p>
      <h3 class="col-xs-12">Images</h3>
      <p class="col-xs-12">
      Taxon images used in this application are licensed with the <a href="https://choosealicense.com/licenses/cc-by-4.0/" class="newwindow">Creative Commons BY 4.0 license</a>, except where otherwise noted.
      </p>
      <h3 class="col-xs-12">Content</h3>
      <p class="col-xs-12">
      All information and content is licensed with the <a href="https://choosealicense.com/licenses/cc-by-4.0/" class="newwindow">Creative Commons BY 4.0 license</a>. A full citation for any given entry can be found on the account page, or under the <code>dcterms:bibliographicCitation</code> key on the API result for a given taxon.
      </p>
        <?php
        echo $bodyClose;
?>
</html>
