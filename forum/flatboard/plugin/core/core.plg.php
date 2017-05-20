<?php defined('FLATBOARD') or die('Flatboard Community.');
/**
 * Core
 *
 * @author 		Frédéric K.
 * @copyright	(c) 2015-2017
 * @license		http://opensource.org/licenses/MIT
 * @package		FlatBoard
 * @version		1.0.2
 * @update		2016-04-16
 */	
	
function core_install()
{
	$plugin = 'core';
	if (flatDB::isValidEntry('plugin', $plugin))
		return;

    $data[$plugin.'state'] = true;  // Ne pas désactiver !     
    flatDB::saveEntry('plugin', $plugin, $data);
}

function core_head()
{
  $plugin = 'core';
  $out  = '';
  # Lecture des données
  $data = flatDB::readEntry('plugin', $plugin);
  if ($data[$plugin.'state']) {
	$destination = PLUGIN_DIR . $plugin . DS . 'assets' . DS . 'css' .DS;
	$css = array(
        $destination. 'hint.css',
        $destination. 'checkbox.css'
    );
            
	echo Asset::Stylesheet($css, HTML_THEME_DIR . $destination, 'core.min.css'); 
	// Font Awesome Minify don't work, added manually here	
	$out .= '<link href="' .HTML_PLUGIN_DIR . $plugin . DS . 'assets' . DS . 'css' . DS . 'font-awesome.min.css?ver=4.7.0" rel="stylesheet" type="text/css" />' .(User::isWorker()? '' : '').PHP_EOL; 
  } 
  return $out;
}
                
function core_footerJS()
{
	global $lang, $cur, $config;
	$plugin = 'core';
	$out='';
	$assets = HTML_PLUGIN_DIR . $plugin. DS . 'assets' .DS;
	# Lecture des données
	$data = flatDB::readEntry('plugin', $plugin);
	if ($data[$plugin.'state']) {
		$out .= (User::isWorker()? '' : '').PHP_EOL;
	    	
	    // Infinite Ajax Scroll : http://infiniteajaxscroll.com/ 
	    if($cur=='home') {
		    $out .= '<script src="' . $assets . 'js' . DS . 'jquery-ias.min.js?ver=2.2.2"></script>'.PHP_EOL;  
		    $out .= '<script>
			var ias = $.ias({
			  container:  ".col-8",
			  item:       ".item",
			  pagination: ".pagination",
			  next:       ".next a",
			  delay: 	  600
			});
		    ias.extension(new IASSpinnerExtension({
			    html: \'<div class="ias-spinner" style="text-align: center; margin: 10px;"><i class="fa fa-lg fa-circle-o-notch fa-spin"></i> ' .$lang['loading']. '</div>\'
			}));
			ias.extension(new IASTriggerExtension({ 
				html: \'<div class="ias-trigger ias-trigger-next" style="text-align: center; margin: 10px;"><button class="small outline"><i class="fa fa-refresh"></i> ' .$lang['load_more']. '</button></a></div>\',
				offset: ' .$config['nb_page_scroll_infinite']. '
			}));
			ias.extension(new IASNoneLeftExtension({ 
				html: \'<div class="ias-noneleft" style="text-align:center; margin: 10px;"><button class="button red small outline">' .$lang['no_more_load']. '</button></div>\' 
			}));	
	</script>' .PHP_EOL;
		}
	}
	return $out;
}

?>