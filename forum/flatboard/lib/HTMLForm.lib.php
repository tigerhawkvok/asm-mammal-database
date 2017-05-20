<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class HTMLForm
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
     * Méthode qui convertie du html en texte brut
     * HTMLForm::clean('test');
     *
     * @param string $text String
     * @return string
     */    	
	public static function clean($text)
	{		
		return htmlspecialchars(trim($text), ENT_QUOTES, CHARSET);
	}	
	   
	public static function transNL($text)
	{
		return preg_replace('/\n{3,}/', "\n\n", str_replace(array("\r\n", "\r"), "\n", $text));
	}
	
	public static function hide($text)
	{
		return md5($text.sha1($text));
	}
	
	public static function trip($name, $id)
	{
		global $config;
		if ($name === '')
		{
			return substr($id, -6);
		}
		else
		{
			$parts = explode('#', $name, 2);
			$salt = md5($config['salt'].$parts[1]);
			return  $parts[0].(isset($parts[1])? '#' .substr($salt, -6) : '');
		}
	}
	
	public static function err($eid, $msg)
	{
		if (isset($_SESSION[$eid]))
		{
			unset($_SESSION[$eid]);
			return '&nbsp;<span class="error">' .$msg. '</span>';
		}
		return '';
	}
	
	public static function password($name, $class='w50')
	{
		global $lang;
		return '<div class="form-item">
				<label>' .
					HTMLForm::err($name. 'ErrNotMatch', $lang['errNotMatch']).
					HTMLForm::err('incorrect_password', $lang['incorrect_password']). ' 
					<input type="password" name="' .$name. '" placeholder="' .$lang[$name]. '" class="' .$class. '"/> 
				</label>
				<label> 
					<input type="password" name="' .$name. 'Confirm" placeholder="' .$lang['confirm_password']. '" class="' .$class. '"/>
				</label>
				</div>';
	}
	/**
	 * Méthode qui affiche un zone de saisie
	 *
	 * @param	name		nom de la zone de saisie
	 * @param	value		valeur contenue dans la zone de saisie
	 * @param	type		type du champ (text, password, hidden)
	 * @param	class		class css à utiliser pour formater l'affichage
	 * @param	placeholder valeur du placeholder du champ (html5)
	 * @param	desc 		valeur de la description
	 * @return	stdout
	 **/	
	public static function text($name, $default='', $type='text', $class='', $placeholder='', $desc='')
	{
		global $lang;
		
		$value = Util::isPOST($name) ? HTMLForm::clean($_POST[$name]) : $default;
		$class = $class!='' ? ' class="'.$class.'"' : ' class="w50"';
		$placeholder = $placeholder!='' ? ' placeholder="' .$lang[$placeholder]. '"' : '';
		$desc = $desc!='' ? '<div class="desc">' .$lang[$desc]. '</div>' : '';
		
		return '<div class="form-item">
					<label for="' .$name. '">' .$lang[$name].
						HTMLForm::err($name. 'ErrLen', $lang['errLen']).
						HTMLForm::err($name. 'ErrNb', $lang['errNb']). '
					</label>
					<input type="' .$type. '" id="' .$name. '" name="' .$name. '" value="' .$value. '"' .$class . $placeholder. '/>
					' .$desc. '
				</div>';
	}
	
	public static function textarea($name, $default='', $class='', $desc='', $rows='', $placeholder='')
	{
		global $lang;
		$value = Util::isPOST($name)? HTMLForm::transNL(HTMLForm::clean($_POST[$name])) : $default;
		$class = $class!='' ? ' class="'.$class.'"' : '';
		$desc = $desc!='' ? '<div class="desc">' .$lang[$desc]. '</div>' : '';
		$rows = $rows!='' ? $rows : 10;
		$placeholder = $placeholder!='' ? ' placeholder="' .$lang[$placeholder]. '"' : '';
		return '<div class="form-item">
					<label for="' .$name. '">' .$lang[$name]. HTMLForm::err($name. 'ErrLen', $lang['errLen']).'</label>'.
					Plugin::hook('editor'). '
					<textarea id="' .$name. '" name="' .$name. '" rows="' .$rows. '"' .$class . $placeholder. '>' .$value. '</textarea>
					' .$desc. '
				</div>';
	}

	public static function submit($button='submit')
	{	
		global $lang;		
		return '<div class="form-item">
					<label for="captcha">' .$lang['captcha']. ' 
						<span class="label">
							<img id="cap-img" src="' .BASEPATH . DS . 'lib' .DS. 'Captcha.lib.php" alt="' .$lang['captcha']. '" />
						</span>'.HTMLForm::err('ErrToken', $lang['invalid_token']). 
								 HTMLForm::err('ErrBot', $lang['errBot']). '
					</label>				
					<div class="append w30">
						<input type="text" name="captcha" placeholder="' .$lang['enter_code']. '">
						<button class="button" type="submit">
							' .$lang[$button]. '&nbsp;&nbsp;<i class="fa fa-check" aria-hidden="true"></i>
						</button>
					</div>
				</div>';
	}	
	
	public static function simple_submit($button='submit', $class='', $icon='')
	{
		global $lang;
		$class = $class!='' ? ' class="'.$class.'"' : ' class="button"';
		$icon = $icon!='' ? '<i class="' .$icon. '"></i> ' : '';	
		return  HTMLForm::err('ErrToken', $lang['invalid_token']). '<div class="form-item"><button' .$class. ' type="submit">' .$icon. $lang[$button]. '</button></div>';
	}
	
	public static function select($name, $options, $default = '', $class='', $desc='')
	{
		global $lang;
		$class = $class!='' ? ' class="'.$class.'"' : '';
		$desc = $desc!='' ? '<div class="desc">' .$lang[$desc]. '</div>' : '';
		$selected = Util::isPOST($name) && isset($options[$_POST[$name]])? $_POST[$name] : $default;
		$out = '<div class="form-item">
			<label for="' .$name. '">' .$lang[$name]. '</label>
			<select id="' .$name. '" name="' .$name. '"' .$class. '>';
				foreach($options as $value => $option)
				{
					$out .= '<option value="' .$value. '"' .($value == $selected? ' selected="selected"' : ''). '>' .$option. '</option>';
				}
	$out .= '</select>
				' .$desc. '
			</div>';
		return $out;
	}
		
	public static function form($action, $controls)
	{
		global $token;
		$form  = PHP_EOL .'<form action="' .$action. '" method="post" class="forms">' .PHP_EOL;
		$form .= '<fieldset>' .PHP_EOL;
		$form .= '<input type="hidden" name="_token" value="' .$token. '">' .PHP_EOL;
		$form .= $controls .PHP_EOL;
		$form .= '</fieldset>' .PHP_EOL;
		$form .= '</form>' .PHP_EOL;
		return $form;
	}
	
	public static function preview($name)
	{
		return Util::isPOST($name)? '<div class="message">' .Parser::content(HTMLForm::transNL(HTMLForm::clean($_POST[$name]))). '</div>' : '';
	}
	
	public static function check($name, $min = 1, $max = 40)
	{		
		if(!Util::isPOST($name))
			return false;
		$len = strlen(trim($_POST[$name]));
		if($len >= $min && $len <= $max)
			return true;
		$_SESSION[$name. 'ErrLen'] = 1;
		return false;
	}
	
	public static function checkPass($name)
	{
		if(HTMLForm::check($name) && Util::isPOST($name. 'Confirm') && $_POST[$name] === $_POST[$name. 'Confirm'])
			return true;
		$_SESSION[$name. 'ErrNotMatch'] = 1;
		return false;
	}
	
	public static function checkNb($name)
	{	
		$num = $_POST[$name];	
		if(ctype_digit($num) && $num > 0)	
			return true;
		$_SESSION[$name. 'ErrNb'] = 1;
		return false;
	}

	public static function checkMail($email) {
      return filter_var($email, FILTER_VALIDATE_EMAIL);
    }
    		
	public static function checkBot()
	{
		if(!Util::isPOST('captcha'))
			return false;
		if(isset($_SESSION['captcha']) && $_POST['captcha'] === $_SESSION['captcha'])
			return true;
		$_SESSION['ErrBot'] = 1;
		return false;
	}
}