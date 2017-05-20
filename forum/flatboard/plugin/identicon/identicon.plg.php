<?php defined('FLATBOARD') or die('Flatboard Community.');
/**
 * Identicon
 *
 * @author 		Frédéric K.
 * @copyright	(c) 2015-2017
 * @license		http://opensource.org/licenses/MIT
 * @package		FlatBoard
 * @version		1.0.2
 * @update		2016-01-30
 */	
 
define('PATH_AVATARS', 	UPLOADS_DIR . DS . 'avatars' . DS);                 
/**
 * On pré-installe les paramètres par défauts.
**/
function identicon_install()
{
	$plugin = 'identicon';
	if (flatDB::isValidEntry('plugin', $plugin))
		return;

    # Création du dossier qui accueillera nos avatars      
	if(!is_dir(PATH_AVATARS)){
		mkdir(PATH_AVATARS);
		chmod(PATH_AVATARS, 0777);
	}

	if (!file_exists(PATH_AVATARS. 'index.html')) {
		$f = fopen(PATH_AVATARS. 'index.html', 'a+');
		fwrite($f, '');
		fclose($f);	
	}
	
    $data[$plugin.'state']    = true; 
    $data['taille']            = '90'; 
    $data['taille_index']      = '20';          
    flatDB::saveEntry('plugin', $plugin, $data);         
}

/**
 * Admin
**/
function identicon_config()
{    
	   global $lang, $token; 
       $plugin = 'identicon';
       $out ='';
           
       if(HTMLForm::check('state') && HTMLForm::checkNb('taille') && HTMLForm::checkNb('taille_index') && CSRF::check($token) )
       {
               $data[$plugin.'state']     = HTMLForm::clean($_POST['state']);  
               $data['taille']            = HTMLForm::clean($_POST['taille']); 
               $data['taille_index']      = HTMLForm::clean($_POST['taille_index']);   
               
               flatDB::saveEntry('plugin', $plugin, $data);
               $out .= Plugin::redirectMsg($lang['data_save'],'config.php' . DS . 'plugin' . DS . $plugin, $lang['plugin'].'&nbsp;<b>' .$lang[$plugin.'name']. '</b>');   
       }
        else
       {
               if (flatDB::isValidEntry('plugin', $plugin))
               $data = flatDB::readEntry('plugin', $plugin);
               $out .= HTMLForm::form('config.php' . DS . 'plugin' . DS . $plugin,
               HTMLForm::select('state', array(true=> $lang['state_on'], false=> $lang['state_off']), $data[$plugin.'state'],'w20'). 
               HTMLForm::text('taille', isset($data)? $data['taille'] : '', 'number', 'w20', '', 'pixel').   
               HTMLForm::text('taille_index', isset($data)? $data['taille_index'] : '', 'number', 'w20', '', 'pixel').      
               HTMLForm::simple_submit());
       }
       return $out;
} 
/**
 * Show only in topic view
**/
function identicon_profile($username)
{
  	$plugin = 'identicon';
  	# Lecture des données
  	$data = flatDB::readEntry('plugin', $plugin);
  	# Chargement de la class identicons  	
  	require_once(dirname(__FILE__). DS . 'autoload.php');
  	$identicon = new \Identicon\Identicon();
  	$imageDataUri = $identicon->getImageDataUri($username, $data['taille']);
  	
  	$avatar = str_replace('#', '_', $username);
  	$identity = '';
  	if ( file_exists(UPLOADS_DIR . DS . 'avatars' . DS . $avatar. '.png') ) {
  		$identity .= '<img src="' .HTML_BASEPATH . DS . 'uploads' . DS . 'avatars' . DS . $avatar. '.png" class="thumbnail" alt="'.$avatar.'" width="'.$data['taille'].'px" height="'.$data['taille'].'px" />'. PHP_EOL; 
  	} else if (is_numeric($username)) {
        $identity .= '<img src="' .HTML_BASEPATH . DS . 'plugin' . DS . $plugin . DS . 'anonymous.png" class="thumbnail" alt="anonymous" width="'.$data['taille'].'px" height="'.$data['taille'].'px" />'. PHP_EOL;
    } else {
        $identity .= '<img src="' .$imageDataUri. '" class="thumbnail" alt="identicon" />'. PHP_EOL;    
   	}
   	return $identity;   
}
/**
 * Display in index & topics list forum
**/
function identicon_profile_index($username)
{
  	$plugin = 'identicon';
  	# Lecture des données
  	$data = flatDB::readEntry('plugin', $plugin);
  	# Chargement de la class identicons  	
  	require_once(dirname(__FILE__).DS.'autoload.php');
  	$identicon = new \Identicon\Identicon();
  	$imageDataUri = $identicon->getImageDataUri($username, $data['taille_index']);
  	
  	$avatar = str_replace('#', '_', $username);
  	$identity = '';
  	if ( file_exists(UPLOADS_DIR . DS . 'avatars' . DS . $avatar. '.png') ) {
  		$identity .= '<img src="' .HTML_BASEPATH . DS . 'uploads' . DS . 'avatars' . DS . $avatar. '.png" class="thumbnail" alt="'.$avatar.'" width="'.$data['taille_index'].'px" height="'.$data['taille_index'].'px" />'; 
  	} else if (is_numeric($username)) {
        $identity .= '<img src="' .HTML_BASEPATH . DS . 'plugin' . DS . $plugin . DS . 'anonymous.png" class="thumbnail" alt="anonymous" width="'.$data['taille'].'px" height="'.$data['taille'].'px" />'. PHP_EOL;
    } else {
        $identity .= '<img src="' .$imageDataUri. '" class="thumbnail" alt="identicon" />'. PHP_EOL;    
   	}
   	return $identity;  
}


?>