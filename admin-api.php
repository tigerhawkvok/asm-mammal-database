<?php

/***
 * Handle admin-specific requests
 ***/

#$debug = true;


if ($debug) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('AdminAPI is running in debug mode!');
}

try {
    ini_set('post_max_size', '500M');
    ini_set('upload_max_filesize', '500M');
} catch (Exception $e) {
    
}

$print_login_state = false;
require_once("CONFIG.php");
require_once(dirname(__FILE__)."/core/core.php");

$db = new DBHelper($default_database,$default_sql_user,$default_sql_password,$default_sql_url,$default_table,$db_cols);

require_once(dirname(__FILE__)."/admin/async_login_handler.php");

$start_script_timer = microtime_float();

if(!function_exists('elapsed'))
  {
    function elapsed($start_time = null)
    {
      /***
       * Return the duration since the start time in
       * milliseconds.
       * If no start time is provided, it'll try to use the global
       * variable $start_script_timer
       *
       * @param float $start_time in unix epoch. See http://us1.php.net/microtime
       ***/

      if(!is_numeric($start_time))
        {
          global $start_script_timer;
          if(is_numeric($start_script_timer)) $start_time = $start_script_timer;
          else return false;
        }
      return 1000*(microtime_float() - (float)$start_time);
    }
  }


$admin_req=isset($_REQUEST['perform']) ? strtolower($_REQUEST['perform']):null;
$login_status = getLoginState($get);


if($as_include !== true) {


    if($login_status["status"] !== true) {
        $login_status["error"] = "Invalid user";
        $login_status["human_error"] = "You're not logged in as a valid user to edit this. Please log in and try again.";
        returnAjax($login_status);
    }

    switch($admin_req)
    {
        # Stuff
    case "save":
        returnAjax(saveEntry($_REQUEST));
        break;
    case "new":
        returnAjax(newEntry($_REQUEST));
        break;
    case "delete":
        returnAjax(deleteEntry($_REQUEST));
        break;
    default:
        returnAjax(getLoginState($_REQUEST,true));
    }

}

function inviteUser($get) {
    # Is the invite target valid?
    $destination = deEscape($get["invitee"]);
    if (!preg_match('/^(?:[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/im', $destination)) {
        return array(
            "status" => false,
            "action" => "INVITE_USER",
            "error" => "INVALID_EMAIL",
            "target" => $destination,
        );
    }
    # Go through the process
    $u = new UserFunctions($login_status["detail"]["dblink"], 'dblink');
    # Does the invite target exist as a user?
    $userExists = $u->isEntry($destination, $u->userColumn);
    if($userExists !== false) {
        return array(
            "status" => false,
            "error" => "ALREADY_REGISTERED",
            "target" => $destination,
            "action" => "INVITE_USER",
        );
    }
    require_once dirname(__FILE__).'/admin/PHPMailer/PHPMailerAutoload.php';
    require_once dirname(__FILE__).'/admin/CONFIG.php';
    global $is_smtp,$mail_host,$mail_user,$mail_password,$is_pop3;
    $mail = new PHPMailer();
    if ($is_smtp) {
        $mail->isSMTP();
        $mail->SMTPAuth = true;
        $mail->Host = $mail_host;
        $mail->Username = $mail_user;
        $mail->Password = $mail_password;
        $mail->SMTPSecure = 'tls';
        $mail->Port = 587;
    }
    if ($is_pop3) {
        $mail->isPOP3();
    } # Need to expand this
    $mail->From = $u->getUsername();
    $mail->FromName = $u->getShortUrl().' on behalf of '.$u->getName();
    $mail->isHTML(true);
    $mail->addAddress($destination);
    $mail->Subject = "[".$u->getShortUrl()."] Invitation to Collaborate";
    $body = "<h1>You've been invited to join a research project!</h1><p>You've been invited to join ".$u->getShortUrl()." by ".$u->getName()." (".$u->getUsername().").</p><p>Visit <a href='".$u->getQualifiedDomain()."/admin-login.php?q=create'>".$u->getQualifiedDomain()."/admin-login.php?q=create</a> to create a new user and get going!</p>";
    $mail->Body = $body;
    $success = $mail->send();
    if($success) {
        return array(
            "status" => $success,
            "action" => "INVITE_USER",
            "invited" => $destination,
        );
    } else {
        return array(
            "status" => $success,
            "action" => "INVITE_USER",
            "invited" => $destination,
            "error" => "MAIL_SEND_FAIL",
            "error_detail" => $mail->ErrorInfo,
        );
    }
}

