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
      <h1 class="col-xs-12 citation-block">
        How to Cite
      </h1>
      <div class="col-xs-12 clearfix">
        <img src="assets/asm-collage-lowres.jpg" class="pull-right" alt="ASM collage"/>
        <p><strong>The Database:</strong></p>
        <blockquote><cite class="citation-block">Mammal Diversity Database. <?php echo date('Y'); ?>. <span class="uri">www.mammaldiversity.org</span>. American Society of Mammalogists. Accessed <?php echo date('Y-m-d'); ?> .</cite>
        </blockquote>
        <p><strong>A specific entry:</strong></p>
        <p>Each entry has a citation string at the end. For example:</p>
        <blockquote>
            <cite class="citation-block"><span class="taxon">Mus musculus</span> (ASM Mammal Diversity Database #13972) fetched 2018-02-05. Mammal Diversity Database. 2018. [<span class="uri">https://mammaldiversity.org/species-account/species-id=13972</span>]</cite>
        </blockquote>
        <p><strong>Version 1.0 taxonomy:</strong></p>
        <blockquote>
            <cite class="citation-block">
                Burgin, C. J., Colella, J. P., Kahn, P. L., and Upham, N. S. 2018. How many species of mammals are there? Journal of Mammalogy 99:1&#8212;11. [<span class='uri'>https://doi.org/10.1093/jmammal/gyx147</span>]
            </cite>
        </blockquote>

      </div>
      <h1 id="title" class="col-xs-12">
        About the  Database
      </h1>
      <div class="col-xs-12 clearfix">
        <p>
          Development for this work is funded by <a href="http://www.mammalsociety.org/about-asm" class="newwindow">American Society of Mammalogists</a> with logistical and planning support from the <a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=1441737" class="newwindow">NSF</a> <a href="http://vertlife.org/" class="newwindow">Vertlife Terrestrial</a> grantand commissioned by the <a href="http://www.mammalsociety.org/about-asm">American Society of Mammalogists</a>.
        </p>
        <p>
          The <a href="http://www.mammalsociety.org/committees/mammal-biodiversity">ASM Biodiversity Committee</a>
          stewards the Mammal Diversity Database, an updatable and
          online database of mammal taxonomic and biodiversity
          information. This database aims to serve the global
          scientific community by providing the latest information on
          species-level and higher taxonomic changes, thereby
          promoting more rigorous study of mammalian biodiversity
          worldwide. The initial objective for this online database is
          to aggregate, curate, and compile new citations on species
          descriptions and taxonomic revisions into regular releases
          that are downloadable in comma-delimited format. Downstream
          goals include expanded hosting of ecological, trait, and
          taxonomic data, and an online forum for discussing mammalian
          taxonomy and systematics. By serving as both a platform and
          forum, this initiative aims to stimulate interest in mammals
          and promote the ASM’s role as a leader in high quality
          research on mammalian biology.
        </p>
      </div>
      <h2 class="col-xs-12">API</h2>
      <p class="col-xs-12">
        Please view <a href="<?php echo $gitUrl; ?>/blob/master/README.md#api"><code>README.md</code> in the Github repository</a> for information on how to use our public taxon API. The API endpoint can be found at <code><a href="<?php echo $protocol; ?>://<?php echo $shortUrl; ?>/api/q=ursus+arctos" class="newwindow"><?php echo $protocol; ?>://<?php echo $shortUrl; ?>/api</a></code>. You can also do an interactive live query against the database by clicking the <iron-icon icon="icons:code"></iron-icon> button in the footer of any page.
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
