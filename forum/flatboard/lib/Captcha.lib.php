<?php
/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

header("Content-Type: image/png");
session_start();

$text = substr(sha1(time()), 0, rand(5,8));
$_SESSION['captcha'] = $text;

// Paramètres
$parametres = array('w'=>85, 'h'=>30, 'bgcolor'=>'224,225,225', 'txcolor'=>'28,134,242');

if(isset($_GET['w']))		$parametres['w']       = (int)$_GET['w'];
if(isset($_GET['h']))		$parametres['h'] 	   = (int)$_GET['h'];
if(isset($_GET['bgcolor'])) $parametres['bgcolor'] = $_GET['bgcolor'];
if(isset($_GET['txcolor'])) $parametres['txcolor'] = $_GET['txcolor'];

// Taille de l'image
$captcha = @imagecreate($parametres['w'], $parametres['h']);

// Couleur du fond
$exp = explode(',',$parametres['bgcolor']);
$bgcolor = imagecolorallocate($captcha, $exp[0], $exp[1], $exp[2]);

// Couleur du text
$exp = explode(',',$parametres['txcolor']);
$textcolor = imagecolorallocate($captcha, $exp[0], $exp[1], $exp[2]);

// Création du PNG
imagestring($captcha, 5, 5, $parametres['h']/2 - 8, $text, $textcolor);
imagepng($captcha);
imagedestroy($captcha);
?>
