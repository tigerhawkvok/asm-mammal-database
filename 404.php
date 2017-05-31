<!doctype html>
<html lang="en">
  <head>
    <title>
      <?php
      $title = "HTTP 404 NOT FOUND";
      echo $title;
      ?>
    </title>
    <base href="https://mammaldiversity.org/" />
    <?php include_once dirname(__FILE__)."/modular/header.php"; ?>

  </head>
  <?php
    require_once dirname(__FILE__)."/modular/bodyFrame.php";
    echo $bodyOpen
    ?>
    <h1 class="col-xs-12">Lost?</h1>
    <div class="col-xs-12 error-image">
      <video autoplay loop poster="https://media.giphy.com/media/9J7tdYltWyXIY/200_s.gif">
        <source src="https://media.giphy.com/media/9J7tdYltWyXIY/giphy.mp4" type="video/mp4"/>
        <img src="https://media.giphy.com/media/9J7tdYltWyXIY/giphy.gif" />
      </video>
    </div>
  <p class="col-xs-12">
    Nope, nothing there. Or, in web parlance, <code>404 NOT FOUND</code>. Try one of the links in the header to get you to someplace that actually exists :-)
  </p>
  <?php echo $bodyClose; ?>
</html>
