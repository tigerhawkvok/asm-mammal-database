<!DOCTYPE html>
<?php
# $show_debug = true;


if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('summary stats is running in debug mode!');
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
      $title = "Taxon Summary Statsitics";
      $pageDescription = "About the Species Account Database";
?>
    <title><?php echo $title;
?></title>
    <?php 
    include_once dirname(__FILE__)."/modular/header.php";

?>
  </head>
    <?php
    require_once dirname(__FILE__)."/modular/bodyFrame.php";
    echo $bodyOpen;
?>
      <h1 id="title" class="col-xs-12">
        Taxon Summary Statistics
      </h1>
      <div class="col-xs-12 clearfix">
      </div>
        <?php
        echo $bodyClose;
?>
</html>
