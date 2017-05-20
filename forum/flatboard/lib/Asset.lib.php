<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
 *
 * -- CODE: -----------------------------------------------------------------------
 *
 * $css = array(
 *       'http://example/files/sample_css_file_1.css',
 *       'http://example/files/sample_css_file_2.css',
 *       );
 *       
 *	echo Asset::Stylesheet($css, 'minified_files/', md5("my_mini_file").".css");
 *
 * --------------------------------------------------------------------------------
 *
 */

class Asset {

    /**
     * Protected constructor since this is a static class.
     *
     * @access  protected
     */
    protected function __construct()
    {
        // Nothing here
    }

	public static function Stylesheet($array_files, $destination_dir, $dest_file_name='styles.min.css'){
		global $config;
		$content = '';
		
		if(!flatDB::isValidEntry('config', 'config')) // For install.php
		{
			$cache_dir = THEME_DIR . 'kube' . DS . 'cache' .DS;
			$index_file = $cache_dir. 'index.html';
			$css_path = THEME_DIR . 'kube' . DS . 'css' .DS;
			$css_cache_file = $cache_dir. $dest_file_name;
		} else {
			$cache_dir = THEME_CONFIG_PATH . 'cache' .DS;
			$index_file = $cache_dir. 'index.html';
			$css_path = $destination_dir;
			$css_cache_file = $cache_dir. $dest_file_name;			
		}		
		// Make cache folder 
		if(!is_dir($cache_dir) && (!@mkdir($cache_dir) || !@chmod($cache_dir, 0777)));	
		// Make index.html
		if (!file_exists($index_file)) {
			$f = fopen($index_file, 'a+');
			fwrite($f, '');
			fclose($f);	
		}	


	    if(!file_exists($css_cache_file)){ //continue only if file doesn't exist    
	    	$cache_time = @filemtime($css_cache_file);    	
	        foreach ($array_files as $file){ //loop through array list
		        // Check filemtime
		        $time = @filemtime($file);
			    $content .= Asset::compressCSS($file); // Compress all file
	        }
            #if ($time > $cache_time)
			if (($fd = fopen($css_cache_file, 'w')) !== false) { 
			  fwrite($fd, $content);   
			  fclose($fd); 
			}				        
	        return '<link rel="stylesheet" href="' .$css_cache_file. '" />'; //output combined file
	        
	    } else {     
	        //use stored file
	        $cache_file = HTML_THEME_DIR . 'cache' . DS . $dest_file_name;
	        return '<link rel="stylesheet" href="' .$cache_file. '?ver=' .VERSION. '" />'; //output cached combine file
	    }
	}	
	public static function compressCSS($file) {
		$filedata = @file_get_contents($file);
		$filedata = str_replace(array("\r\n", "\r", "\n", "\t", '  ', '    ', '    '), '', $filedata);
		$filedata = preg_replace('!/\*[^*]*\*+([^/][^*]*\*+)*/!', '', $filedata);
	    $filedata = str_replace('{ ', '{', $filedata);
	    $filedata = str_replace(' }', '}', $filedata);
	    $filedata = str_replace('; ', ';', $filedata);
	    $filedata = str_replace(', ', ',', $filedata);
	    $filedata = str_replace(' {', '{', $filedata);
	    $filedata = str_replace('} ', '}', $filedata);
	    $filedata = str_replace(': ', ':', $filedata);
	    $filedata = str_replace(' ,', ',', $filedata);
	    $filedata = str_replace(' ;', ';', $filedata);	
		return $filedata;
	}
	public static function updateCSS() {
		global $css_path, $css_cache_file, $css_files;
		if (file_exists($css_cache_file)) {
			$cache_time = filemtime($css_cache_file);
			foreach ($css_files as $file) {
				if (file_exists($css_path.$file)) {
					$time = filemtime($css_path.$file);
					if ($time > $cache_time) {
						return Asset::joinCSSFiles();
						break;
					}
				}
			}
		} else {
			return Asset::joinCSSFiles();
		}
		return file_get_contents($css_cache_file);;
	}
	
	public static function joinCSSFiles() {
		global $css_cache_file, $css_files, $css_path;
		$data = '';
		foreach ($css_files as $file) {
			if (file_exists($css_path.$file)) {
				$data .= Asset::compressCSS($css_path.$file);
			}
		}
		file_put_contents($css_cache_file, $data);
		return $data;
	}

}