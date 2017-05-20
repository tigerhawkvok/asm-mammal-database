<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * CSRF token class
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class CSRF
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
     * Generate new CSRF token based on IP address and random string.
     *
     * @return string
     */
    public static function generate()
    {	// Fixed by HD#20af3 flatboard.free.fr/view.php/topic/2016-12-071103229c648
        #return $_SESSION['token'] = base64_encode(implode('|', [md5($_SERVER['REMOTE_ADDR']), uniqid()]));
        return $_SESSION['token'] = base64_encode(implode('|', array(md5($_SERVER['REMOTE_ADDR']), uniqid())));
    }

    /**
     * Checks given token and IP address if valid.
     *
     * @param $token
     *
     * @return bool
     */
    public static function check($token)
    {
        if (isset($_SESSION['token']) && $token === $_SESSION['token']) {
            $ex = explode('|', base64_decode($token));
            if ($ex[0] !== md5($_SERVER['REMOTE_ADDR'])) {
                return false;
            }

            unset($_SESSION['token']);

            return true;
        }
        
		$_SESSION['ErrToken'] = 1;
        return false;
    } 
           
}