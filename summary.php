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
include_once dirname(__FILE__)."/core/core.php";
$db = new DBHelper($default_database, $default_sql_user, $default_sql_password, $default_sql_url, $default_table, $db_cols);
?>
<html>
  <head>
    <?php
      $title = "Taxon Summary Statsitics";
      $pageDescription = "About the Species Account Database";
    ?>
    <title>
    <?php
    echo $title;
    ?>
    </title>
    <?php
    include_once dirname(__FILE__)."/modular/header.php";
    ?>
    <script type="text/javascript" src="bower_components/chart.js/dist/Chart.bundle.min.js"></script>
    <script type="text/javascript" src="js/charts.min.js"></script>
  </head>
    <?php
    require_once dirname(__FILE__)."/modular/bodyFrame.php";
    echo $bodyOpen;
    ?>
      <h1 id="title" class="col-xs-12">
        Taxon Summary Statistics
      </h1>
      <script id="high-level-taxon-data">
      <?php
        # Get the taxon details
        $linneanOrderBinQuery = "select distinct `linnean_order`, count(*) as count from `$default_table` group by `linnean_order`";
        $r = mysqli_query($db->getLink(), $linneanOrderBinQuery);
        $labels = array();
        $data = array();
        while($row = mysqli_fetch_assoc($r)) {
            $labels[] = $row["linnean_order"];
            $data[] = $row["count"];
        }
        echo "var hlTaxonLabels = " . json_encode($labels) . ";";
        echo "var hlTaxonData = " . json_encode($data) . ";";
        ?>
      </script>
      <div class="col-xs-12 clearfix" id="high-level-canvas-container">
        <canvas id="high-level-chart">

        </canvas>
      </div>
      <div class="col-xs-12 clearfix" id="taxon-zoom-canvas-container">
        <canvas id="taxon-zoom-chart">

        </canvas>
      </div>
    <?php
    echo $bodyClose;
    ?>
</html>
