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
        $fail = false;
        try {
            $db = new DBHelper($default_database, $default_sql_user, $default_sql_password, $default_sql_url, $default_table, $db_cols);
        } catch (Exception $e) {
            $fail = true;
            ?>
      </script>
      <div class="col-xs-12">
        <section id="error-db-connection" class="row">
          <div class="bs-callout bs-callout-danger col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
            There was a problem communicating with the database.
            <br/><br/>
            If this problem persists, <a href="mailto:support@velociraptorsystems.com?subject=DATABASE_CONNECTION_FAILURE" class="alert-link">email support@velociraptorsystems.com</a> to report the issue, or <a href="https://github.com/tigerhawkvok/asm-mammal-database/issues/new" class="newwindow">report a bug on Github</a>.
          </div>
        </section>
      </div>
      <script>
            <?php
        }
        if (!$fail) {
            # Get the taxon details
            $linneanOrderBinQuery = "select distinct `linnean_order`, count(*) as count from `".$db->getTable()."` group by `linnean_order`";
            $r = mysqli_query($db->getLink(), $linneanOrderBinQuery);
            $labels = array();
            $data = array();
            $speciesTotal = 0;
            while ($row = mysqli_fetch_assoc($r)) {
                $labels[] = ucwords($row["linnean_order"]);
                $data[] = $row["count"];
                $speciesTotal += $row["count"];
            }
            $genusBreakdown = array();
            $genusTotal = 0;
            foreach ($labels as $taxon) {
                $genusBinQuery = "select distinct `genus`, count(*) as count from `".$db->getTable()."` where `linnean_order`='$taxon' group by `genus`";
                $tmpLabels = array();
                $tmpData = array();
                $r = mysqli_query($db->getLink(), $genusBinQuery);
                while ($row = mysqli_fetch_assoc($r)) {
                    $tmpLabels[] = ucwords($row["genus"]);
                    $tmpData[] = $row["count"];
                    $genusTotal++;
                }
                $genusBreakdown[$taxon] = array(
                    "data" => $tmpData,
                    "labels" => $tmpLabels,
                );
            }
            echo "var hlTaxonLabels = " . json_encode($labels) . ";\n\n";
            echo "var hlTaxonData = " . json_encode($data) . ";\n\n";
            echo "var genusData = " . json_encode($genusBreakdown) . ";\n\n";
        }
        ?>
      </script>
      <section class="col-xs-12 clearfix">
        <div class="table-responsive">
          <table class="table-bordered table table-striped table-condensed">
            <thead>
              <tr>
                <th>Orders</th>
                <th>Genera</th>
                <th>Species</th>
                <th>View Taxonomy Info</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                    <?php echo sizeof($labels); ?>
                </td>
                <td>
                    <?php echo $genusTotal; ?>
                </td>
                <td>
                  <?php echo $speciesTotal; ?>
                </td>
                <td>
                    <a class="btn btn-primary" href="<?php echo $qualDomain;?>/taxonomy">
                        Visit Taxonomy Page
                    </a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
      <section class="col-xs-12 clearfix" id="high-level-canvas-container">
        <aside>
          <div class="panel panel-default">
            <div class="panel-heading">
              <h3 class="panel-title">
                Chart Configuration Options
              </h3>
            </div>
            <div class="panel-body">
              <paper-toggle-button id="log-scale" checked>Log Scale</paper-toggle-button>
              <paper-toggle-button id="default-sort-toggle" checked>Use Default Sort</paper-toggle-button>
              <div>
                <paper-dropdown-menu label="Order Sort" id="order-sort"  class="chart-param sort-options" data-key="order_sort" disabled>
                  <paper-listbox class="dropdown-content" selected="0">
                    <paper-item data-value="linnean_order">Order</paper-item>
                    <paper-item data-value="count">Member Count</paper-item>
                  </paper-listbox>
                </paper-dropdown-menu>

                <paper-dropdown-menu label="Genus Sort" id="genus-sort"  class="chart-param sort-options" data-key="genus_sort" disabled>
                  <paper-listbox class="dropdown-content" selected="0">
                    <paper-item data-value="genus">Genus</paper-item>
                    <paper-item data-value="count">Member Count</paper-item>
                  </paper-listbox>
                </paper-dropdown-menu>
              </div>
            </div>
          </aside>
          <canvas id="high-level-chart">

          </canvas>
        </div>
      </section>
      <p class="col-xs-12">
        Click on a taxon above to see a more detailed breakdown.
      </p>
      <br/><br/>
      <h2 id="zoom-taxon-label" class="col-xs-12">

      </h2>
      <div class="col-xs-12 clearfix" id="taxon-zoom-canvas-container">
        <canvas id="taxon-zoom-chart">

        </canvas>
      </div>
    <?php
    echo $bodyClose;
    ?>
</html>
