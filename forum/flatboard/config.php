<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'config';
require_once __DIR__ . '/header.php';

 /**
  * GESTION DES MODÉRATEURS
  **/
if(Util::isGET('worker') && User::isAdmin())
{
	$cur = 'worker'; # Indicateur de page
	$out['subtitle'] = $lang['worker'];
	$out['sub_prefix'] = '<a href="add.php' . DS . 'worker" class="hint--top hint--rounded" data-hint="' .$lang['add_worker']. '"><i class="fa fa-plus-circle"></i></a>';
	$out['content'] .= '<ul>';
	if($config['worker'])
	{
		foreach($config['worker'] as $key => $password)
		{
			$out['content'] .= '<li><a href="delete.php' . DS . 'worker' . DS . $key. '" class="hint--top hint--rounded" data-hint="' .$lang['delete']. '"><i class="fa fa-trash-o"></i></a> ' .$password. '</li>';
		}
	}
	else
	{
		$out['content'] .= '<li>' .$lang['none']. '</li>';
	}
	$out['content'] .= '</ul>';
}
 /**
  * GESTION DES PLUGINS
  **/
else if(Util::isGET('plugin') && User::isAdmin())
{
	if(Plugin::isValidHook('config', $_GET['plugin']))
	{
		$cur = (isset($_GET['plugin']) ? $_GET['plugin'] : null); # Indicateur de page
		$out['subtitle'] = $lang['config']. ' ' .$lang[$_GET['plugin'].'name'];
	    $plugin = $_GET['plugin'];
		$out['content'] .= '
    <nav class="breadcrumbs">
      <ul>
          <li><a href="config.php' . DS . 'plugin">' .$lang['plugin']. '</a></li>
          <li><span>' .$lang[$_GET['plugin'].'name']. '</span></li>
      </ul>
    </nav>
    <div class="row gutters">
	    <div class="col col-9">
	    		' .Plugin::myHook('config', $_GET['plugin']). '
	    </div>
	    <div class="col col-3">
		    <blockquote>
		    	<img class="thumbnail" src="' .HTML_PLUGIN_DIR . $plugin . DS . 'icon.png" style="width: 150px;" alt="icon" />
			   	<p>' .$lang['author']. ' ' .(!$lang[$plugin.'author_site']? $lang[$plugin.'author'] : '<a href="' .$lang[$plugin.'author_site']. '">' .$lang[$plugin.'author']. '</a>').'</p>		
				<p>' .($lang[$plugin.'author_mail']? User::protect_email($lang[$plugin.'author_mail'], $lang['mail']) : '-').'</p>		
				<p>' .$lang['update']. ' ' .($lang[$plugin.'update']? '<span class="label focus outline">'.$lang[$plugin.'update'].'</span>' : '-').'</p>
			</blockquote>	    
	    </div>
	</div>';					
	}
	 /**
	  * TABLEAU RETOURNANT LA LISTE DES PLUGINS
	  **/	
	else
	{
		$cur = 'plugin'; # Indicateur de page
		$out['subtitle'] = $lang['manage_plugin'];
		
		$out['content'] .= '
		<h2 class="subheader">' .$lang['plugin']. Util::pluralize(count($plugins)) . ' <small>' .count($plugins). '</small></h2>
		
		<table id="plugin" class="w100 bordered striped">
            <thead>
             <tr>
               <th style="width: 80px;">&nbsp;</th>
               <th>' .$lang['name']. ' / ' .$lang['description']. '</th>
               <th style="width: 180px;">&nbsp;</th>
             </tr>
            </thead>
            <tbody>';
	        sort($plugins);
	        $nb = $config['ItemByPage'];
		    $total = Paginate::countPage($plugins, $nb);
		    $p = Paginate::pid($total);                      	                            
			if($plugins)
			{
			    foreach(Paginate::viewPage($plugins, $p, $nb) as $plugin)
				{
				    # Fichier langue qui contient les infos du plugins
				    require PLUGIN_DIR . $plugin . DS . 'lang' . DS . $config['lang']. '.php';
				    $data = flatDB::readEntry('plugin', $plugin);
				    $statut = ($data[$plugin.'state'] ? '' : ' secondary');
				    $statutLang = ($data[$plugin.'state'] ? '<i class="fa fa-cog" aria-hidden="true"></i> ' .$lang['config'] : 
				    '<i class="fa fa-plus-square" aria-hidden="true"></i> ' .$lang['install']);
				    
					$out['content'] .= '<tr>
					<td>' .(Plugin::isValidHook('config', $plugin)? '<a class="thumbnail" href="config.php' . DS . 'plugin' . DS . $plugin. '"><img src="' .HTML_PLUGIN_DIR . $plugin . DS . 'icon.png" style="width: 80px;" alt="icon" /></a>' : '<img class="thumbnail" src="' .HTML_PLUGIN_DIR . $plugin . DS . 'icon.png" style="width: 80px;" alt="icon" />'). '</td>
					
					<td>
						<b>' .$lang[$plugin.'name']. '</b> 
						<span class="label warning">Version ' .$lang[$plugin.'version']. '</span><br />
						<span class="color-gray">' .$lang[$plugin.'description']. '</span>
					</td>
	
	               <td style="vertical-align:middle">
	               		' .(Plugin::isValidHook('config', $plugin)? '<a href="config.php' . DS . 'plugin' . DS . $plugin. '" class="button small' .$statut. '">' .$statutLang. '</a>' : ''). '
	               </td>
	             </tr>';
				}
			}
			else		{
				$out['content'] .= '<p>' .$lang['none']. '</p>';
			}
		$out['content'] .= '</tbody>
          </table>'.
          # PAGINATION
          Paginate::pageLink($p, $total, 'config.php' . DS . 'plugin' . DS . 'o'); 
	}
}
/**
 * CENTRE DE NOTIFICATIONS
 **/
