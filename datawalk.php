<?php

/***
 * Walk all the data, and reparse it into the database
 *
 * See:
 * https://github.com/tigerhawkvok/asm-mammal-database/issues/55
 ***/

#$show_debug = true;

if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('API is running in debug mode!');
    $debug = true; # compat
} else {
    # Rigorously avoid errors in production
    ini_set('display_errors', 0);
    $debug = false;
}

require dirname(__FILE__)."/CONFIG.php";
require_once(dirname(__FILE__)."/core/core.php");

if (isset($_SERVER['QUERY_STRING'])) {
    parse_str($_SERVER['QUERY_STRING'], $_REQUEST);
}

$start_script_timer = microtime_float();
$_REQUEST = array_merge($_REQUEST, $_GET, $_POST);
$db = new DBHelper($default_database, $default_sql_user, $default_sql_password, $default_sql_url, $default_table, $db_cols);

try {
    # walk distinct genera
    $query = "SELECT DISTINCT genus FROM `".$db->getTable()."` WHERE (`genus_authority` IS NULL OR `authority_year` IS NULL OR `genus_authority`='' OR `authority_year`='')";
    if (isset($_REQUEST["genus"])) {
        $query .= " AND `genus`='".$db->sanitize($_REQUEST["genus"])."'";
    }
    $r = mysqli_query($db->getLink(), $query);
    $generaCount = mysqli_num_rows($r);
    $generaWalked = 0;
    $writeData = array();
    $statementsSuccessful = 0;
    while ($row = mysqli_fetch_row($r)) {
        # Find oldest citation among unformatted (all) and formatted
        # genera
        $query = "SELECT `id`, `authority_year`, `species_authority`, `parens_auth_species` FROM `".$db->getTable()."` WHERE (`genus_authority` IS NULL OR `authority_year` IS NULL OR `genus_authority`='' OR `authority_year`='') AND `species_authority` IS NOT NULL AND `genus`='".$row[0]."'";
        $ur = mysqli_query($db->getLink(), $query);
        $data = array();
        while ($genusRow = mysqli_fetch_assoc($ur)) {
            # Compute the year
            $sYear = null;
            $gYear = null;
            $tYear = null;
            $authority = null;
            $aYear = json_decode($genusRow['authority_year'], true);
            if (is_array($aYear)) {
                if (is_numeric(key($aYear))) {
                    $gYear = key($aYear);
                    $sYear = current($aYear);
                } elseif (is_numeric(current($aYear))) {
                    $gYear = current($aYear);
                    $sYear = $gYear;
                }
                $authority = preg_replace('%(</|<|&lt;|&lt;/).*?(>|&gt;)%im', '', $genusRow["species_authority"]);
                $authority = preg_replace('/^\(? *(([\'"]?) *(?:\b[a-z\xC0-\x{17F}.[\]-]+(?:,| *&| *&amp;| *&amp;amp;| *&([a-z]|#[0-9])+;)? *)+ *\g{2}) *, *([0-9]{4}) *\)?$/uim', '${1}', $authority);
                $authority = htmlspecialchars_decode($authority);
            }
            if (empty($gYear) || empty($sYear)) {
                # Parse out the string
                $authority = preg_replace('%(</|<|&lt;|&lt;/).*?(>|&gt;)%im', '', $genusRow["species_authority"]);
                $authority = preg_replace('/^\(? *(([\'"]?) *(?:\b[a-z\xC0-\x{17F}.[\]-]+(?:,| *&| *&amp;| *&amp;amp;| *&([a-z]|#[0-9])+;)? *)+ *\g{2}) *, *([0-9]{4}) *\)?$/uim', '${1}', $authority);
                $authority = htmlspecialchars_decode($authority);
                $tYear = preg_replace('/^\(? *(([\'"]?) *(?:\b[a-z\xC0-\x{17F}.[\]-]+(?:,| *&| *&amp;| *&amp;amp;| *&([a-z]|#[0-9])+;)? *)+ *\g{2}) *, *([0-9]{4}) *\)?$/uim', '${4}', $genusRow["species_authority"]);
                $sYear = $tYear;
                if (empty($gYear)) {
                    $gYear = $tYear;
                }
            }
            if (empty($authority)) {
                $authority = $genusRow["species_authority"];
            }
            $hasParens = strpos($authority, "(") !== false || strpos($genusRow["species_authority"], "(") !== false || toBool($genus["parens_auth_species"]);
            # We've assured we've generated something from the species_authority,
            # bu we could still have something from the real genus authority. Now,
            # we make sure it has priority.
            if (!empty($genusRow["genus_authority"])) {
                $authority = preg_replace('%(</|<|&lt;|&lt;/).*?(>|&gt;)%im', '', $genusRow["genus_authority"]);
                $authority = preg_replace('/^\(? *(([\'"]?) *(?:\b[a-z\xC0-\x{17F}.[\]-]+(?:,| *&| *&amp;| *&amp;amp;| *&([a-z]|#[0-9])+;)? *)+ *\g{2}) *, *([0-9]{4}) *\)?$/uim', '${1}', $authority);
                $authority = htmlspecialchars_decode($authority);
                if (empty($authority)) {
                    $authority = $genusRow["genus_authority"];
                }
            }
            if (empty($gYear) && empty($sYear)) {
                continue;
            }
            $data[] = array(
                $genusRow['id'] => array(
                    "year" => intval($gYear),
                    "authority" => $authority,
                    "species_year" => intval($sYear),
                    "match_authority" => $genusRow["species_authority"],
                    "has_parens" => toBool($hasParens),
                ),
            );
        }
        # Apply oldest as genus citation for all of them
        $oldest = intval(date("Y")) + 2; # for year change corner cases
        $genusAuthority = "";
        $useParens = false;
        foreach ($data as $taxa) {
            foreach ($taxa as $uniqueAuthority) {
                if ($uniqueAuthority["year"] < $oldest) {
                    $oldest = $uniqueAuthority["year"];
                    $genusAuthority = $uniqueAuthority["authority"];
                    $hasParens = $uniqueAuthority["has_parens"];
                }
            }
        }
        # Format and apply species citation
        foreach ($data as $taxa) {
            foreach ($taxa as $uniqueAuthority) {
                $authYear = json_encode(array($oldest => $uniqueAuthority["species_year"]));
                if (($authYear == "[0]" || $oldest == 0 || $uniqueAuthority["species_year"] == 0) && !isset($_REQUEST["genus"])) {
                    continue;
                }
                $q = "UPDATE ".$db->getTable()." SET `authority_year`='".$db->sanitize($authYear)."', `genus_authority`='".mysqli_real_escape_string($db->getLink(), $genusAuthority)."', `species_authority`='".mysqli_real_escape_string($db->getLink(), $uniqueAuthority["authority"])."', `parens_auth_species`=".strbool($uniqueAuthority["has_parens"]).", `parens_auth_genus`=".strbool($hasParens)." WHERE `genus`='$row[0]' AND `species_authority`='".mysqli_real_escape_string($db->getLink(), $uniqueAuthority["match_authority"])."'";
                $writeData[] = $q;
                if (!isset($_REQUEST["genus"])) {
                    $executed = mysqli_query($db->getLink(), $q);
                } else {
                    $executed = false;
                }
                if ($executed !== false) {
                    $statementsSuccessful++;
                }
            }
        }
        $generaWalked++;
    }
    $response = array(
        "status" => $generaCount == $generaWalked && $statementsSuccessful == sizeof($writeData),
        "statements" => array(
            "generated" => sizeof($writeData),
            "executed" => $statementsSuccessful,
        ),
        "genera" => array(
            "modified" => $generaWalked,
            "needed_updates" => $generaCount,
        ),
        #"sample" => $q,
    );
    if (isset($_REQUEST["genus"])) {
        $response["queries"] = $writeData;
        $response["raw"] = $data;
    }
    returnAjax($response);
} catch (Exception $e) {
    $response = array(
        "status" => false,
        "built" => sizeof($writeData),
        "genera_needed_update" => $generaCount,
        "genera_modified" => $generaWalked,
        "human_error" => "Failed to update all citations",
        "error" => "SERVER_EXCEPTION",
    );
    if ($show_debug === true) {
        $response["error"] = $e->getMessage();
    }
    returnAjax($response);
}
?>