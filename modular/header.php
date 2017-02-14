<?php ?>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta charset="utf-8"/>
<meta name="theme-color" content="#455A64"/>
<meta name="viewport" content="width=device-width, minimum-scale=1,initial-scale=1" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />

<?php
  $description = "The American Society of Mammalogists Species Account Database";
  $pageDescription = empty($pageDescription) ? $description:$pageDescription;

?>

<meta name="description" content="<?php echo $pageDescription; ?>"/>


<?php
  if(!empty($prefetch)) {
  if(!is_array($prefetch)) {
  $prefetch_arr = array($prefetch);
  } else {
  $prefetch_arr = $prefetch;
  }
  foreach($prefetch_arr as $prefetch) {
  ?>
<link rel="prefetch" href="<?php echo $prefetch; ?>" />
<?php
  }
  }
  if(!empty($prerender)) {
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

<link href="css/main.min.css" rel='stylesheet' type='text/css'/>
<link href="css/glyphicons-bootstrap.css" rel='stylesheet' type='text/css'/>
<link href="css/glyphicons.css" rel='stylesheet' type='text/css'/>
<link href='https://fonts.googleapis.com/css?family=Roboto:regular,bold,italic,thin,light,bolditalic,black,medium&amp;lang=en' rel='stylesheet' type='text/css'>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
