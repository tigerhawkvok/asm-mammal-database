<?php 
  require_once dirname(__FILE__) . "/../core/core.php";
  $defaultImage = "species_photos/Tragelaphus_eurycerus.jpg";
  $pageImage = empty($pageImage) ? $defaultImage : $pageImage;  
  $image = new ImageFunctions($pageImage);
  if(!$image->imageExists()) {
      $pageImage = $defaultImage;
      $image->setImage($defaultImage);
  }
  $width = $image->getWidth();
  $height = $image->getHeight();
  ?>

<!-- Meta descriptors -->

<!-- Twitter cards -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@mammalogists">
<meta name="twitter:creator" content="@mammalogists">
<meta name="twitter:title" content="<?php echo $title; ?>">
<meta name="twitter:description" content="<?php echo $pageDescription; ?>">
<meta property="twitter:image" content="https://mammaldiversity.org/<?php echo $pageImage; ?>" />
<meta property="twitter:image:width" content="<?php echo $width; ?>"/>
<meta property="twitter:image:height" content="<?php echo $height; ?>"/>
<!-- Facebook OG tags -->
<meta property="og:title"
      content="<?php echo $title; ?>" />
<meta property="og:site_name" content="American Society of Mammalogists"/>
<meta property="og:url"
      content="https://mammaldiversity.org/" />
<meta property="og:image" content="https://mammaldiversity.org/assets/favicon1024.png" />
<meta property="og:image:width" content="1024"/>
<meta property="og:image:height" content="1024"/>
<meta property="og:description" content="<?php echo $pageDescription; ?>"/>
<!-- <meta property="fb:page" content="970367112996034" /> -->
<!-- <meta property="fb:app_id" content="974878739261435" /> -->

<link href="https://plus.google.com/107225054672743265667" rel="publisher" />

<!-- Schema.org -->
<script type="application/ld+json">
  { "@context" : "http://schema.org",
  "@type" : "Organization",
  "name" : "ASM Species Account Database",
  "url" : "https://mammaldiversity.org/",
  "logo" : "https://mammaldiversity.org/assets/favicon2048.png",
  "image" : "https://mammaldiversity.org/<?php echo $pageImage; ?>",
  "description" : "<?php echo $pageDescription; ?>"
  }
</script>
