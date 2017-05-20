<?php defined('FLATBOARD') or die('Flatboard Community.');
/**
 * editor
 *
 * @author 		Frédéric K.
 * @copyright	(c) 2016-2017
 * @license		http://opensource.org/licenses/MIT
 * @package		FlatBoard
 * @version		1.0
 * @update		2017-04-15
 */	             	
/**
 * On pré-installe les paramètres par défauts.
**/
function editor_install()
{
	$plugin = 'editor';
	if (flatDB::isValidEntry('plugin', $plugin))
		return;
	$data[$plugin.'state'] 	 = true;  // Ne pas désactiver !
	$data['tabSize']         = '2';
	$data['markdown_toolbar'] = '"bold", "italic", "strikethrough", "heading", "|", "link", "image", "code", "horizontal-rule", "table", "|", "preview", "side-by-side", "|", "undo", "redo", "|", "fullscreen", "guide"';
	$data['bbcode_toolbar']  = '"bold,italic,underline,strike|,img,link,|,fontcolor,fontsize,|,justifycenter,justifyright,|,blockquote,code"';         
    $data['idContent']       = 'content';               
    flatDB::saveEntry('plugin', $plugin, $data);          
}
 /*
** Admin
*/
function editor_config()
{     
	   global $config, $lang, $token;
       $plugin = 'editor';
       $out ='';      
       if(!empty($_POST) && CSRF::check($token) )
       {
	       	$data[$plugin.'state']= true;
            $data['idContent'] = HTMLForm::clean($_POST['idContent']);
            $data['tabSize'] = HTMLForm::clean($_POST['tabSize']);
            $data['markdown_toolbar'] = HTMLForm::clean($_POST['markdown_toolbar']); 
            $data['bbcode_toolbar'] = HTMLForm::clean($_POST['bbcode_toolbar']);          
            flatDB::saveEntry('plugin', $plugin, $data);
            $out .= Plugin::redirectMsg($lang['plugin'].'&nbsp;<b>'.$lang[$plugin.'name']. '</b>','config.php' . DS . 'plugin' . DS . $plugin, $lang['data_save']);
       }
        else
       {
            if (flatDB::isValidEntry('plugin', $plugin))
            $data = flatDB::readEntry('plugin', $plugin);
            $out .= HTMLForm::form('config.php' . DS . 'plugin' . DS . $plugin,
            HTMLForm::text('idContent',isset($data)? $data['idContent'] : ''). 
            HTMLForm::text('tabSize',isset($data)? $data['tabSize'] : ''). 
			HTMLForm::textarea('markdown_toolbar', $data['markdown_toolbar'], 'w70', '', 4).
            HTMLForm::textarea('bbcode_toolbar', $data['bbcode_toolbar'], 'w70', '', 4).         
            HTMLForm::simple_submit());
       }
       return $out;
}
 /*
** Css
*/
function editor_head()
{
  global $config;
  $plugin = 'editor';
  # Lecture des données
  if ($config['editor'] == 'markdown') 
     return '<link href="' .HTML_PLUGIN_DIR . $plugin . DS . 'dist' . DS . 'simplemde.min.css" rel="stylesheet" type="text/css">'.PHP_EOL; 
  else
     return '<!-- Load WysiBB Theme -->
	 		<link rel="stylesheet" href="' .HTML_PLUGIN_DIR . $plugin . DS . 'wysibb' . DS . 'theme' . DS . 'default' . DS . 'wbbtheme.css" />
	 		<style>.img-zoom{max-width:350px;-webkit-transition:all .2s ease-in-out;-moz-transition:all .2s ease-in-out;-o-transition:all .2s ease-in-out;-ms-transition:all .2s ease-in-out}.transition{-webkit-transform:scale(2);-moz-transform:scale(2);-o-transform:scale(2);transform:scale(2)}.zoom{display:inline-block;position:relative}.zoom img,.zoom:after{display:block}.zoom:after{content:\'\';display:block;width:33px;height:33px;position:absolute;top:0;right:0;background:url(' .HTML_PLUGIN_DIR . $plugin . DS . 'zoom.png)}.zoom img::-moz-selection{background-color:transparent}.zoom img::selection{background-color:transparent}</style>'.PHP_EOL;         
}
 /*
** JavaScript
*/
function editor_footerJS()
{
  global $config, $out;
  $plugin = 'editor';
  # Lecture des données
  $data = flatDB::readEntry('plugin', $plugin);  
  $html  = '';
  if (in_array($out['self'], array('add', 'edit', 'view')))
   {
	   	if ($config['editor'] == 'markdown')
	   	{

	   		$html .= '<script src="' .HTML_PLUGIN_DIR . $plugin. DS . 'dist' . DS . 'simplemde.min.js"></script>'.PHP_EOL;
			$html .= '<script>$(document).ready(function() { ';
			$html .= 'var simplemde = new SimpleMDE({
						element: document.getElementById("'.$data['idContent'].'"),
						status: true,
						toolbarTips: true,
						toolbarGuideIcon: true,
						autofocus: true,
						lineWrapping: true,
						indentWithTabs: true,
						tabSize: '.$data['tabSize'].',
						spellChecker: false,
						toolbar: [' .Parser::htmlDecode($data['markdown_toolbar']). ']
					});			
					$(\'.button[href^="add.php"]\').click(function(event) {
						event.preventDefault();
						if($(this).siblings(\'#form\').length > 0) {
							$(this).siblings(\'#form\').slideUp(\'slow\', function(){ $(this).remove(); });			
						} else {
							$(\'#form\').remove();
							$(\'<div id="form"></div>\').hide().insertAfter(this).load($(this).attr(\'href\') + \' form\', function() {
								var simplemde = new SimpleMDE({
									element: document.getElementById("' .$data['idContent']. '"),
									status: true,
									toolbarTips: true,
									toolbarGuideIcon: true,
									autofocus: true,
									lineWrapping: true,
									indentWithTabs: true,
									tabSize: '.$data['tabSize'].',
									spellChecker: false,
									toolbar: [' .Parser::htmlDecode($data['markdown_toolbar']). ']
								});
								$(this).slideDown(\'slow\');
							});
						}
					});';
			$html .= '}); </script>'.PHP_EOL;	    
		} else {
	   	   # BBcode
	   	   $html .= '<!-- Load WysiBB JS and Theme -->
		   <script src="' .HTML_PLUGIN_DIR . $plugin . DS . 'wysibb' . DS . 'jquery.wysibb.min.js"></script>'.PHP_EOL;
		   $JSlang = HTML_PLUGIN_DIR . $plugin . DS . 'wysibb' . DS . 'lang' . DS . $config['lang']. '.js';
		   if (file_exists($JSlang)) $html .= '<script src="' .$JSlang. '"></script>'.PHP_EOL;
		   $html .= '<script>
					$(function() {
						var wbbOpt = {buttons: ' .Parser::htmlDecode($data['bbcode_toolbar']). ', lang: "' .$config['lang']. '"}
						$(\'#'.$data['idContent'].'\').wysibb(wbbOpt);
					})
			   
		   			$(document).ready(function(){ 
						$(\'.button[href^="add.php"], .button[href^="edit.php"]\').click(function(event) {
							event.preventDefault();
							if($(this).siblings("#form").length > 0) {
								$(this).siblings("#form").slideUp("slow", function(){ $(this).remove(); });			
							} else {
								$("#form").remove();
								$(\'<div id="form"></div>\').hide().insertAfter(this).load($(this).attr("href") + " form", function() {
									var wbbOpt = {buttons: ' .Parser::htmlDecode($data['bbcode_toolbar']). ', lang: "' .$config['lang']. '"}
									$(\'#'.$data['idContent'].'\').wysibb(wbbOpt);
									$(this).slideDown("slow");
								});
							}
						});					
					});		
					$(document).ready(function(){
						$(\'.img-zoom\').hover(function() {
							$(this).addClass(\'transition\');
			
						}, function() {
							$(this).removeClass(\'transition\');
						});
					});							
					</script>'.PHP_EOL;	
		}		   
   }
   return $html;    
}
?>