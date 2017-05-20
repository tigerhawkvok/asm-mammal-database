<?php if(!isset($out)) exit; ?>
<!DOCTYPE html>
<html lang="<?php echo $config['lang']?>">
<head>
	<meta charset="<?php echo CHARSET ?>" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
	<meta name="description" content="<?php echo Util::Description()?>"/>
	<title><?php echo $config['title']?> - <?php echo $out['subtitle']?></title>
	<base href="<?php echo $out['baseURL']?>"/>
	<?php 
		$destination = THEME_DIR. $config['theme'] . DS . 'assets' .DS. 'css' .DS;
		$css = array(
            $destination. 'kube.css',
            $destination. 'master.css',
            $destination. 'main.css',
            Plugin::hook('css', $out['self']),
            );
            
		echo Asset::Stylesheet($css, $destination, 'style.min.css'); 	
	?>
	<!-- favicon -->
	<link rel="icon" href="<?php echo HTML_THEME_DIR?>assets/img/favicon.ico">
	<link rel="apple-touch-icon" href="<?php echo HTML_THEME_DIR?>assets/img/apple-touch-icon.png">
	<!-- RSS Feeds -->
	<link rel="alternate" type="application/atom+xml" href="feed.php/topic" title="<?php echo $lang['topic']?> - <?php echo $config['title']?>"/>
	<link rel="alternate" type="application/atom+xml" href="feed.php/reply" title="<?php echo $lang['reply']?> - <?php echo $config['title']?>"/>
	<style>/* Navbar background color */ #top { background: <?php echo $config['style']?>; }</style>
	<?php echo Plugin::hook('head', $out['self'])?>
</head>

<body>

	<header role="banner">
		<div class="show-sm">
	    	<div id="nav-toggle-box">
	    		<div id="nav-toggle-brand">
	    		    
		            <a href="<?php echo HTML_BASEPATH?>" title="<?php echo $config['description']?>">
			            <?php echo $config['title']?>
			        </a>	
	    			
	    		</div>
	            <a href="#" id="nav-toggle" data-component="toggleme" data-target="#top"><i class="kube-menu"></i></a>
	    	</div>
		</div>
	
		<div id="top" class="hide-sm">
	    	<div id="top-brand">    
	            <a href="<?php echo HTML_BASEPATH?>" title="<?php echo $config['description']?>">
		            <?php echo $config['title']?>
		        </a>		
	    	</div>
	        <nav class="top-nav-main" id="top-nav-main">
		        <ul>		
					<li<?php if ($cur == 'forum') echo ' class="active"'; ?>><a href="index.php/forum"><?php echo $lang['forum']?></a></li>
					<li<?php if ($cur == 'search') echo ' class="active"'; ?>><a href="search.php"><?php echo $lang['search']?></a></li>
					<?php echo Plugin::hook('menu', $out['self']) ?>
				</ul>
			</nav>
			
	        <nav id="top-nav-extra">
		        <ul>
				<?php echo (User::isWorker()? '<li><a href="#" data-component="dropdown" data-target="#settings">' .$lang[$_SESSION['role']]. ' <span class="caret down"></span></a></li>' : '<li><a href="auth.php">' .$lang['login']. '</a></li>')
				?>
				</ul>
			</nav>	
		</div>
		
	    <?php if (User::isWorker()): ?>
		<nav class="dropdown hide" id="settings">
		    <ul>
		        <?php if (User::isAdmin()): ?>
	            <li<?php if ($cur == 'config') echo ' class="active"'; ?>><a href="config.php"><?php echo $lang['config'] ?></a></li>
				<li<?php if ($cur == 'plugin') echo ' class="active"'; ?>><a href="config.php/plugin"><?php echo $lang['plugin'] ?></a></li>
				<li<?php if ($cur == 'worker') echo ' class="active"'; ?>><a href="config.php/worker"><?php echo $lang['worker'] ?></a></li>
				<li<?php if ($cur == 'notifications') echo ' class="active"'; ?>><a href="config.php/notifications"><?php echo $lang['notifications_center'] ?></a></li>
				<li<?php if ($cur == 'password') echo ' class="active"'; ?>><a href="auth.php/password"><?php echo $lang['change_pwd'] ?></a></li>
				<?php endif; ?>
				<?php echo Plugin::hook('core_menu', $out['self'])?>
				<li><a href="auth.php/logout"><?php echo $lang['logout'] ?></a></li>
			</ul>	
		</nav>
	    <?php endif; ?>		
	</header>
	
	<main role="main">
	    <?php if (!$config['announcement']==''): ?>
	    <div id="announce" class="message">
		    <?php echo $config['announcement']?>
	    </div>
		<?php endif; ?>
		   	
		<?php echo Plugin::hook('beforeMain', $out['self'])?>

	    <section>	
			<h4><?php echo $out['sub_prefix'].$out['subtitle']?></h4>
			<?php echo $out['content']?>	
	    </section>	
	    
	    <?php echo Plugin::hook('afterMain', $out['self'])?>       	
    </main>
	   
    <footer id="footer">
    	<nav>
    		<ul>	
				<li><?php echo $lang['powered']?> <?php echo Plugin::hook('footer', $out['self'])?></li>
				<li><?php if(DEBUG_MODE) echo '<small class="label error outline upper hint--top hint--rounded" data-hint="v.'.VERSION.'">' .CODENAME. '</small>'; ?></li>
			</ul>
    	</nav>
    	
    	<p><?php echo $config['footer_text']?></p>
    </footer>
    
	<!-- Javascripts -->
	<script src="<?php echo HTML_THEME_DIR?>assets/js/jquery.min.js"></script>
    <script src="<?php echo HTML_THEME_DIR?>assets/js/kube.min.js"></script>
    <?php echo Plugin::hook('footerJS', $out['self'])?>	
</body>
</html>
