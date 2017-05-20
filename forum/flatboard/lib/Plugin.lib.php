<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class Plugin
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
	
	public static function hook($name, $param = null)
	{
		global $plugins;
		$out = '';
		foreach($plugins as $plugin)
		{
			if(Plugin::isValidHook($name, $plugin))					
				$out .= Plugin::myHook($name, $plugin, $param);
		}
		return $out;
	}
	
	public static function isValidHook($hook, $plugin)
	{
		return function_exists($plugin. '_' .$hook);
	}
	
	public static function myHook($hook, $plugin, $param = null)
	{
		$hookFunc = $plugin. '_' .$hook;
		return $hookFunc($param);
	}
	/**
	 * Méthode qui affiche une notification
	 * $class = message error, message success, message warning, message focus, message black, message inverted
	 **/	
	public static function redirectMsg($title, $url, $destination, $class='message', $autoredirect=TRUE)
	{
		global $lang; 		
		return '<div class="'.$class.'" data-component="message">
				   <div class="text-center">
					   <strong>' .$title. '</strong>
		               ' .($autoredirect ? '<br /><a href="'.$url.'">' .$lang['redirect']. '&nbsp;' .$destination.'</a><br />
					   <i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i>
					   <span class="sr-only">Loading...</span>' :''). '	 
				  </div>             	
	              <span class="close small"></span>
	            </div>' .($autoredirect ? '
	            <script>
					setTimeout(function () {    
					    window.location.href = "'.$url.'"; 
					},1500); // 1.5 seconds	            
	            </script>' :'');          
	}

	public static function installPlugin($plugin)
	{     
	   global $lang, $token;

       $out ='';
     
       if(!empty($_POST) && CSRF::check($token) )
       {
               $data[$plugin.'state'] = HTMLForm::clean($_POST['state']);             
               flatDB::saveEntry('plugin', $plugin, $data[$plugin.'state']);
       }
        else
       {
               if (flatDB::isValidEntry('plugin', $plugin))
               $data = flatDB::readEntry('plugin', $plugin);
               $url = Util::baseURL(). 'config.php' . DS . 'plugin' . DS . $plugin;
               
               $out .= '<input class="tgl tgl-flat" type="checkbox" id="' .$plugin. '"' .($data[$plugin.'state'] ? ' checked' : ''). ' onClick="location.href=\''.$url.'\'">
			   				<label class="tgl-btn" for="' .$plugin. '"></label>';
       }
       return $out;

	}
		
	public static function isHome()
	{
	   global $config,$lang,$cur;
	   if($config['homepage'] !== 'index.php') 
		    return '<li' .(!$cur== $_GET['plugin'] ? ' class="active"':''). '><a href="index.php">' .$lang['home']. '</a></li>'; 
	} 

}