<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/
$smilies = array(
	':)' => 'smile.png',
	'=)' => 'smile.png',
	':|' => 'neutral.png',
	'=|' => 'neutral.png',
	':(' => 'sad.png',
	'=(' => 'sad.png',
	':D' => 'big_smile.png',
	'=D' => 'big_smile.png',
	':o' => 'yikes.png',
	':O' => 'yikes.png',
	';)' => 'wink.png',
	':/' => 'hmm.png',
	':P' => 'tongue.png',
	':p' => 'tongue.png',
	':lol:' => 'lol.png',
	':mad:' => 'mad.png',
	':rolleyes:' => 'roll.png',
	':cool:' => 'cool.png');
	
class Parser
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
	/**
	 * 
	 * @param $string is the actual string
	 * @param $word_length to storten 
	 * @param $endstring will concat the string with some extra string if the word limit is less than word count 
	 */
	public static function summary($string, $word_length=100, $endstring=' &hellip;') {
	    $retval = $string;
	    // if a string is given instead of integer return total string.
	    $word_length = (intval($word_length) == 0 ) ? strlen($retval) : intval($word_length);
	    $array = explode(" ", $string);
	    if (count($array) <= $word_length) {
	        $retval = $string;
	    } else {
	        array_splice($array, $word_length);
	        $retval = implode(" ", $array);
	        $retval .= $endstring;
	    }
	    return $retval;
	}
	//
	// Replace string matching regular expression
	//
	// This function takes care of possibly disabled unicode properties in PCRE builds
	//
	public static function ucp_preg_replace($pattern, $replace, $subject, $callback = false)
	{
		if($callback)
			$replaced = preg_replace_callback($pattern, create_function('$matches', 'return '.$replace.';'), $subject);
		else
			$replaced = preg_replace($pattern, $replace, $subject);
	
		// If preg_replace() returns false, this probably means unicode support is not built-in, so we need to modify the pattern a little
		if ($replaced === false)
		{
			if (is_array($pattern))
			{
				foreach ($pattern as $cur_key => $cur_pattern)
					$pattern[$cur_key] = str_replace('\p{L}\p{N}', '\w', $cur_pattern);
	
				$replaced = preg_replace($pattern, $replace, $subject);
			}
			else
				$replaced = preg_replace(str_replace('\p{L}\p{N}', '\w', $pattern), $replace, $subject);
		}
	
		return $replaced;
	}
	
	//
	// A wrapper for ucp_preg_replace
	//
	function ucp_preg_replace_callback($pattern, $replace, $subject)
	{
		return Parser::ucp_preg_replace($pattern, $replace, $subject, true);
	}		
	//
	// Convert a series of smilies to images
	//
	public static function do_smilies($text)
	{
		global $smilies;
	
		$text = ' '.$text.' ';
	
		foreach ($smilies as $smiley_text => $smiley_img)
		{
			if (strpos($text, $smiley_text) !== false)
				$text = Parser::ucp_preg_replace('%(?<=[>\s])'.preg_quote($smiley_text, '%').'(?=[^\p{L}\p{N}])%um', '<img src="'.Parser::fb_htmlspecialchars(EMOTICONS_DIR.$smiley_img).'" style="margin-top:6px" alt="'.substr($smiley_img, 0, strrpos($smiley_img, '.')).'">', $text);
		}
	
		return substr($text, 1, -1);
	}
	//
	// Calls htmlspecialchars with a few options already set
	//
	public static function fb_htmlspecialchars($str)
	{
		return htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
	}		
	
	public static function content($text, $summary = false)
	{
		global $config;		
		# smilies
		$text = Parser::do_smilies($text);
		
		if($config['editor'] === 'markdown'){	
			global $Parsedown, $BBlight;	
			# Parse markdown content.
			$text = $Parsedown->text($text);
			$text = $BBlight->toHTML($text, false, true);
		} else {
			global $BBcode;
			# Parse BBcode content.	
			$text = $BBcode->toHTML($text, false, true);	
		}			
		return $text;
	}

	public static function title($string)
	{
		global $lang;
		$string = str_replace(array('[SOLVED]','[solved]'), '<span class="label success upper outline">' .$lang['solved']. '</span>', $string);
		$string = str_replace(array('[PLUGIN]','[plugin]'), '<span class="label focus">Plugin</span>', $string);
		$string = str_replace(array('[TRANSLATION]','[translation]'), '<span class="label black">Translation</span>', $string);
		$string = str_replace(array('[FRENCH]','[french]'), '<img src="./uploads/flags/fr.png" alt="German Flag">', $string);
		$string = str_replace(array('[GERMAN]','[german]'), '<img src="./uploads/flags/de.png" alt="German Flag">', $string);
		$string = str_replace(array('[THEME]','[theme]'), '<span class="label warning">Theme</span>', $string);
		return $string;
	}
	
	public static function pre2htmlentities($string)
	{
		return preg_replace_callback('/<pre.*?><code(.*?)>(.*?)<\/code><\/pre>/imsu',
			create_function('$input', 'return "<pre><code $input[1]>".htmlentities($input[2])."</code></pre>";'),
			$string);
	}
		
	// Convert special HTML entities back to characters
	public static function htmlDecode($text)
	{
		$flags = ENT_COMPAT;
		if(defined('ENT_HTML5')) {
			$flags = ENT_COMPAT|ENT_HTML5;
		}
		return htmlspecialchars_decode($text, $flags);
	}
	// Highlighted search word
	function highlight_word( $content, $word, $color ) {
	    $replace = '<span style="background-color: ' . $color . ';">' . $word . '</span>';
	    $content = str_replace( $word, $replace, $content );
	
	    return $content;
	}
}