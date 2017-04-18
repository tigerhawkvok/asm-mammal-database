<!doctype html>
<html lang="en">
  <head>
    <title>
      <?php
      $title = "HTTP 500 INTERNAL SERVER ERROR";
      echo $title;
      ?>
    </title>
        <base href="http://localhost/~Philip/" />
    <?php include_once dirname(__FILE__)."/modular/header.php"; ?>

  </head>
  <?php
    require_once dirname(__FILE__)."/modular/bodyFrame.php";
    echo $bodyOpen;
    ?>

  <div class="col-xs-12">
    <h1>Yikes.</h1>
    <p class="col-xs-12">
      That's an error. Our system isn't able to handle your request.
    </p>
    <div class="col-xs-12 error-image">
      <!-- <img src="https://http.cat/500.jpg" alt="HTTP 500 errror" /> -->
      <img src="https://media.giphy.com/media/1eUtlOkkugRX2/giphy.gif" alt="HTTP 500 errror" />
    </div>
    <p class="col-xs-12">
      Or, in web parlance, <code>500 INTERNAL SERVER ERROR</code>
    </p>
  </div>
  <?php echo $bodyClose;
  ?>
  </html>
