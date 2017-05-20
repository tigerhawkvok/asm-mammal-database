<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class flatDB
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
    	
	public static function fdir($dir)
	{
    	$ignored = array('.', '..', '.svn', '.git', 'Thumbs.db', 'index.html', '.DS_Store');	
		$files = array();
		$dh = opendir($dir);
		while(false !== ($file = readdir($dh)))
		{
			if (in_array($file, $ignored)) continue;			
			$file = explode('.', $file, 2);
			$files[] = $file[0];
		}
		closedir($dh);
		return $files;
	}
	
	public static function indir($file, $dir, $ext = '')
	{
		return strpos($file, DS) === false && strpos($file, '.') === false && strpos($file, "\0") === false && file_exists($dir. DS .$file .$ext);
	}
	
	public static function readEntry($type, $file)
	{
		return eval('return ' .file_get_contents(DATA_DIR . $type . DS . $file . '.dat.php', false, NULL, 14). ';');
	}
	
	public static function saveEntry($type, $file, $data)
	{
		return file_put_contents(DATA_DIR . $type. DS . $file . '.dat.php', "<?php exit;?>\n" .var_export($data, JSON_PRETTY_PRINT), LOCK_EX);
	}
	
	public static function deleteEntry($type, $file)
	{
		unlink(DATA_DIR . $type . DS . $file . '.dat.php');
		return true;
	}
	
	public static function listEntry($type)
	{
		return flatDB::fdir(DATA_DIR . $type);
	}
	
	public static function isValidEntry($type, $file)
	{
		return flatDB::indir($file, DATA_DIR . $type, '.dat.php');
	}
	
	public static function newEntry()
	{
		return date('Y-m-dHis').substr(uniqid(), -5);
	}
	/**
	 * Méthode qui formate une chaine de caractères en supprimant des caractères non valides
	 **/
	public static function removeAccents($str) {

		$str = htmlentities($str, ENT_NOQUOTES, CHARSET);
		$a = array('À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'ÿ', 'Ā', 'ā', 'Ă', 'ă', 'Ą', 'ą', 'Ć', 'ć', 'Ĉ', 'ĉ', 'Ċ', 'ċ', 'Č', 'č', 'Ď', 'ď', 'Đ', 'đ', 'Ē', 'ē', 'Ĕ', 'ĕ', 'Ė', 'ė', 'Ę', 'ę', 'Ě', 'ě', 'Ĝ', 'ĝ', 'Ğ', 'ğ', 'Ġ', 'ġ', 'Ģ', 'ģ', 'Ĥ', 'ĥ', 'Ħ', 'ħ', 'Ĩ', 'ĩ', 'Ī', 'ī', 'Ĭ', 'ĭ', 'Į', 'į', 'İ', 'ı', 'Ĳ', 'ĳ', 'Ĵ', 'ĵ', 'Ķ', 'ķ', 'Ĺ', 'ĺ', 'Ļ', 'ļ', 'Ľ', 'ľ', 'Ŀ', 'ŀ', 'Ł', 'ł', 'Ń', 'ń', 'Ņ', 'ņ', 'Ň', 'ň', 'ŉ', 'Ō', 'ō', 'Ŏ', 'ŏ', 'Ő', 'ő', 'Œ', 'œ', 'Ŕ', 'ŕ', 'Ŗ', 'ŗ', 'Ř', 'ř', 'Ś', 'ś', 'Ŝ', 'ŝ', 'Ş', 'ş', 'Š', 'š', 'Ţ', 'ţ', 'Ť', 'ť', 'Ŧ', 'ŧ', 'Ũ', 'ũ', 'Ū', 'ū', 'Ŭ', 'ŭ', 'Ů', 'ů', 'Ű', 'ű', 'Ų', 'ų', 'Ŵ', 'ŵ', 'Ŷ', 'ŷ', 'Ÿ', 'Ź', 'ź', 'Ż', 'ż', 'Ž', 'ž', 'ſ', 'ƒ', 'Ơ', 'ơ', 'Ư', 'ư', 'Ǎ', 'ǎ', 'Ǐ', 'ǐ', 'Ǒ', 'ǒ', 'Ǔ', 'ǔ', 'Ǖ', 'ǖ', 'Ǘ', 'ǘ', 'Ǚ', 'ǚ', 'Ǜ', 'ǜ', 'Ǻ', 'ǻ', 'Ǽ', 'ǽ', 'Ǿ', 'ǿ');
		$b = array('A', 'A', 'A', 'A', 'A', 'A', 'AE', 'C', 'E', 'E', 'E', 'E', 'I', 'I', 'I', 'I', 'D', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'U', 'U', 'U', 'U', 'Y', 's', 'a', 'a', 'a', 'a', 'a', 'a', 'ae', 'c', 'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i', 'n', 'o', 'o', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u', 'y', 'y', 'A', 'a', 'A', 'a', 'A', 'a', 'C', 'c', 'C', 'c', 'C', 'c', 'C', 'c', 'D', 'd', 'D', 'd', 'E', 'e', 'E', 'e', 'E', 'e', 'E', 'e', 'E', 'e', 'G', 'g', 'G', 'g', 'G', 'g', 'G', 'g', 'H', 'h', 'H', 'h', 'I', 'i', 'I', 'i', 'I', 'i', 'I', 'i', 'I', 'i', 'IJ', 'ij', 'J', 'j', 'K', 'k', 'L', 'l', 'L', 'l', 'L', 'l', 'L', 'l', 'l', 'l', 'N', 'n', 'N', 'n', 'N', 'n', 'n', 'O', 'o', 'O', 'o', 'O', 'o', 'OE', 'oe', 'R', 'r', 'R', 'r', 'R', 'r', 'S', 's', 'S', 's', 'S', 's', 'S', 's', 'T', 't', 'T', 't', 'T', 't', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'W', 'w', 'Y', 'y', 'Y', 'Z', 'z', 'Z', 'z', 'Z', 'z', 's', 'f', 'O', 'o', 'U', 'u', 'A', 'a', 'I', 'i', 'O', 'o', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'A', 'a', 'AE', 'ae', 'O', 'o');
		$str = str_replace($a, $b, $str);
		$str = preg_replace('#\&([A-za-z])(?:acute|cedil|circ|grave|ring|tilde|uml|uro)\;#', '\1', $str);
		$str = preg_replace('#\&([A-za-z]{2})(?:lig)\;#', '\1', $str); # pour les ligatures e.g. '&oelig;'
		$str = preg_replace('#\&[^;]+\;#', '', $str); # supprime les autres caractères
		return $str;
	}

	/**
	 * Méthode qui convertit une chaine de caractères au format valide pour une url
	 **/
	public static function slug($str) {

		$str = strtolower(flatDB::removeAccents($str,CHARSET));
		$str = preg_replace('/[^[:alnum:]]+/',' ',$str);
		return strtr(trim($str), ' ', '-');
	}	

	/**
	 * Méthode récursive qui supprimes tous les dossiers et les fichiers d'un répertoire
	 **/
	public static function _deleteDir($deldir) {

		if(is_dir($deldir) AND !is_link($deldir)) {
			if($dh = opendir($deldir)) {
				while(FALSE !== ($file = readdir($dh))) {
					if($file != '.' AND $file != '..') {
						flatDB::_deleteDir($deldir . '/' . $file);
					}
				}
				closedir($dh);
			}
			return rmdir($deldir);
		}
		return unlink($deldir);
	}

	/**
	 * Méthode qui supprime un dossier et son contenu
	 **/
	public static function removeDirectory($deldir, $phrase) {
		global $lang;
		# suppression du dossier des images et de son contenu
		if(flatDB::deleteDir($deldir))
			return Plugin::redirectMsg($lang[$phrase], 'config.php', $lang['config'], 'message success');
		else
			return Plugin::redirectMsg($lang['folder_error'], 'config.php', $lang['config'], 'message error');
	}
		
	/**
	 * Méthode récursive qui supprimes tous les dossiers et les fichiers d'un répertoire
	 **/
	public static function deleteDir($dir){
		if ($handle = opendir($dir)) {
			while (false !== ($file = readdir($handle))) {
				if ($file != '.' && $file != '..') {
					if(is_dir($dir . $file)) {
						if(!rmdir($dir . $file)) // Empty directory? Remove it
						{
							flatDB::deleteDir($dir .'/'. $file . '/'); // Not empty? Delete the files inside it
						}
					} else {
						unlink($dir . $file);
					}
				}
			}
			closedir($handle);
			@rmdir($dir);
		}
	}
}