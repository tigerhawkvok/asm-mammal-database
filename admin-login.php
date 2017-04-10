<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <?php
      $debug = false;
      $title = "ASM SADB Admin Login";
      $pageDescription = "The American Society of Mammalogists' searchable database of mammals across the world. Species accounts, photos, geolocation, and more.";
      ?>
    <title><?php echo $title; ?></title>

    <?php include_once dirname(__FILE__)."/modular/header.php"; ?>

  </head>
    <?php
       require dirname(__FILE__)."/modular/bodyFrame.php";
       echo $bodyOpen;
       if ($debug) {
           echo "<div class='alert alert-danger'><strong>Warning:</strong> Debugging is enabled on admin-login.php</div>";
           // ini_set('error_log', '/usr/local/web/amphibian_disease/error-admin.log');
           ini_set('display_errors', 1);
           ini_set('log_errors', 1);
           error_reporting(E_ALL);
           // $string = "Foobar";
           // $pass = "123";
           // $methods = print_r(openssl_get_cipher_methods(), true);
           // $encrypted = openssl_encrypt($string, "AES-256-CBC", $pass);
           // $decrypted = openssl_decrypt($encrypted, "AES-256-CBC", $pass);
           // $encrypt_test = "<pre>OpenSSL Encrypt Test: \n\n $methods \n\n $encrypted \n\n $decrypted</pre>";
           // echo $encrypt_test;
       }
       require 'CONFIG.php';
       require 'admin/login.php';
       echo $login_output;
       echo $bodyClose;
     ?>