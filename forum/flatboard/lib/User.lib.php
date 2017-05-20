<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class User
{
    /**
     * Protected constructor since this is a static class.
     *
     * @access  protected
     */
    protected function __construct()
    {
        // Nothing here
    }
    	
	public static function isAdmin()
	{
		return $_SESSION['role'] === 'admin';
	}
	
	public static function isAuthor($entry)
	{
		return isset($_SESSION[$entry]);
	}
	
	public static function isWorker()
	{
		return $_SESSION['role'] === 'worker' || $_SESSION['role'] === 'admin';
	}
	
	public static function login($password)
	{
		global $config, $lang;
		$password = HTMLForm::hide($password);
		if($password === $config['admin'])
		{
			$_SESSION['role'] = 'admin';
			return true;
		}
		else if(isset($config['worker'][$password]))
		{
			$_SESSION['role'] = 'worker';
			return true;
		} 
		else 
		{
			$_SESSION['incorrect_password'] = 1;
			return false;
		}
	}
	/**
	 * Protège le mail via un affichage js
	 * Usage:
	 * User::protect_email("youremail@here.com");
	 **/
	public static function protect_email($email,$word)
	{
		$pieces = explode("@", $email);
		return '<script>
					var a = "<a href=\'mailto:";
					var b = "' . $pieces[0] . '";
					var c = "' . $pieces[1] .'";
					var d = "\' class=\'label label-outline\'><i class=\'fa fa-envelope\'></i> ";
					var e = "' . $word .'";
					var f = "</a>";
					document.write(a+b+"@"+c+d+e+f);
			</script>
			<noscript>Activer JavaScript pour afficher le mail</noscript>
		';
	}
	/**
	 * RÉCUPÈRE L’IP REEL
	 **/
	public static function getRealIpAddr()
	{
	    if (!empty($_SERVER['HTTP_CLIENT_IP']))   //check ip from share internet
	    {
	      $ip = $_SERVER['HTTP_CLIENT_IP'];
	    }
	    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))   //to check ip is pass from proxy
	    {
	      $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
	    }
	    else
	    {
	      $ip = $_SERVER['REMOTE_ADDR'];
	    }
	    return $ip;
	}

	
	/**
	* Blocklist function checks a user IP against an array of blocked IPs.
	* I'd avoid using a hard coded filename/path in this so 
	* consider this as just a demo.
	* 
	* @param string $ip The IP address to check
	* @return bool true If IP is in blocklist. Defaults to false.
	*/
	public static function blocklist($ip) {
	    $blocked = false;
	    $ipList = file(BAN_FILE, FILE_SKIP_EMPTY_LINES)
	        or exit("Unable to open blocklist file");
	 
	    foreach ($ipList as $entry) {
	        if(strstr($ip, $entry, true)) {
	            $blocked = true;
	            break;  // No need to loop further
	        }
	    }
	    return $blocked;
	}	
	public static function checkIP2()
	{
	    global $lang;
		$userIP = User::getRealIpAddr();
		// If the IP is in the blocklist, send a 403 Forbidden header
		if(User::blocklist($userIP)) {
		    header("HTTP/1.1 403 Forbidden");
		    exit(); // We're done here
		}
	}		
	/**
	 * VÉRIFIE SI UNE ADRESSE IP EST BANNIE
	 **/
	public static function is_ban($ip) 
	{ 	  
	  $IPlist = BAN_FILE;
	  if (file_exists($IPlist)) {
	    $blacklist = file_get_contents($IPlist);
     
			if ($blacklist != ''){
				return strpos($ip."\n", $blacklist) === false ? false : true;
			}    
	  }
	
	}
	/**
	 * SI L’IP EST BANNI, ON RENVOIS LE VISITEUR SUR UNE PAGE SPÉCIALE
	 **/
	public static function checkIP()
	{
	    global $lang;
	    
	    $ip = User::getRealIpAddr();
	    $list = file(BAN_FILE);
		foreach ($list as $line)
		{
		    if ($ip == $line)
		        die("<!DOCTYPE html><html><head><meta charset='utf-8' /><title>".$lang['banned']."</title></head><body style='background:#232323; color:#FFF; position: absolute;top: 50%;left: 50%;margin-top: -5%;margin-left: -22%;'>".mb_strtoupper(Util::lang('your_banned %s has_banned', $ip)). "</p></body></html>");

		}	    
	}

}