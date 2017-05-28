<!doctype html>
<html lang="en">
  <head>
    <title>
      <?php
      $title = "HTTP 403 FORBIDDEN";
      echo $title;
      ?>
    </title>
        <base href="https://mammaldiversity.org/" />
    <?php include_once dirname(__FILE__)."/modular/header.php"; ?>

  </head>
  <?php
    require_once dirname(__FILE__)."/modular/bodyFrame.php";
    echo $bodyOpen;
    ?>

  <div class="col-xs-12">
    <h1>Not so much.</h1>
    <div class="col-xs-12 error-image">
      <video autoplay loop poster="https://media.giphy.com/media/njYrp176NQsHS/200_s.gif">
        <source src="https://media.giphy.com/media/njYrp176NQsHS/giphy.mp4" type="video/mp4"/>
        <img src="https://media.giphy.com/media/njYrp176NQsHS/giphy.gif" />
      </video>
    </div>
    <p class="col-xs-12">
      Or, in web parlance, <code>403 FORBIDDEN</code>
    </p>
  </div>
  <?php echo $bodyClose;
  ?>
  </html>
