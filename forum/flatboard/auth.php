<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'auth';
require_once __DIR__ . '/header.php';
/**
 * MODIFICATION DU MOT DE PASSE ADMIN
 **/
if(Util::isGET('password') && User::isAdmin())
{
    $cur = 'password';
	$out['subtitle'] = $lang['edit_password'];
	if(!empty($_POST) && HTMLForm::checkPass('password') && CSRF::check($token) )
	{
		$config['admin'] = HTMLForm::hide($_POST['password']);
		flatDB::saveEntry('config', 'config', $config);
		$_SESSION['role'] = '';
		$out['content'] .= Plugin::redirectMsg($lang['password_changed'], 'auth.php' . DS . 'login', $lang['login']);
			
	}
	else
	{
		$out['content'] .= HTMLForm::form('auth.php' . DS . 'password',
		HTMLForm::password('password').
		HTMLForm::simple_submit());
	}
}
/**
 * ON QUITTE LA SESSION
 **/
else if(Util::isGET('logout') && User::isWorker())
{
	#$_SESSION = array();
	session_destroy();
	$out['subtitle'] = $lang['logout'];
	$out['content'] .= Plugin::redirectMsg($lang['logout_confirm'], 'index.php' . DS . 'forum', $lang['forum'], 'message success');
}
/**
 * PAGE DE CONNEXION
 **/
else
{
	$cur = 'login'; # Indicateur de page
	$out['subtitle'] = $lang['login'];
	# Protection anti brute force
	$maxlogin['counter'] = 3; # nombre de tentative de connexion autorisé dans la limite de temps autorisé
	$maxlogin['timer'] = 3 * 60; # temps d'attente limite si nombre de tentative de connexion atteint (en minutes)	

	# Initialisation variable erreur
	$error = '';
	$msg = '';

	if(isset($_SESSION['maxtry'])) {
		if( intval($_SESSION['maxtry']['counter']) >= $maxlogin['counter'] AND (time() < $_SESSION['maxtry']['timer'] + $maxlogin['timer']) ) 
		{
			# écriture dans les logs du dépassement des 3 tentatives successives de connexion
			@error_log('Flatboard: Max login failed. IP : '.User::getRealIpAddr());
			# message à affiche sur le mire de connexion
			$msg = sprintf($lang['error_maxlogin'], ($maxlogin['timer']/60));
			$out['content'] .= Plugin::redirectMsg($msg, 'index.php', $lang['home'], 'message error', FALSE);
			$error = true;
		}
		if( time() > ($_SESSION['maxtry']['timer'] + $maxlogin['timer']) ) {
			# on réinitialise le control brute force quand le temps d'attente limite est atteint
			$_SESSION['maxtry']['counter'] = 0;
			$_SESSION['maxtry']['timer'] = time();
		}
	} else {
		# initialisation de la variable qui compte les tentatives de connexion
		$_SESSION['maxtry']['counter'] = 0;
		$_SESSION['maxtry']['timer'] = time();
	}
	# on incremente la variable de session qui compte les tentatives de connexion		
	$_SESSION['maxtry']['counter']++;	
	
	$connected = false;	
	if(HTMLForm::checkBot() && HTMLForm::checkPass('password') && User::login($_POST['password']) && CSRF::check($token) && $error=='' )
	{
		session_regenerate_id(true);	
		$connected = true;
	}
	if($connected) {
		unset($_SESSION['maxtry']);
		$out['content'] .= Plugin::redirectMsg($lang['login_confirm'], 'index.php' . DS . 'forum', $lang['forum'], 'message success');
		#exit;
	} else {
		if($error) {
			$out['content'] .='';
		} else {	
		$out['content'] .= HTMLForm::form('auth.php' . DS . 'login',
			HTMLForm::password('password').
			HTMLForm::submit('login'));
		}
	}
		

}

require PATH_ROOT . DS . 'footer.php';

?>