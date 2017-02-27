<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <?php
      $title = "ASM SADB Admin Login";
      $pageDescription = "The American Society of Mammalogists' searchable database of mammals across the world. Species accounts, photos, geolocation, and more.";
      ?>
    <title><?php echo $title; ?></title>

    <?php include_once dirname(__FILE__)."/modular/header.php"; ?>

  </head>
  <body>
    <?php
       $debug = false;
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
       require_once 'CONFIG.php';
       require_once 'admin/login.php';
       echo $login_output;
       ?>
    <footer class="row">
      <div class="col-md-7 col-xs-12">
        <copyright-statement copyrightStart="2017">American Society of Mammologists</copyright-statement>
      </div>
      <div class="col-md-1 col-xs-4">
        <paper-icon-button icon="icons:chrome-reader-mode" class="click" data-href="https://amphibian-disease-tracker.readthedocs.org" data-toggle="tooltip" title="Documentation" data-newtab="true"></paper-icon-button>
      </div>
      <div class="col-md-1 col-xs-4">
        <paper-icon-button icon="glyphicon-social:github" class="click" data-href="https://github.com/tigerhawkvok/asm-mammal-database" data-toggle="tooltip" title="Visit us on GitHub" data-newtab="true"></paper-icon-button>
      </div>
      <div class="col-md-1 col-xs-4">
        <paper-icon-button icon="icons:bug-report" class="click" data-href="https://github.com/tigerhawkvok/asm-mammal-database/issues/new" data-toggle="tooltip" title="Report an issue" data-newtab="true"></paper-icon-button>
      </div>
      <div class="col-md-2 col-xs-6 hidden-xs">
        Written with <paper-icon-button icon="icons:polymer" class="click" data-href="https://www.polymer-project.org" data-newtab="true"></paper-icon-button>
      </div>
    </footer>
  </body>
</html>
