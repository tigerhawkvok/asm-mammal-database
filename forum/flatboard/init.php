<?php defined('FLATBOARD') or die('Flatboard Community.');
/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/
/*
 *---------------------------------------------------------------
 * DEFINITION DE CONSTANTES
 *---------------------------------------------------------------
 */
# Version de FlatBoard
if (!defined('VERSION')) define('VERSION', '1.0RC1'); 
if (!defined('CODENAME')) define('CODENAME', 'TRYING TO FLY'); 

# Mode de déboguage
if (!defined('DEBUG_MODE')) define('DEBUG_MODE', FALSE);
error_reporting(0); // Désactive tous les rapports d’erreur
if(DEBUG_MODE)
{
	# Active tous les rapports d’erreur
	ini_set("display_errors", 1);
	ini_set('display_startup_errors',1);
	ini_set("track_errors", 1);
	ini_set("html_errors", 1);
	error_reporting(E_ALL | E_STRICT | E_NOTICE);
}
# Formatage du timestamp
if (!defined('TIMESTAMP')) define('TIMESTAMP', TRUE);
# Constantes
if (!defined('CHARSET')) 		  define('CHARSET', 	'UTF-8'); 
if (!defined('UPLOADS_DIR')) 	  define('UPLOADS_DIR', PATH_ROOT . DS . 'uploads' . DS);
if (!defined('DATA_DIR')) 		  define('DATA_DIR', 	PATH_ROOT . DS . 'data' . DS);
if (!defined('BAN_DIR')) 		  define('BAN_DIR', 	PATH_ROOT . DS . 'data' . DS . 'ban' . DS);
if (!defined('BAN_FILE')) 		  define('BAN_FILE', 	BAN_DIR   . DS . 'blocklist.txt');
if (!defined('LANG_DIR')) 		  define('LANG_DIR', 	PATH_ROOT . DS . 'lang' . DS);
if (!defined('LIB_DIR')) 		  define('LIB_DIR', 	PATH_ROOT . DS . 'lib' . DS);
if (!defined('PLUGIN_DIR')) 	  define('PLUGIN_DIR', 	PATH_ROOT . DS . 'plugin' . DS);
if (!defined('THEME_DIR')) 		  define('THEME_DIR', 	BASEPATH  . DS . 'theme' . DS);
# JSON pretty print
if(!defined('JSON_PRETTY_PRINT')) define('JSON_PRETTY_PRINT', 128);

# Multibyte string extension loaded.
define('MB_STRING', 			  extension_loaded('mbstring'));
if(MB_STRING)
{
	mb_internal_encoding(CHARSET);
	mb_http_output(CHARSET);
}
/*
 *---------------------------------------------------------------
 * INCLUSION DES LIBS NÉCESSAIRE
 *---------------------------------------------------------------
 */
require_once LIB_DIR . 'Flatdb.lib.php';
require_once LIB_DIR . 'Asset.lib.php';
require_once LIB_DIR . 'Utils.lib.php';
require_once LIB_DIR . 'CSRF.lib.php';

# Renvoie le réglage de la configuration actuelle magic_quotes_gpc et désactivation des guillemets magiques à l'exécution
if (get_magic_quotes_gpc()) {

    function stripslashesGPC(&$value)
    {
        $value = stripslashes($value);
    }
    array_walk_recursive($_GET, 'stripslashesGPC');
    array_walk_recursive($_POST, 'stripslashesGPC');
    array_walk_recursive($_COOKIE, 'stripslashesGPC');
    array_walk_recursive($_REQUEST, 'stripslashesGPC');
}
?>