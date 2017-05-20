<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

if(!isset($out))
{
	exit;
}

# Security constant
define('FLATBOARD',    		TRUE);

if (!defined('DS')) define('DS', DIRECTORY_SEPARATOR);
if (!defined('BASEPATH')) define('BASEPATH', '.');
# Define the path to the root directory (with trailing slash).
if (!defined('PATH_ROOT')) define('PATH_ROOT', rtrim(__DIR__, DS));

include PATH_ROOT . DS . 'init.php';


if(!flatDB::isValidEntry('config', 'config'))
{
	Util::redirect(BASEPATH . DS . 'install.php');
}
# Session & déclarion du jeton
session_start();
$token = CSRF::generate();
if(!isset($_SESSION['role']))
{
	$_SESSION['role'] = '';
}

# Chargement de la config
$config = flatDB::readEntry('config', 'config');
# Constante ayant besoin de rendus HTML
if (!defined('HTML_BASEPATH')) define('HTML_BASEPATH', 	rtrim(Util::baseURL(), '\\/') );
if (!defined('HTML_PLUGIN_DIR')) define('HTML_PLUGIN_DIR',	HTML_BASEPATH . DS . 'plugin' .DS);
if (!defined('HTML_THEME_DIR')) define('HTML_THEME_DIR',	HTML_BASEPATH . DS . 'theme' .DS. $config['theme'] .DS);
if (!defined('THEME_CONFIG_PATH')) define('THEME_CONFIG_PATH',	THEME_DIR .  $config['theme'] .DS);
# Déclaration de l'emplacement des émoticones
if (!defined('EMOTICONS_DIR')) define ('EMOTICONS_DIR', 	HTML_THEME_DIR . 'smilies' .DS);

# Vérifie l’existence du fichier langue en configuration, sinon on charge l’anglais
if (file_exists(LANG_DIR . $config['lang']. '.php')) require_once LANG_DIR . $config['lang']. '.php';
	else require_once LANG_DIR . 'en-US.php';

require_once LIB_DIR . 'User.lib.php';
# On vérifie nos IP'S bannis
User::checkIP();
require_once LIB_DIR . 'HTMLForm.lib.php';
require_once LIB_DIR . 'Plugin.lib.php';

# On répertorie les plugins
$plugins = flatDB::fdir(PLUGIN_DIR);
foreach($plugins as $plugin)
{
	// Fichier Langue du plugin
	$plugin_lang = PLUGIN_DIR . $plugin . DS . 'lang' . DS . $config['lang']. '.php';
	if (file_exists($plugin_lang)) require_once $plugin_lang;
		else require_once PLUGIN_DIR .$plugin. DS . 'lang' . DS . 'en-US.php';	
		
	// Chargement du plugin si au bon format
	$extend = PLUGIN_DIR . $plugin . DS . $plugin. '.plg.php';	
	if (file_exists($extend))
		require_once $extend;
}
# Installation & initialisation des plugins si actifs !
Plugin::hook('install');
Plugin::hook('init');

# Parseur de contenu au format Markdown OU BBcode
if(in_array($out['self'], array('add', 'edit', 'feed', 'index', 'view', 'search', 'config'))) {
 	require_once LIB_DIR . 'Parser.lib.php';
 	# Markdown
	if($config['editor'] === 'markdown'){
		require_once LIB_DIR . 'Parsedown.lib.php';
		require_once LIB_DIR . 'ParsedownExtra.lib.php';
		require_once LIB_DIR . 'BBlight.lib.php';
		# Objects
		$Parsedown = new ParsedownExtra();
		$BBlight = new BBlight;	
	# BBcode		
	} else {
		require_once LIB_DIR . 'BBcode.lib.php';		
		# Objects
		$BBcode = new BBCode;		
	}	 	
}
# Modération
if(in_array($out['self'], array('index', 'search', 'view', 'config')))
	require_once LIB_DIR . 'EntryLink.lib.php';

# Pagination & Mail report
if(in_array($out['self'], array('index', 'config', 'view', 'feed')))
	require_once LIB_DIR . 'Pagination.lib.php';


$_GET = Util::fURL();
$cur = (isset($cur) ? $cur : null);


$out['content'] = '';
$out['sub_prefix'] = '';
$out['baseURL'] = Util::baseURL();

?>