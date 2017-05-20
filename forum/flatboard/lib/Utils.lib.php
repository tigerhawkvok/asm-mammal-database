<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class Util
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
	public static function isGET($name)
	{
		return isset($_GET[$name]) && is_string($_GET[$name]);
	}
	
	public static function isPOST($name)
	{
		return isset($_POST[$name]) && is_string($_POST[$name]);
	}
	
	public static function isGETValidEntry($type, $name)
	{
		return Util::isGET($name) && flatDB::isValidEntry($type, $_GET[$name]);
	}
	
	public static function isGETValidHook($hook, $name)
	{
		return Util::isGET($name) && Plugin::isValidHook($hook, $_GET[$name]);
	}
	
	public static function fURL()
	{
		$out = array();
		if(isset($_SERVER['PATH_INFO']))
		{
			$info = explode('/', $_SERVER['PATH_INFO']);
			$infoNum = count($info);
			for($i=1; $i<$infoNum; $i+=2)
			{
				if($info[$i] !== '')
					$out[$info[$i]] = isset($info[$i+1])? $info[$i+1] : '';
			}
		}
		return $out;
	}
    /**
      * Gets the base URL
      *
     *  <code>
     *      echo Util::baseURL();
     *  </code>
     *
      * @return string
     */
    public static function baseURL()
    {
	    $siteUrl = str_replace(array('add.php', 'auth.php', 'config.php', 'delete.php', 'edit.php', 'feed.php', 'index.php', 'install.php', 'search.php', 'view.php', 'download.php', 'forum.php'), '', $_SERVER['SCRIPT_NAME']);
	    #$siteUrl = rtrim($siteUrl, '\\/');
	    $https = (isset($_SERVER['HTTPS']) && strtolower($_SERVER['HTTPS']) == 'on') ? 'https://' : 'http://';
	    
	    $siteUrl = $https . $_SERVER['HTTP_HOST'] . $siteUrl;
	    return $siteUrl;
    }

    /**
     * Gets current URL
     *
     *  <code>
     *      echo Util::getCurrent();
     *  </code>
     *
     * @return string
     */
    public static function getCurrent()
    {
        return (!empty($_SERVER['HTTPS'])) ? "https://".$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'] : "http://".$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'];
    }

	
	public static function _max($arr, $limit)
	{
		$size = count($arr);
		if($size <= $limit)
		{
			rsort($arr);
			return $arr;
		}
		$out = array();
		for($i=0; $i<$limit; $i++)
		{
			$maxI = 0;
			for($j=1; $j<$size; $j++)
			{
				if ($arr[$j] > $arr[$maxI])
					$maxI = $j;
			}
			$out[] = $arr[$maxI];
			unset($arr[$maxI]);
			$size--;
		}
		return $out;
	}
		
	public static function redirect($loc)
	{
		header('Location: ' .Util::baseURL().$loc);
		exit;
	}
	
	public static function onPage($item, $items)
	{
		return (int) (array_search($item, array_values($items), true) / 8) + 1;
	}
	
	public static function shortNum($int)
	{
		if($int < 1000)
			return intval($int);
		else
			return round(intval($int)/1000, 1). 'K';
	}
	
	public static function toDate($id, $pattern = 'Y/m/d H:i')
	{
		global $lang, $config;
		$timestamp = strtotime(substr($id, 0, 16));
		$diff = time() - $timestamp;
		if($pattern === $config['date_format'] && $diff < 604800) //1 week
		{
			$periods = array(86400 => $lang['day'], 3600 => $lang['hour'], 60 => $lang['minute'], 1 => $lang['second']);
			foreach($periods as $key => $value)
			{
				if($diff >= $key)
				{
					$num = (int) ($diff / $key);
					if(TIMESTAMP)
						return $num. ' ' .$value.($num > 1? $lang['plural'] : ''). ' ' .$lang['ago'];
					else
						return $lang['ago']. ' ' .$num. ' ' .$value.($num > 1? $lang['plural'] : '');
				}
			}
		}
		return date($pattern, $timestamp);
	}
	
	public static function lang($format)
	{
		global $lang;
		$argList = func_get_args();
		$wordList = array();
		foreach(explode(' ', $format) as $word)
		{
			$wordList[] = isset($lang[$word])? $lang[$word] : $word;
		}
		return vsprintf(implode($lang['useSpace']? ' ' : '', $wordList), array_slice($argList, 1));
	}		
	/**
	 * Méthode qui teste si la fonction php mail est disponible
	 *
	 * @param	io			affiche à l'écran le résultat du test si à VRAI
	 * @param	format		format d'affichage
	 * @return	boolean		retourne vrai si la fonction php mail est disponible
	 **/
	public static function testMail($io=true, $format="<div class=\"message #color\" data-component=\"message\">#symbol #message</div>\n") 
	{
		global $lang;
		if($return=function_exists('mail')) {
			if($io==true) {
				$output = str_replace('#color', 'success', $format);
				$output = str_replace('#symbol', '&#10004;', $output);
				$output = str_replace('#message', $lang['mail_available'], $output);
				return $output;
			}
		} else {
			if($io==true) {
				$output = str_replace('#color', 'error', $format);
				$output = str_replace('#symbol', '&#10007;', $output);
				$output = str_replace('#message', $lang['mail_not_available'], $output);
				return $output;
			}
		}
		return $return;
	}
	/**
	* Méthode d'envoi de mail
	*
	* @param	name	string 			Nom de l'expéditeur
	* @param	from	string 			Email de l'expéditeur
	* @param	to		array/string	Adresse(s) du(des) destinataires(s)
	* @param	subject	string			Objet du mail
	* @param	body	string			contenu du mail
	* @return			boolean			renvoie FAUX en cas d'erreur d'envoi
	**/
	public static function sendMail($name, $from, $to, $subject, $body, $contentType="text", $cc=false, $bcc=false) 
	{
		if(is_array($to))
			$to = implode(', ', $to);
		if(is_array($cc))
			$cc = implode(', ', $cc);
		if(is_array($bcc))
			$bcc = implode(', ', $bcc);

		$headers  = "From: ".$name." <".$from.">\r\n";
		$headers .= "Reply-To: ".$from."\r\n";
		$headers .= 'MIME-Version: 1.0'."\r\n";
		// Content-Type
		if($contentType == 'html')
			$headers .= 'Content-type: text/html; charset="' .CHARSET. '"'."\r\n";
		else
			$headers .= 'Content-type: text/plain; charset="' .CHARSET. '"'."\r\n";

		$headers .= 'Content-transfer-encoding: 8bit'."\r\n";
		$headers .= 'Date: '.date("D, j M Y G:i:s O")."\r\n"; // Sat, 7 Jun 2001 12:35:58 -0700

		if($cc != "")
			$headers .= 'Cc: '.$cc."\r\n";
		if($bcc != "")
			$headers .= 'Bcc: '.$bcc."\r\n";

		return mail($to, $subject, $body, $headers);
	}
	    	
	/**
	 * Retourne la dernière version
	 **/	 
	public static function checkMaj() 
	{
	    global $lang;
	    
	    $latest_version = '';
		if (file_exists(PATH_ROOT . DS . 'latest_version'))
			$version = PATH_ROOT . DS . 'latest_version';
		else
			$version = base64_decode('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0ZyZWQ4OS9mbGF0Ym9hcmQvbWFzdGVyL2xhdGVzdF92ZXJzaW9u');
		# La fonction est active ?
		if(!ini_get('allow_url_fopen')) 
			return '<div class="message error" data-component="message">' .$lang['allow_url_fopen']. '</div>';

		# Requete HTTP sur le site de Flatboard
		if($fp = @fopen($version, 'r')) {
			$latest_version = trim(fread($fp, 16));
			fclose($fp);
		}
		if($latest_version == '')
			return '<div class="message error" data-component="message">' .$lang['update_error']. '</div>';
      
		# Comparaison
		if(version_compare(VERSION, $latest_version, '>='))
			return '<div class="message focus" data-component="message">' .$lang['no_update']. ' <span class="float-right"><i class="fa fa-code-fork"></i> v.<strong>' .VERSION. '</strong></span></div>';
		else
			return '<div class="message warning" data-component="message"><i class="fa fa-info-circle"></i> ' .sprintf($lang['update_version_%1$s'], $latest_version). '</div>';
			
	}
	/*
	** Ajoute un 's' au pluriel
	** $num = 6;
	** $texte = 'Vous avez acheté ' . $num . ' journ' . Util::pluralize($num, 'aux', 'al') . ' ce jour.<br />';
	** $texte .= 'Vous avez ' . $num . ' commentaire' . Util::pluralize($num) . '<br />';
	** print($texte);
	*/
	public static function pluralize($num, $plural='s', $single='') 
	{
	    if ($num == 0 || $num == 1) return $single; 
	     else return $plural;
	}
			
	public static function Description()
	{
	   global $config, $cur, $out;
	   if($cur === 'home') { 
	        return $config['description']; 
	   } else {
		    return $out['subtitle']; 
	   }
	} 		
}