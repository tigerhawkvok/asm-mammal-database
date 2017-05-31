<?php ?>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta charset="utf-8"/>
<meta name="theme-color" content="#446f74"/>
<meta name="viewport" content="width=device-width, minimum-scale=1,initial-scale=1" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />

<?php
  $description = "The American Society of Mammalogists Species Account Database";
  $pageDescription = empty($pageDescription) ? $description:$pageDescription;

?>

<meta name="description" content="<?php echo $pageDescription; ?>"/>


<?php
  if (!empty($prefetch)) {
      if (!is_array($prefetch)) {
          $prefetch_arr = array($prefetch);
      } else {
          $prefetch_arr = $prefetch;
      }
      foreach ($prefetch_arr as $prefetch) {
          ?>
<link rel="prefetch" href="<?php echo $prefetch; ?>" />
<?php

      }
  }
  if (!empty($prerender)) {
      ?>
<link rel="prerender" href="<?php echo $prerender; ?>" />
<?php

  }
  ?>


<link rel='shortcut icon' type='image/vnd.microsoft.icon' sizes='32x32' href='assets/favicon.ico' />
<link rel="icon" type="image/png" sizes="16x16" href="assets/favicon16.png" />
<link rel="icon" type="image/png" sizes="32x32" href="assets/favicon32.png" />
<link rel="icon" type="image/png" sizes="64x64" href="assets/favicon64.png" />
<link rel="icon" type="image/png" sizes="128x128" href="assets/favicon128.png" />
<link rel="icon" type="image/png" sizes="256x254" href="assets/favicon256.png" />
<link rel="icon" type="image/png" sizes="512x512" href="assets/favicon512.png" />
<link rel="icon" type="image/png" sizes="1024x1024" href="assets/favicon1024.png" />
<link rel="icon" type="image/png" sizes="2048x2048" href="assets/favicon2048.png" />
<link rel="icon" type="image/svg+xml" href="assets/logo.svg" />
<link rel="manifest" href="/manifest.json" />

<link href="css/main.min.css" rel='stylesheet' type='text/css'/>


<!-- Icons -->
<link href="css/glyphicons-bootstrap.css" rel='stylesheet' type='text/css'/>
<link href="css/glyphicons.css" rel='stylesheet' type='text/css'/>
<link rel="stylesheet" type="text/css" href="bower_components/octicons/octicons/octicons.css"/>

<link href='https://fonts.googleapis.com/css?family=Roboto:regular,bold,italic,thin,light,bolditalic,black,medium&amp;lang=en' rel='stylesheet' type='text/css'>

<script  type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>

<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>

<script src="bower_components/webcomponentsjs/webcomponents-lite.min.js"></script>

<link rel="import" href="bower_components/polymer/polymer.html"/>
<link rel="import" href="bower_components/font-roboto/roboto.html"/>
<link rel="import" href="bower_components/iron-icons/iron-icons.html"/>
<link rel="import" href="bower_components/iron-icons/image-icons.html"/>
<link rel="import" href="bower_components/iron-icons/social-icons.html"/>
<link rel="import" href="bower_components/iron-icons/editor-icons.html"/>
<link rel="import" href="bower_components/iron-icons/communication-icons.html"/>
<link rel="import" href="bower_components/iron-icons/maps-icons.html"/>

<link rel="import" href="bower_components/paper-toggle-button/paper-toggle-button.html"/>
<link rel="import" href="bower_components/paper-toast/paper-toast.html"/>
<link rel="import" href="bower_components/paper-input/paper-input.html"/>
<link rel="import" href="bower_components/paper-spinner/paper-spinner.html"/>
<link rel="import" href="bower_components/paper-menu/paper-menu.html"/>
<link rel="import" href="bower_components/paper-menu-button/paper-menu-button.html"/>
<link rel="import" href="bower_components/paper-dialog/paper-dialog.html"/>
<link rel="import" href="bower_components/paper-dialog-scrollable/paper-dialog-scrollable.html"/>
<link rel="import" href="bower_components/paper-button/paper-button.html"/>
<link rel="import" href="bower_components/paper-radio-button/paper-radio-button.html"/>
<link rel="import" href="bower_components/paper-radio-group/paper-radio-group.html"/>
<link rel="import" href="bower_components/paper-icon-button/paper-icon-button.html"/>
<link rel="import" href="bower_components/paper-fab/paper-fab.html"/>
<link rel="import" href="bower_components/paper-item/paper-item.html"/>
<link rel="import" href="bower_components/paper-dropdown-menu/paper-dropdown-menu.html"/>
<link rel="import" href="bower_components/paper-listbox/paper-listbox.html"/>
<link rel="import" href="bower_components/paper-progress/paper-progress.html"/>
<link rel="import" href="bower_components/paper-icon-button/paper-icon-button.html"/>
<link rel="import" href="bower_components/marked-element/marked-element.html"/>

<link rel="import" href="bower_components/neon-animation/neon-animation.html"/>

<link rel="import" href="polymer-elements/copyright-statement.html"/>
<link rel="import" href="polymer-elements/glyphicon-social-icons.html"/>


<script type="text/javascript" src="js/purl.min.js"></script>
<script type="text/javascript" src="js/xmlToJSON.min.js" async></script>
<script type="text/javascript" src="bower_components/js-base64/base64.min.js"></script>
<script type="text/javascript" src="bower_components/picturefill/dist/picturefill.min.js"></script>
<script src="bower_components/imagelightbox/dist/imagelightbox.min.js"></script>
<script src="bower_components/markdown/lib/markdown.js"></script>
<script src="bower_components/js-nacl/lib/nacl_factory.js" async></script>
<script type="text/javascript" src="js/c.min.js"></script>

<?php include_once dirname(__FILE__) ."/social.php"; ?>