else if(Util::isGET('notifications') && User::isAdmin())
{
	$cur = 'notifications'; # Indicateur de page
	$out['subtitle'] = $lang['notifications_center'];
    # On vérifie la présence éventuelle du fichier d'installation
	if(is_file('install.php')) $out['content'] .= '<div class="message warning"><i class="fa fa-warning"></i> ' .$lang['warning_installation_file']. '</div>';
	# On vérifie que le mot de passe par défaut soit changé
	if(strcmp($config['admin'],HTMLForm::hide('demo')) == 0) $out['content'] .= '<div class="message warning"><i class="fa fa-warning"></i> ' .$lang['change_defaut_password']. '</div>';
	# Vérifie s'il y a une nouvelle version de Flatboard
	$out['content'] .= Util::checkMaj();	
	# Vérifie si la fonction mail existe
	$out['content'] .= Util::testMail();
	
	$out['content'] .= '
	<table class="w100 striped">
	<thead>
		<tr>
		<th class="w30"></th>
		<th class="w70"></th>
		</tr>
	</thead>
	<tbody>

		<tr>
			<td>Flatboard codename</td>
			<td>'.CODENAME.'</td>
		</tr>
			
		<tr>
			<td>CHARSET</td>
			<td>' .CHARSET. '</td>
		</tr>
	
		<tr>
			<td>PHP version</td>
			<td>'.phpversion().'</td>
		</tr>

		<tr>
			<td>SERVER SOFTWARE</td>
			<td>'.(!empty($_SERVER['SERVER_SOFTWARE']) ? $_SERVER['SERVER_SOFTWARE'] : '').'</td>
		</tr>
			
		<tr>
			<td>PHP modules</td>
			<td>'.implode(', ',get_loaded_extensions()).'</td>
		</tr>
		
	</tbody>
	</table>';		
}
/**
 * SUPRESSION DU FICHIER D'INSTALLATION
 **/
else if(Util::isGET('delinstallfile') && User::isAdmin())
{
    @unlink('install.php');
	Util::redirect('config.php' . DS . 'notifications');
	exit();
}
/**
 * SUPRESSION DU CACHE DES FICHIERS CSS DU THEME
 **/
else if(Util::isGET('deletecache') && User::isAdmin())
{
	$out['subtitle'] = '';
    $out['content'] .= flatDB::removeDirectory(THEME_CONFIG_PATH . 'cache' . DS, 'cache_clean');
}
/**
 * LISTE DES UTILISATEUR BANNIS
 **/
else if(Util::isGET('ban') && User::isAdmin())
{
	$cur = 'ban'; # Indicateur de page
	$out['subtitle'] = $lang['ban_list'];
	
    if (!file_exists(BAN_FILE)) {
       @mkdir(BAN_FILE, 0777, true);
       $fp = fopen(BAN_FILE, 'w');
	   fwrite($fp, '');
	   fclose($fp);
    }
    $ips = file_get_contents(BAN_FILE, true);
	$adresses = explode("\n", $ips);
    $nbr = count($adresses);
     
	$out['content'] .= '<ul class="unstyled">';
	if($adresses)
	{
		foreach($adresses as $key => $value)
		{
		    if ($value != '')
			  $out['content'] .= '<li>' .entryLink::userBan($value). ' ' .$value. '</li>';
			else 		 
			  $out['content'] .= '<li>' .$lang['none']. '</li>';
		}
	}
	$out['content'] .= '</ul>';	
}
 /**
  * PARAMÈTRES DU FORUM
  **/ 