function saveEntry($get, $dataIsDecoded = false) {
  /***
   * Save edits to a taxon entry
   *
   * Requires the "id" attribute to be set
   ***/
  if($dataIsDecoded !== true) {
  $data64 = $get["data"];
  $enc = strtr($data64, '-_', '+/');
  $enc = chunk_split(preg_replace('!\015\012|\015|\012!','',$enc));
  $enc = str_replace(' ','+',$enc);
  $data_string = base64_decode($enc);
  $data = json_decode($data_string,true);
        } else {
$data = $get["data"];
}
  if(!isset($data["id"]))
    {
      # The required attribute is missing
        $details = array (
                          "original_data" => $data64,
                          "decoded_data" => $data_string,
                          "data_array" => $data
                          );
      return array("status"=>false,"error"=>"POST data attribute \"id\" is missing","human_error"=>"The request to the server was malformed. Please try again.","details"=>$details);
    }
  # Add the perform key
  global $db;
  $ref = array();
  $ref["id"] = $data["id"];
  unset($data["id"]);
  try
    {
      $result = $db->updateEntry($data,$ref);
      # Now, we want to do image processing if an image was alerted
      $imgDetails = false;
      if(!empty($data["image"])) {
          $img = $data["image"];
          $imgDetails = array("has_provided_img"=>true);
          # Process away!
          $file = dirname(__FILE__)."/".$img;
          $imgDetails["file_path"] = $file;
          $imgDetails["relative_path"] = $img;
          if(file_exists($file))
          {
              $imgDetails["img_present"] = true;
              # Resize away
              try
              {
                  $i = new ImageFunctions($file);
                  $thumbArr = explode(".",$img);
                  $extension = array_pop($thumbArr);
                  $outputFile = dirname(__FILE__)."/".implode(".",$thumbArr)."-thumb.".$extension;
                  $imgDetails["resize_status"] = $i->resizeImage($outputFile,256,256); 
              }
              catch(Exception $e)
              {
                  $imgDetails["resize_status"] = false;
                  $imgDetails["resize_error"] = $e->getMessage();
              }

          }
          else
          {
              $imgDetails["img_present"] = false;
          }
      }
    }
  catch(Exception $e)
    {
      return array("status"=>false,"error"=>$e->getMessage(),"humman_error"=>"Database error saving","data"=>$data,"ref"=>$ref,"perform"=>"save");
    }
  if($result !== true)
    {
      return array("status"=>false,"error"=>$result,"human_error"=>"Database error saving","data"=>$data,"ref"=>$ref,"perform"=>"save");
    }
  return array("status"=>true,"perform"=>"save","data"=>$data, "img_details"=>$imgDetails);
}

function newEntry($get)
{
  /***
   * Create a new taxon entry
   *
   *
   * @param data a base 64-encoded JSON string of the data to insert
   ***/
  $data64 = $get["data"];
  $enc = strtr($data64, '-_', '+/');
  $enc = chunk_split(preg_replace('!\015\012|\015|\012!','',$enc));
  $enc = str_replace(' ','+',$enc);
  $data_string = base64_decode($enc);
  $data = json_decode($data_string,true);
  # Add the perform key
  global $db;
  try
  {
    $result = $db->addItem($data);
  }
  catch(Exception $e)
  {
    return array("status"=>false,"error"=>$e->getMessage(),"humman_error"=>"Database error saving","data"=>$data,"ref"=>$result,"perform"=>"new");
  }
  if($result !== true)
  {
    return array("status"=>false,"error"=>$result,"human_error"=>"Database error saving","data"=>$data,"ref"=>$result,"perform"=>"new");
  }
  return array("status"=>true,"perform"=>"new","data"=>$data);
}

function deleteEntry($get)
{
  /***
   * Delete a taxon entry
   * Delete an entry described by the ID parameter
   *
   * @param $get["id"] The DB id to delete
   ***/
  global $db;
  $id = $get["id"];
  $result = $db->deleteRow($id,"id");
  if ($result["status"] === false)
  {
    $result["human_error"] = "Failed to delete item '$id' from the database";
  }
  return $result;
}

?>