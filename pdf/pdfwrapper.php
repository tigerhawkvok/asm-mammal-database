<?php
# $debug = true;


if ($debug) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('PDFwrapper is running in debug mode!');
}

parse_str($_SERVER['QUERY_STRING'], $_GET);
$_REQUEST = array_merge($_REQUEST, $_GET, $_POST);
$htmlBuildable = $_REQUEST["html"];

require_once dirname(__FILE__)."/../core/core.php";

$buildLead = "data:text/html;charset=utf-8,";
if (strpos($htmlBuildable, $buildLead) !== false) {
    $truncateLength = strlen();
    $htmlEncoded = substr($htmlBuildable, $truncatelength);
} else {
    # We already don't have the lead bit
    $htmlEncoded = $htmlBuildable;
}
$html = urldecode($htmlEncoded);

$pdfResponse = array();

$filePath = "pdf-gen/".microtime_float()."-to-gen.html";
$bits = file_put_contents($filePath, $html);
chmod($filePath, 0777);
$pdfResponse["html_bits_written"] = $bits;

# check OS bits

$pathBits = PHP_INT_SIZE == 8 ? "64" : "32";
$pdfResponse["OS_Architecture"] = $pathBits;

try {
    #$execPath = dirname(__FILE__)."/" . $pathBits . "/bin/wkhtmltopdf";
    $execPath = "./" . $pathBits . "/bin/wkhtmltopdf";
    $destFile = "./pdf-gen/asm-species-pdf-".microtime_float().".pdf";
    $pdfResponse["file"] = $destFile;
    $execCmd = $execPath . " ./" . $filePath . " ".$destFile . " 2>&1";
    # Exec shell
    # https://secure.php.net/manual/en/function.shell-exec.php
    # http://wkhtmltopdf.org/
    $shellResponse = array();
    $shellReturn = "";
    exec($execCmd, $shellResponse, $shellReturn);
    #$shellResponse = system($execCmd);
    #$shellResponse = passthru($execCmd);
    #$shellResponse = shell_exec($execCmd);
    $pdfResponse["response"] = $shellResponse;
    $pdfResponse["return"] = $shellReturn;
    if (empty($shellResponse)) {
        $pdfResponse["status"] = false;
        $pdfResponse["error"] = "NO_SHELL_RESPONSE";
        $pdfResponse["cmd"] = $execCmd;
    } else {
        if (strpos($shellResponse, "Permission denied") !== false) {
            $pdfResponse["status"] = false;
            $pdfResponse["error"] = "PERMISSION_DENIED";
            $pdfResponse["cmd"] = $execCmd;
        } else {
            $pdfResponse["status"] = true;
        }
    }
    # Check the files in pdf-gen, remove all over 24hrs old
} catch (Exception $e) {
    $pdfResponse["status"] = false;
    $pdfResponse["error"] = $e->getMessage();
}

# Return API endpoint for file download
$start_script_timer = microtime_float();

if (!function_exists('elapsed')) {
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

        if (!is_numeric($start_time)) {
            global $start_script_timer;
            if (is_numeric($start_script_timer)) {
                $start_time = $start_script_timer;
            } else {
                return false;
            }
        }

        return 1000 * (microtime_float() - (float) $start_time);
    }
}


function returnAjax($data)
{
    if (!is_array($data)) {
        $data = array($data);
    }
    $data['execution_time'] = elapsed();
    $data['completed'] = microtime_float();
    global $do;
    $data['requested_action'] = $do;
    $data['args_provided'] = $_REQUEST;
    if (!isset($data['status'])) {
        $data['status'] = false;
        $data['error'] = 'Server returned null or otherwise no status.';
        $data['human_error'] = "Server didn't respond correctly. Please try again.";
        $data['app_error_code'] = -10;
    }
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
    header('Content-type: application/json');
    global $billingTokens;
    if (is_array($billingTokens)) {
        $data['billing_meta'] = $billingTokens;
    }
    // try {
    //     foreach($data as $col=>$val) {
    //         $data[$col] = deEscape($val);
    //     }
    // } catch (Exception $e) {
    // }
    $json = json_encode($data, JSON_FORCE_OBJECT);
    $replace_array = array("&quot;","&#34;");
    $deescaped = htmlspecialchars_decode(html_entity_decode($json));
    $dequoted = str_replace($replace_array, "\\\"", $deescaped);
    $dequoted_bare = str_replace($replace_array, "\\\"", $json);
    $de2 = htmlspecialchars_decode(html_entity_decode($dequoted_bare));
    #print $deescaped;
    # print $dequoted_bare;
    print $de2;
    exit();
}


returnAjax($pdfResponse);