else
{
	if(User::isAdmin()) {
		$cur = 'config'; # Indicateur de page
		$out['subtitle'] = $lang['config'];
		if(HTMLForm::check('title') && HTMLForm::check('description',0,250) &&
			Util::isPOST('theme') && flatDB::indir($_POST['theme'], THEME_DIR) && HTMLForm::check('style',3,120) && 
			Util::isPOST('lang') && flatDB::indir($_POST['lang'], LANG_DIR, '.php') && HTMLForm::check('editor') && HTMLForm::check('date_format') && HTMLForm::check('mail') && HTMLForm::check('salt', 8, 80) && HTMLForm::check('footer_text', 1, 250) && HTMLForm::checkNb('ItemByPage') && HTMLForm::checkNb('nb_page_scroll_infinite') && CSRF::check($token) )
		{
			$config['title'] = HTMLForm::clean($_POST['title']);
			$config['description'] = HTMLForm::transNL(HTMLForm::clean($_POST['description']));
			$config['theme'] = $_POST['theme'];
			$config['style'] = HTMLForm::clean($_POST['style']);
			$config['lang'] = HTMLForm::clean($_POST['lang']);
			$config['editor'] = HTMLForm::clean($_POST['editor']);
			$config['date_format'] = HTMLForm::clean($_POST['date_format']);
			$config['mail'] = HTMLForm::clean($_POST['mail']);
			$config['salt'] = HTMLForm::clean($_POST['salt']);
			$config['footer_text'] = HTMLForm::transNL(Parser::htmlDecode($_POST['footer_text']));
			$config['announcement'] = HTMLForm::transNL(Parser::htmlDecode($_POST['announcement']));
			$config['ItemByPage'] = HTMLForm::clean($_POST['ItemByPage']);
			$config['nb_page_scroll_infinite'] = HTMLForm::clean($_POST['nb_page_scroll_infinite']);
			flatDB::saveEntry('config', 'config', $config);
			$out['content'] .= Plugin::redirectMsg($lang['data_save'], 'config.php', $lang['config'], 'message success');
		}
		else
		{
			$themes = flatDB::fdir('theme');
			$langs = flatDB::fdir('lang');
			$out['content'] .= HTMLForm::form('config.php',
				HTMLForm::text('title', $config['title'], 'text', 'w50').
				HTMLForm::textarea('description', $config['description'], 'w60', '', 3). '
				<hr />
			    <div class="row gutters">
			        <div class="col col-4">
			            ' .HTMLForm::text('style', $config['style'], 'text', 'color', 'style_placeholder', 'style_desc'). '
			        </div>
			        <div class="col col-2">
			            ' .HTMLForm::select('theme', array_combine($themes, $themes), $config['theme'], '', 'theme_desc'). '
			        </div>
			        <div class="col col-2">
			            ' .HTMLForm::select('lang', array_combine($langs, $langs), $config['lang']). '
			        </div>
			        <div class="col col-3">
			            ' .HTMLForm::select('editor', array('bbcode'=> $lang['bbcode'], 'markdown'=> $lang['markdown']), $config['editor'], '', 'editor_desc'). '
			        </div>			        
			    </div>
			    
			    <div class="row gutters">
			        <div class="col col-4">
			            ' .HTMLForm::text('date_format', $config['date_format'], 'date', '', 'date_format_placeholder'). '
			        </div>
			        <div class="col col-2">
			            ' .HTMLForm::text('ItemByPage', $config['ItemByPage'], 'number'). '
			        </div>
			        <div class="col col-4">
			            ' .HTMLForm::text('nb_page_scroll_infinite', $config['nb_page_scroll_infinite'], 'number', '', '', 'nb_page_scroll_desc'). '
			        </div>
			    </div>
			    <hr />'.
				HTMLForm::text('mail', $config['mail'], 'email', 'w50').
				HTMLForm::text('salt', ($config['salt'] ? $config['salt'] : $token), 'text', 'w70', '', 'salt_desc'). '
				<hr />' .
				HTMLForm::textarea('footer_text', $config['footer_text'], 'w70', '', 4).
				HTMLForm::textarea('announcement', $config['announcement'], 'w70', 'announcement_desc', 5).
				HTMLForm::simple_submit('save'));
		}
	
	} 
	/**
	 * Si non connecté on quitte
	 **/	
	else {	
		Util::redirect('auth.php' . DS . 'login');
		exit();
	}
}

require PATH_ROOT . DS . 'footer.php';

?>