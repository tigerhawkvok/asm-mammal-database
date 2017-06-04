<?php


/***********************************************************
* ASM Species database API target
 *
 * Find the full API description here:
 *
 * https://github.com/tigerhawkvok/asm-mammal-database/blob/master/README.md
 *
 * @param boolean fuzzy
 * @param boolean loose
 * @param int limit
 * @param string order (comma-seperated values)
 * @param string only (comma-seperated values)
 * @param string include (comma-seperated values)
 * @param string type
 * @param JSON filter
 * @param boolean dwc_only
 *
 * @author Philip Kahn / tigerhawkvok@gmail.com
 * @date January 2017
 *
 * Forked from
 * https://github.com/SSARHERPS/SSAR-species-database/blob/v1.2.5/commonnames_api.php
 *
 * @url https://github.com/tigerhawkvok/asm-mammal-database
 **********************************************************/


/*****************
* Setup
 *****************/

#$show_debug = true;

if ($show_debug === true) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    error_log('API is running in debug mode!');
    $debug = true; # compat
} else {
    # Rigorously avoid errors in production
    ini_set('display_errors', 0);
}

require dirname(__FILE__)."/CONFIG.php";
require_once(dirname(__FILE__)."/core/core.php");
# This is a public API
header("Access-Control-Allow-Origin: *");

$db = new DBHelper($default_database, $default_sql_user, $default_sql_password, $default_sql_url, $default_table, $db_cols);

if (isset($_SERVER['QUERY_STRING'])) {
    parse_str($_SERVER['QUERY_STRING'], $_REQUEST);
}

$start_script_timer = microtime_float();
$_REQUEST = array_merge($_REQUEST, $_GET, $_POST);

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
        return 1000*(microtime_float() - (float)$start_time);
    }
}


if (!function_exists("returnAjax")) {
    function returnAjax($data)
    {
        /***
         * Return the data as a JSON object
         *
         * @param array $data
         *
         ***/
        if (!is_array($data)) {
            $data=array($data);
        }
        $data["execution_time"] = elapsed();
        header('Cache-Control: no-cache, must-revalidate');
        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
        header('Content-type: application/json');
        $json = json_encode($data, JSON_FORCE_OBJECT);
        $replace_array = array("&quot;","&#34;");
        print str_replace($replace_array, "\\\"", $json);
        exit();
    }
}



function checkColumnExists($column_list)
{
    /***
     * Check if a comma-seperated list of columns exists in the
     * database.
     * @param string $column_list (comma-sep)
     * @return array
     ***/
    if (empty($column_list)) {
        return true;
    }
    global $db;
    $cols = $db->getCols();
    foreach (explode(",", $column_list) as $column) {
        if (strtolower($column) == "count(*)" || $column == "*") {
            continue;
        }
        if (!array_key_exists($column, $cols)) {
            try {
                returnAjax(array("status"=>false,"error"=>"Invalid column '$column'. If it exists, it may be an illegal lookup column.","human_error"=>"Sorry, you specified a lookup criterion that doesn't exist. Please try again.","columns"=>$column_list,"bad_column"=>$column));
            } catch (Exception $e) {
                returnAjax(array("status"=>false,"error"=>"Invalid column. If it exists, it may be an illegal lookup column.","human_error"=>"Sorry, you specified a lookup criterion that doesn't exist. Please try again.","columns"=>$column_list,"bad_column"=>$column));
            }
        }
    }
    return true;
}



if (boolstr($_REQUEST["missing"]) || boolstr($_REQUEST["fetch_missing"])) {
    $save = isset($_REQUEST["prefetch"]) ? boolstr($_REQUEST["prefetch"]) : false;
    returnAjax(getTaxonIucnData($_REQUEST), $save);
}
if (boolstr($_REQUEST["get_unique"])) {
    returnAjax(getUniqueVals($_REQUEST["col"]));
}
if (boolstr($_REQUEST["random"])) {
    $query = "SELECT `genus`, `species`, `subspecies` from `".$db->getTable()."` ORDER BY RAND() LIMIT 1";
    $result = mysqli_query($db->getLink(), $query);
    $row = mysqli_fetch_assoc($result);
    returnAjax($row);
}


switch (strtolower($_REQUEST["action"])) {
    case "taxonomy":
        returnAjax(getOrderedTaxonomy($_REQUEST));
        die();
        break;
    case "query":
        returnAjax(doLiveQuery($_REQUEST));
        die();
        break;
    default:
        break;
}



function doLiveQuery($get)
{
    /***
     * Handles directly querying the database with an SQL string.
     *
     * @param array $get -> an array containing keys:
     *  - @key sql_query: a base64-encoded string for an SQL statement
     *  - @key (opt) bool dwc: If true, only return DarwinCore values
     ***/
    global $show_debug, $db;
    $sqlQuery = decode64($get['sql_query'], true);
    if (empty($sqlQuery)) {
        $sqlQuery = base64_decode(urldecode($get["sql_query"]));
    }
    $originalQuery = $sqlQuery;
    $dwcOnly = isset($get["dwc"]) ? toBool($get["dwc"]) : false;
    # If it's a "SELECT" style statement, make sure the accessing user
    # has permissions to read this dataset
    $searchSql = strtolower($sqlQuery);
    # We're going to check against well-formed selects
    $queryPattern = '/^SELECT +((?:(?:(`?)[a-zA-Z_\-]+\g{2}|count\(\*\))(?: +as +[a-zA-Z\_]+)?(?:, *)?)+|\*)(?<!,) +FROM +(`?)'.$db->getTable().'\g{3}( +\(?where +((?:(?:\(?(`?)[a-zA-Z_\-]+\g{6} *(?:=|!=| is | is not | like ) *([\'"]?)[^\'"`;]+\g{7})(?:(?: +AND| +OR| *,| *\)(?: +AND| +OR| *,)) +)?)+|false)\)?)?( +GROUP BY +(?:(`?)[a-zA-Z_\-]+\g{9}(?:, *)?)+(?<!,))?( +ORDER BY +(?:(`?)[a-zA-Z_\-]+\g{11}(?:, *)?)+(?<!,))? *; *$/im';
    # Purely for emacs not liking the thing above meaning it has to be
    #commented out in dev
    if (!isset($queryPattern)) {
        return array(
            "error" => "Please uncomment \$queryPattern before using"
        );
    }
    $statements = explode(';', $sqlQuery);
    $effectiveKey = 0;
    $statementsSize = sizeof($statements);
    $statementResponse = array();
    $status = true;
    foreach ($statements as $k => $statement) {
        $queryInfo = array();
        $statement = trim($statement);
        if (empty($statement)) {
            unset($statements[$k]);
            continue;
        } else {
            $statement .= ";";
        }
        $effectiveKey++;
        $safePreflight = false;
        if (preg_match($queryPattern, $statement)) {
            $safePreflight = true;
            $sqlAction = "SELECT";
        } elseif (preg_match('/\A(?i)SELECT +\* +(?:FROM)?[ `]*'.$db->getTable().'[ `]* +(WHERE FALSE)[;]?\Z/m', $statement)) {
            # Looking up the columns is a safe action
            $safePreflight = true;
            $sqlAction = "LOOKUP_COLS";
        } else {
            # Unverified action
            $safePreflight = false;
            $sqlAction = "UNVERIFIED";
        }
        if ($safePreflight === true) {
            try {
                # Split up statements into chunks and prep for a safe
                # query
                global $db, $default_database, $readonly_sql_user, $readonly_sql_password, $default_sql_url, $default_sql_user, $default_sql_password;
                # We're going ito use peices of PDO since this is more
                # or less arbitrarily specifiable by users
                $dsn = "mysql:host=$default_sql_url;dbname=$default_database;charset=utf8";
                $opt = array(
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                );
                $pdo = new PDO($dsn, $readonly_sql_user, $readonly_sql_password, $opt);
                #$pdo = new PDO($dsn, $default_sql_user, $default_sql_password, $opt);
                $select = preg_replace($queryPattern, '$1', $statement);
                $selectCols = explode(",", $select);
                $realSelect = array();
                $dontQuote = array(
                    "count(*)",
                    "*",
                );
                foreach ($selectCols as $colStatement) {
                    $col = preg_replace('/^([`]?)([a-zA-Z_\-]+)\g{1}$/im', '$2', $colStatement);
                    $realCol = getDarwinCore($col, true, true);
                    checkColumnExists($realCol);
                    $realSelect[] = in_array($realCol, $dontQuote) ? $realCol : "`$realCol`";
                }
                $query = "SELECT ".implode(",", $realSelect)." FROM `".$db->getTable()."`";
                $where = preg_replace($queryPattern, '${4}', $statement);
                if (!empty($where)) {
                    # Extract parameters from the where
                    $buildWhere = array();
                    $buildWhereVals = array();
                    $where = trim($where);
                    $whereStatements = preg_replace('/ *where *(.*) *$/im', '$1', $where);
                    $groups = explode(")", $whereStatements);
                    $buildGroup = array();
                    $orConds = array();
                    $andConds = array();
                    foreach ($groups as $k => $group) {
                        # Trim any leading parens or spaces
                        if (empty($group)) {
                            continue;
                        }
                        if (preg_match('/^ *(and|or) +.*$/im', $group)) {
                            $glue = preg_replace('/^ *(and|or) +.*$/im', '$1', $group);
                            $group = preg_replace('/^ *(and|or) +(.*)$/im', '$2', $group);
                            $buildGroup[$k] = " $glue (";
                        } else {
                            $buildGroup[$k] =  "(";
                        }
                        $group = preg_replace('/^\(? *(.*)$/im', '$1', $group);
                        if (preg_match('/(?: |^)and /im', $group)) {
                            # AND statements
                            if (preg_match('/^and /im', $group)) {
                                # The group leads with an and
                                $buildGroup[$k] = " AND (";
                            }
                            $conds = preg_split('/(?: |^)and */im', $group);
                            $andConds = $conds;
                            $ands = array();
                            foreach ($conds as $cond) {
                                if (!empty(trim($cond))) {
                                    $condParts = preg_split('/ *(=|!=| is | is not | like ) */im', $cond, -1, PREG_SPLIT_NO_EMPTY);
                                    $glue = preg_replace('/.*?(=|!=| is | is not | like ).*/im', '$1', $cond);
                                    $col = preg_replace('/^([`]?)([a-zA-Z_\-]+)\g{1}$/im', '$2', $condParts[0]);
                                    $realCol = getDarwinCore($col, true, true);
                                    checkColumnExists($realCol);
                                    $ands[] = "`$realCol`" . $glue . " ? ";
                                    $buildWhereVals[] = preg_replace('/^([\'"]?)([^\'"]+)\g{1}$/im', '$2', $condParts[1]);
                                }
                            }
                            $buildGroup[$k] .= implode(" AND ", $ands);
                        } elseif (preg_match('/(?: |^)or /im', $group)) {
                            # OR statements
                            if (preg_match('/^or /im', $group)) {
                                # The group leads with an or
                                $buildGroup[$k] = " OR (";
                            }
                            $conds = preg_split('/(?: |^)or */im', $group);
                            $orConds = $conds;
                            $ors = array();
                            foreach ($conds as $cond) {
                                if (!empty(trim($cond))) {
                                    $condParts = preg_split('/ *(=|!=| is | is not | like ) */im', $cond, -1, PREG_SPLIT_NO_EMPTY);
                                    $glue = preg_replace('/.*?(=|!=| is | is not | like ).*/im', '$1', $cond);
                                    $col = preg_replace('/^([`]?)([a-zA-Z_\-]+)\g{1}$/im', '$2', $condParts[0]);
                                    $realCol = getDarwinCore($col, true, true);
                                    checkColumnExists($realCol);
                                    $ors[] = "`$realCol`" . $glue . " ? ";
                                    $buildWhereVals[] = preg_replace('/^([\'"]?)([^\'"]+)\g{1}$/im', '$2', $condParts[1]);
                                }
                            }
                            $buildGroup[$k] .= implode(" or ", $ors);
                        } else {
                            if (sizeof($groups) === 1) {
                                $condParts = preg_split('/ *(=|!=| is | is not | like ) */im', $group, -1, PREG_SPLIT_NO_EMPTY);
                                $glue = preg_replace('/.*?(=|!=| is | is not | like ).*/im', '$1', $group);
                                $col = preg_replace('/^([`]?)([a-zA-Z_\-]+)\g{1}$/im', '$2', $condParts[0]);
                                $realCol = getDarwinCore($col, true, true);
                                checkColumnExists($realCol);
                                $buildGroup[$k] = "(`$realCol` $glue ?";
                                $buildWhereVals[] = preg_replace('/^([\'"]?)([^\'"]+)\g{1}$/im', '$2', $condParts[1]);
                            } elseif (!empty($group)) {
                                # What?
                                $buildGroup[$k] = "ILLEGAL_GROUP::>>>$group<<<";
                            }
                        }
                    }
                    $buildWhere = " WHERE ".implode(") ", $buildGroup).")";
                    $query .= $buildWhere;
                    # Generate some values now, in case we need to debug
                    $queryInfo = array(
                            "where" => $buildWhere,
                            "values" => $buildWhereVals,
                            "full_query" => $query,
                            "used_statement" => $statement,
                        );
                    $debugInfo = array(
                            "raw_where" => $where,
                            "cleaned_where" => $whereStatements,
                            "groups" => $groups,
                            "build_group" => $buildGroup,
                            "last_and" => $ands,
                            "select" => $select,
                            "conds" => array(
                                "or" => $orConds,
                                "and" => $andConds,
                            ),
                        );
                    //return array_merge($queryInfo, $debugInfo);
                    $stmt = $pdo->prepare($query);
                    $stmt->execute($buildWhereVals);
                    $data = array();
                    foreach ($stmt as $row) {
                        $tmp = array(
                            "result" => array($row),
                        );
                        $dwc = getDarwinCore($tmp);
                        $dwcRow = $dwc["result"][0];
                        if ($dwcOnly) {
                            $dwcRow = $dwcRow["dwc"];
                        }
                        $data[] = $dwcRow;
                    }
                    # Set a statement
                    $statementResult = array(
                        "result" => $data,
                        "action" => $sqlAction,
                        "query" => $queryInfo,
                    );
                    if ($show_debug === true) {
                        $statementResult["debug"] = $debugInfo;
                    }
                }
            } catch (Exception $e) {
                $exceptionMessage = $e->getMessage();
                if (strpos(strtolower($exceptionMessage), "sql syntax") !== false) {
                    $sqlResponse = false;
                } else {
                    $sqlResponse = null;
                }
                $statementResult = array(
                            "result" => "ERROR",
                            "error" => array(
                                "safety_check" => $safePreflight,
                                "sql_response" => $sqlResponse,
                                "was_server_exception" => true,
                            ),
                            "action" => $sqlAction,
                            "original_results" => $statementResult,
                            "provided" => $originalQuery,
                            "query" => $queryInfo,
                        );
                if ($show_debug === true) {
                    $statementResult["dev_error"] = array(
                        "exception" => $exceptionMessage,
                        "debug" => $debugInfo,
                    );
                }
                # TODO log to error log
                $status = false;
            }
        } else {
            $sqlAction = preg_replace('/^([a-z-A-Z]+).*$/im', '$1', $statement);
            $statementResult = array(
                            "result" => "ERROR",
                            "error" => array(
                                "safety_check" => $safePreflight,
                                "sql_response" => null,
                                "was_server_exception" => false,
                            ),
                            "action" => $sqlAction,
                            "original_results" => $statementResult,
                            "provided" => $originalQuery,
                            "query" => $queryInfo,
                        );
            $status = false;
        }
        $statementResponse[] = $statementResult;
        if ($status !== true) {
            break;
        }
    }
    return array(
        "status" => $status,
        "statements" => $statementResponse,
        "statement_count" => sizeof($statements),
        "provided" => $originalQuery,
    );
}



function getOrderedTaxonomy($get)
{

   /***
    * Just a duplicate of what goes on in
    * summary.php -- except async and order-able.
    *
    * @param array $get -> the args from a GET or POST request;
    *   expects:
    *     - str $sort -> the column to sort by for both order and genus (validates)
    *     - str $genus_sort -> the column to sort genera (validates)
    *     - str $order_sort -> the column to sort Linnean "orders" (validates)
    *     - bool $reverse -> sort by DESC rather than ASC if true
    ***/
    global $db;
    if (isset($get["sort"])) {
        # Set them to the same thing
        $orderOrderBy = $get["sort"];
        $genusOrderBy = $get["sort"];
    } else {
        # Set them independently
        $orderOrderBy = isset($get["order_sort"]) ? $get["order_sort"] : "linnean_order";
        $genusOrderBy = isset($get["genus_sort"]) ? $get["genus_sort"] : "genus";
    }
    $reverse = isset($get["reverse"]) ? toBool($get["reverse"]) : false;
    $response = array(
            "status" => true,
            "taxonomy" => array(
                "order" => null,
                "genus" => null,
            ),
            "provided" => $get,
        );
    if ($orderOrderBy != "count") {
        checkColumnExists($orderOrderBy);
        # Errors out on its own on fail
    }
    if ($genusOrderBy != "count") {
        checkColumnExists($genusOrderBy);
        # Errors out on its own on fail
    }
    if ($reverse) {
        $orderOrderBy .= " DESC";
        $genusOrderBy .= " DESC";
    }
    $linneanOrderBinQuery = "select distinct `linnean_order`, count(*) as count from `".$db->getTable()."` group by `linnean_order` ORDER BY `$orderOrderBy`";
    $r = mysqli_query($db->getLink(), $linneanOrderBinQuery);
    $labels = array();
    $data = array();
    $speciesTotal = 0;
    while ($row = mysqli_fetch_assoc($r)) {
        $labels[] = ucwords($row["linnean_order"]);
        $data[] = $row["count"];
        $speciesTotal += $row["count"];
    }
    $genusBreakdown = array();
    $genusTotal = 0;
    foreach ($labels as $taxon) {
        $genusBinQuery = "select distinct `genus`, count(*) as count from `".$db->getTable()."` where `linnean_order`='$taxon' group by `genus` ORDER BY `$genusOrderBy`";
        $tmpLabels = array();
        $tmpData = array();
        $r = mysqli_query($db->getLink(), $genusBinQuery);
        while ($row = mysqli_fetch_assoc($r)) {
            $tmpLabels[] = ucwords($row["genus"]);
            $tmpData[] = $row["count"];
            $genusTotal++;
        }
        $genusBreakdown[$taxon] = array(
                    "data" => $tmpData,
                    "labels" => $tmpLabels,
                );
    }
    $response["taxonomy"]["order"] = array(
            "labels" => $labels,
            "data" => $data,
            "params" => array(
                #"query" => $linneanOrderBinQuery,
                "order" => $orderOrderBy,
            ),
        );
    $response["taxonomy"]["genus"] = array(
            "data" => $genusBreakdown,
            "params" => array(
                #"query" => null,
                "order" => $genusOrderBy,
            ),
        );
    returnAjax($response);
}




/*****************************
* Setup flags
*****************************/

$flag_fuzzy = boolstr($_REQUEST['fuzzy']);
$loose = boolstr($_REQUEST['loose']);
# Default limit is specified in CONFIG
$limit = is_numeric($_REQUEST['limit']) && $_REQUEST['limit'] >= 1 ? intval($_REQUEST['limit']):$default_limit;

checkColumnExists($_REQUEST['only']);
checkColumnExists($_REQUEST['include']);
checkColumnExists($_REQUEST['order']);

$order_by = isset($_REQUEST['order']) ? $_REQUEST['order']:"genus,species,subspecies,common_name";

$params = array();
$boolean_type = false;
# This is always set by the filter
$filter_params = null;
$extra_deprecated_params = null;
if (isset($_REQUEST['filter'])) {
    $params = smart_decode64($_REQUEST['filter']);
    if (empty($params)) {
        # Not base 64 encoded
                $params_temp = json_decode($_REQUEST['filter'], true);
        if (!empty($params_temp)) {
            $params = array();
            foreach ($params_temp as $col => $lookup) {
                # Smart_decode takes care of this for us
                $params[$db->sanitize(deEscape($col))] = $db->sanitize(deEscape($lookup));
            }
        }
    }
    if (!empty($params)) {
        # De-escape the columns, since they'll be checked for
        # existence anyway
        $params_temp = $params;
        $params = array();
        foreach ($params_temp as $col => $lookup) {
            $params[deEscape($col)] = $lookup;
        }
        $filter_params = $params;
        # Does the "BOOLEAN_TYPE" key exist?
        if (isset($params["boolean_type"])) {
            $params["BOOLEAN_TYPE"] = $params["boolean_type"];
            unset($params["boolean_type"]);
        }
        if (!array_key_exists("BOOLEAN_TYPE", $params)) {
            returnAjax(array(
                "status"=>false,
                "error"=>"Missing required parameter",
                "human_error"=>"The key 'BOOLEAN_TYPE' must exist and be either 'AND' or 'OR' when the \"filter\" parameter is specified.",
                "given"=>$params));
        }
        # Is it valid?
        if (strtoupper($params['BOOLEAN_TYPE']) != "AND" && strtoupper($params['BOOLEAN_TYPE']) != "OR") {
            returnAjax(array("status"=>false,"error"=>"Missing required parameter","human_error"=>"The key 'BOOLEAN_TYPE' must be either 'AND' or 'OR'.","given"=>$params));
        }
        $boolean_type = strtoupper($params['BOOLEAN_TYPE']);
        unset($params['BOOLEAN_TYPE']);
        if ($boolean_type == "OR") {
            # If the params include an authority, check the deprecated
            if (isset($params["genus_authority"]) || isset($param["species_authority"])) {
                if (!isset($params["deprecated_scientific"])) {
                    $params["deprecated_scientific"] = isset($params["genus_authority"]) ? $params["genus_authority"]:$params["species_authority"];
                }
            }
        } else {
            # AND search. If the params include an authority, check the deprecated
            if (isset($params["genus_authority"]) || isset($param["species_authority"])) {
                $deprecated_params = isset($params["genus_authority"]) ? $params["genus_authority"]:$params["species_authority"];
                $extra_deprecated_params = "LOWER(`deprecated_scientific`) LIKE '%".$deprecated_params."%'";
            }
        }
        if (isset($params["major_type"])) {
            # We want to search all the higherClassification
            $extra_deprecated_params = "`major_type`='".$params["major_type"]."' OR `major_subtype`='".$params["major_type"]."' OR `simple_linnean_group`='".$params["major_type"]."'";
        }
        //print_r($params);
        //print_r($extra_deprecated_params);
        # Do all the columns exist?
        foreach ($params as $col => $lookup) {
            checkColumnExists($col);
        }
    }
}


$search = strtolower($db->sanitize(deEscape(urldecode($_REQUEST['q']))));


/*****************************
 * The actual handlers
 *****************************/

function fetchMajorMinorGroups($scientific = false)
{
    global $db;
    $sciMajor = array(
          "eutheria"=>"eutheria",
              "metatheria"=>"metatheria",
              "prototheria"=>"prototheria",
          );
    $commonMajor = array(
          "eutheria"=>"placental mammals",
              "metatheria"=>"marsupials",
              "prototheria"=>"monotremes",
          );
    $majorGroups = toBool($scientific) ?  $sciMajor : $commonMajor;
    $minorCol = toBool($scientific) ? "linnean_order":"simple_linnean_subgroup";
    $query = "SELECT DISTINCT `$minorCol`, `linnean_order` FROM `".$db->getTable()."`";
    $result = mysqli_query($db->getLink(), $query);
    if ($result === false) {
        return array(
          "status" => false,
                   "error" => mysqli_error($db->getLink()),
                   "human_error" => "DATABASE_ERROR",
          );
    }
    $minorGroups = array();
    while ($row = mysqli_fetch_row($result)) {
        $minorGroups[] = $row[0];
    }
    return array(
          "status" => true,
              "major" => $majorGroups,
                    "minor" => $minorGroups,
          );
}


/***
 * Break out early for these special cases
 ***/

if (toBool($_REQUEST["fetch-groups"])) {
    returnAjax(fetchMajorMinorGroups($_REQUEST["scientific"]));
}



function areSimilar($string1, $string2, $distance = 70, $depth = 3)
{
    /*
     * Returns a TRUE if $string2 is similar to $string1,
     * FALSE otherwise.
     */
    # Is it a substring?
    $i = 1;
    if (metaphone($string1) == metaphone($string2) && $i<=$depth) {
        return true;
    }
    $i++;
    if (soundex($string1) == soundex($string2) && $i<=$depth) {
        return true;
    }
    $i++;
    $similar_difference = similar_text($string1, $string2, $percent);
    if ($percent >= $distance && $i <=$depth) {
        return true;
    }
    $i++;
    $max_distance = strlen($string1)*($distance/100);
    if (levenshtein($string1, $string2) < $max_distance && $i<=$depth) {
        return true;
    }
    $i++;
    return false;
}



function handleParamSearch($filter_params, $loose = false, $boolean_type = "AND", $extra_params = false)
{
    /***
     * Handle the searches when they're using advanced options
     *
     * @param extra_params a literal query
     * @return array the result vector
     ***/
    if (!is_array($filter_params) || sizeof($filter_params) === 0) {
        global $method;
        returnAjax(array("status"=>false,"error"=>"Invalid filter","human_error"=>"You cannot perform a parameter/filter search without setting the primary filters.","method"=>$method,"given"=>$filter_params));
    }
    global $db;
    $query = "SELECT * FROM `".$db->getTable()."` WHERE ";
    $where_arr = array();
    foreach ($filter_params as $col => $crit) {
        $where_arr[] = $loose ? "LOWER(`".$col."`) LIKE '%".$crit."%'":"`".$col."`='".$crit."'";
    }
    $where = "".implode(" ".strtoupper($boolean_type)." ", $where_arr)."";
    if (!empty($extra_params)) {
        global $extra_deprecated_params;
        if (!empty($extra_deprecated_params)) {
            $where =  "(".$where." OR " . $extra_deprecated_params .")";
        }
        $where .= " AND (".$extra_params.")";
        # $where .= " " . strtoupper($boolean_type) . " (".$extra_params.")";
    } elseif (!empty($extra_deprecated_params)) {
        $where .= " OR (".$extra_deprecated_params.")";
    }
    $where = "(".$where.")";
    $query .= $where;
    global $order_by;
    $ordering = explode(",", $order_by);
    $order = " ORDER BY "."`".implode("`,`", $ordering)."`";
    $query .= $order;
    #echo $query;
    $l = $db->openDB();
    $r = mysqli_query($l, $query);
    if ($r === false) {
        global $method;
        returnAjax(array("status"=>false,"error"=>mysqli_error($l),"human_error"=>"There was an error executing this query","query"=>$query,"method"=>$method,"given"=>$filter_params));
    }
    $result_vector = array();
    while ($row = mysqli_fetch_assoc($r)) {
        $result_vector[] = $row;
    }
    if ($show_debug === true) {
        $result_vector["query"] = $query;
    }
    return $result_vector;
}


/*********************************************************
 *
 * The actual main search loop
 *
 *********************************************************/

function doSearch($overrideSearch = null)
{
    global $search, $flag_fuzzy, $loose, $limit, $order_by, $params, $boolean_type, $filter_params, $db, $method;
    if (!empty($overrideSearch)) {
        $search = $overrideSearch;
    }
    $result_vector = array();
    if (empty($params) || !empty($search)) {
        # There was either a parsing failure, or no filter set.
        if (empty($search)) {
            # For the full list, just return scientific data
            $search_list = $order_by;
            $col = "species";
            $params[$col] = $search;
            $loose = true;
            $method = "full_simple_list";
            $l = $db->openDB();
            $query = "SELECT ".$search_list." FROM `".$db->getTable()."` WHERE (`$col`!='' AND `$col` IS NOT NULL) ORDER BY ".$order_by;
            $r = mysqli_query($l, $query);
            try {
                while ($row = mysqli_fetch_assoc($r)) {
                    $result_vector[] = $row;
                }
            } catch (Exception $e) {
                if (is_string($r)) {
                    $error = $r;
                } else {
                    $error = $e;
                }
            }
        } elseif ($search == "*") {
            # Do a full list search, no qualifications
            $method = "full_detail_list";
            $l = $db->openDB();
            $query = "SELECT * FROM `".$db->getTable()."` ORDER BY ".$order_by;
            $r = mysqli_query($l, $query);
            try {
                while ($row = mysqli_fetch_assoc($r)) {
                    $result_vector[] = $row;
                }
            } catch (Exception $e) {
                if (is_string($r)) {
                    $error = $r;
                } else {
                    $error = $e;
                }
            }
        } elseif (is_numeric($search)) {
            $method="year_search";
            $col = "authority_year";
            $loose = true;
            # Always true because of the way data is stored
            $params[$col] = $search;
            $r = $db->doQuery($params, "*", "or", $loose, true, $order_by);
            try {
                while ($row = mysqli_fetch_assoc($r)) {
                    $result_vector[] = $row;
                }
            } catch (Exception $e) {
                if (is_string($r)) {
                    $error = $r;
                } else {
                    $error = $e;
                }
            }
        } elseif (strpos($search, " ") === false) {
            $method="spaceless_search";
            # No space in search
            if ($boolean_type !== false) {
                # Handle the complicated statement. It'll need to be
                # escaped from normal handling.
                $method = "spaceless_search_param";
                $extra_params = array();
                $extra_boolean_type = " OR ";
                if (!isset($_REQUEST['only'])) {
                    $extra_params["common_name"] = $search;
                    $extra_params["genus"] = $search;
                    $extra_params["species"] = $search;
                    $extra_params["subspecies"] = $search;
                    $extra_params["major_type"] = $search;
                    $extra_params["linnean_order"] = $search;
                    $extra_params["deprecated_scientific"] = $search;
                } else {
                    foreach (explode(",", $_REQUEST['only']) as $column) {
                        $extra_params[$db->sanitize($column)] = $search;
                    }
                }
                if (isset($_REQUEST['include'])) {
                    foreach (explode(",", $_REQUEST['include']) as $column) {
                        $extra_params[$db->sanitize($column)] = $search;
                    }
                }
                foreach ($extra_params as $col => $search) {
                    $extra_params[$col] = $loose ? "LOWER(`".$col."`) LIKE '%".$search."%'":"`".$col."`='".$search."'";
                }
                $extra_filter = implode($extra_boolean_type, $extra_params);
                $result_vector = handleParamSearch($params, $loose, $boolean_type, $extra_filter);
            } else {
                $method = "spaceless_search_direct";
                $boolean_type = "OR";
                if (!isset($_REQUEST['only'])) {
                    $params["common_name"] = $search;
                    $params["genus"] = $search;
                    $params["species"] = $search;
                    $params["subspecies"] = $search;
                    $params["major_type"] = $search;
                    $params["major_subtype"] = $search;
                    $params["deprecated_scientific"] = $search;
                } else {
                    foreach (explode(",", $_REQUEST['only']) as $column) {
                        $params[$db->sanitize($column)] = $search;
                    }
                }
                if (isset($_REQUEST['include'])) {
                    foreach (explode(",", $_REQUEST['include']) as $column) {
                        $params[$db->sanitize($column)] = $search;
                    }
                }
                if (!$flag_fuzzy) {
                    $r = $db->doQuery($params, "*", $boolean_type, $loose, true, $order_by);
                    try {
                        while ($row = mysqli_fetch_assoc($r)) {
                            $result_vector[] = $row;
                        }
                    } catch (Exception $e) {
                        if (is_string($r)) {
                            $error = $r;
                        } else {
                            $error = $e;
                        }
                    }
                    if ($show_debug === true) {
                        $result_vector["debug"] = $db->doQuery($params, "*", $boolean_type, $loose, true, $order_by, true);
                    }
                } else {
                    foreach ($params as $search_column => $search_criteria) {
                        $r = $db->doSoundex(array($search_column=>$search_criteria), "*", true, $order_by);
                        try {
                            while ($row = mysqli_fetch_assoc($r)) {
                                $result_vector[] = $row;
                            }
                        } catch (Exception $e) {
                            if (is_string($r)) {
                                $error = $r;
                            } else {
                                $error = $e;
                            }
                        }
                    }
                }
            }
        } else {
            # Spaces in search
            ###############################
            ## Not convinced this makes sense here .... maybe only with
            ## common names?
            if (isset($_REQUEST['only'])) {
                foreach (explode(",", $_REQUEST['only']) as $column) {
                    $params[$db->sanitize($column)] = $search;
                }
            }
            if (isset($_REQUEST['include'])) {
                foreach (explode(",", $_REQUEST['include']) as $column) {
                    $params[$db->sanitize($column)] = $search;
                }
            }
            ###################################
            if ($boolean_type !== false) {
                # Handle the complicated statement. It'll need to be
                # escaped from normal handling.
                $extra_params = array();
                $exp = explode(" ", $search);
                $fallback = true;
                $method = "scientific";
                if (sizeof($exp) == 2 || sizeof($exp) == 3) {
                    $extra_boolean_type = " AND ";
                    $extra_params["genus"] = $exp[0];
                    $extra_params["species"] = $exp[1];
                    if (sizeof($exp) == 3) {
                        $extra_params["subspecies"] = $exp[2];
                    }
                    $where_arr = array();
                    foreach ($extra_params as $col => $crit) {
                        $where_arr[] = $loose ? "LOWER(`".$col."`) LIKE '%".$crit."%'":"`".$col."`='".$crit."'";
                    }
                    $extra_filter = implode($extra_boolean_type, $where_arr);
                }
                $result_vector = handleParamSearch($params, $loose, $boolean_type, $extra_filter);
                if (sizeof($result_vector) == 0) {
                    $result_vector = handleParamSearch($params, $loose, $boolean_type, "LOWER(`deprecated_scientific`) LIKE '%".$search."%'");
                    $method = "deprecated_scientific";
                    if (sizeof($result_vector) == 0) {
                        $col = "common_name";
                        $method = "no_scientific_common";
                        $extra_filter = $loose ? "LOWER(`".$col."`) LIKE '%".$search."%'":"`".$col."`='".$search."'";
                        $result_vector = handleParamSearch($params, $loose, $boolean_type, $extra_filter);
                    }
                }
            } else {
                $exp = explode(" ", $search);
                $fallback = true;
                if (sizeof($exp) == 2 || sizeof($exp) == 3) {
                    $boolean_type = "and";
                    $params["genus"] = $exp[0];
                    $params["species"] = $exp[1];
                    if (sizeof($exp) == 3) {
                        $params["subspecies"] = $exp[2];
                    }
                    $r = $db->doQuery($params, "*", $boolean_type, $loose, true, $order_by);
                    try {
                        $method = "scientific_raw";
                        $fallback = false;
                        if (mysqli_num_rows($r) > 0) {
                            while ($row = mysqli_fetch_assoc($r)) {
                                $result_vector[] = $row;
                            }
                            if ($loose) {
                                # For a loose query, append deprecated results
                                try {
                                    $r2 = $db->doQuery(array("deprecated_scientific"=>$search), "*", $boolean_type, true, true, $order_by);
                                    while ($row = mysqli_fetch_assoc($r2)) {
                                        $result_vector[] = $row;
                                    }
                                } catch (Exception $e) {
                                    # Do nothing - we already have the main result
                                }
                            }
                        } else {
                            # Always has to be a loose query
                            $method = "deprecated_scientific_raw";
                            $fallback = false;
                            $r = $db->doQuery(array("deprecated_scientific"=>$search), "*", $boolean_type, true, true, $order_by);
                            try {
                                while ($row = mysqli_fetch_assoc($r)) {
                                    $result_vector[] = $row;
                                }
                                if (sizeof($result_vector) == 0) {
                                    # Fall back one last time to a common
                                    # name search
                                    $fallback = true;
                                    $boolean_type = "or";
                                }
                            } catch (Exception $e) {
                                if (is_string($r)) {
                                    $error = $r;
                                } else {
                                    $error = $e;
                                }
                            }
                        }
                    } catch (Exception $e) {
                        if (is_string($r)) {
                            $error = $r;
                        } else {
                            $error = $e;
                        }
                    }
                }
                if ($fallback) {
                    if (!$flag_fuzzy) {
                        /*
                         * If we're doing a fuzzy search, we'll just fall
                         * straight back to the grabby/loose fallback and
                         * skip this block.
                         */
                        $method = "space_common_fallback";
                        $params["common_name"] = $search;
                        if ($boolean_type === false) {
                            # If it hasn't been assigned already, use the
                            # loose "or" search
                            $boolean_type = "or";
                        }
                        $r = $db->doQuery($params, "*", $boolean_type, $loose, true, $order_by);
                        #if($show_debug === true) $result_vector["debug"] =
                        $db->doQuery($params, "*", $boolean_type, $loose, true, $order_by, true);
                    } else {
                        $r = false;
                    }
                    $id_list = array();
                    try {
                        while ($row = mysqli_fetch_assoc($r)) {
                            $result_vector[] = $row;
                            $id_list[] = intval($row["id"]);
                        }
                        if ((sizeof($result_vector) == 0 && $loose) || $flag_fuzzy) {
                            /*
                             * At this point, we've exhausted all literal
                             * search combinations for specific
                             * animals. Now, we'll split up the spaces and
                             * look for all common names and common types
                             * that have all the individual words in them.
                             *
                             * If we're not loose, we just fail.
                             * We always hit this condition if we're fuzzy.
                             */
                            $method = "space_loose_fallback";
                            $where = array();
                            $search_cols = array("common_name","major_type","linnean_order");
                            $search_words = explode(" ", $search);
                            $where_glue = " or ";
                            $match_glue = " and ";
                            foreach ($search_cols as $col) {
                                # Reset params
                                $params = array();
                                $fuzzy_params = array();
                                foreach ($search_words as $word) {
                                    if ($flag_fuzzy) {
                                        $fuzzy_params[] = "STRCMP(SUBSTR(SOUNDEX(".$col."),1,LENGTH(SOUNDEX('".$word."'))),SOUNDEX('".$word."'))=0";
                                    }
                                    $params[] = "(`".$col."` LIKE '%".$word."%')";
                                }
                                $where[] = "(".implode($match_glue, $params).")";
                                if ($flag_fuzzy) {
                                    /*
                                     * @note this isn't doing much right
                                     * now - substring soundex matches
                                     * just don't behave nicely. It's here
                                     * for edge cases, but I need to write
                                     * something smarter.
                                     */
                                    $where[] = "(".implode($match_glue, $fuzzy_params).")";
                                }
                            }
                            $params = null;
                            # Clear it out for the return
                            $where_statement = implode($where_glue, $where);
                            $l = $db->openDB();
                            $query = "SELECT * FROM `".$db->getTable()."` WHERE ";
                            $query .= $where_statement . " ORDER BY ".$order_by;
                            $r = mysqli_query($l, $query);
                            try {
                                while ($row = mysqli_fetch_assoc($r)) {
                                    $result_vector[] = $row;
                                }
                            } catch (Exception $e) {
                                if (is_string($r)) {
                                    $error = $r;
                                } else {
                                    $error = $e;
                                }
                            }
                        }
                    } catch (Exception $e) {
                        if (is_string($r)) {
                            $error = $r;
                        } else {
                            $error = $e;
                        }
                    }

                    /*
                     * If the method was
                     * space_common_fallback, let's double
                     * check and append the results for no
                     * space.
                     *
                     * After
                     * https://github.com/SSARHERPS/SSAR-species-database/issues/70
                     */
                    if ($method == "space_common_fallback") {
                        $params["common_name"] = str_replace(" ", "", $search);
                        $r = $db->doQuery($params, "*", $boolean_type, $loose, true, $order_by);
                        try {
                            while ($row = mysqli_fetch_assoc($r)) {
                                if (!in_array(intval($row["id"]), $id_list)) {
                                    $result_vector[] = $row;
                                    $id_list[] = intval($row["id"]);
                                }
                            }
                        } catch (Exception $e) {
                            if (is_string($r)) {
                                $error = $r;
                            } else {
                                $error = $e;
                            }
                        }
                    }
                }
            }
        }
    } else {
        $method = "param_queryless";
        global $extra_deprecated_params;
        $useFilter = !empty($extra_deprecated_params) ? true : null;
        $result_vector = handleParamSearch($params, $loose, $boolean_type, $useFilter);
    }
    if (isset($error)) {
        return array("status"=>false,"error"=>$error,"human_error"=>"There was a problem performing this query. Please try again.","method"=>$method);
    } else {
        foreach ($result_vector as $k => $v) {
            if (is_array($v)) {
                foreach ($v as $rk => $vk) {
                    $v[$rk] = html_entity_decode($vk, ENT_HTML5, "UTF-8");
                }
            } else {
                $v = html_entity_decode($v);
            }
            $result_vector[$k] = $v;
        }
        return array(
            "status"=>true,
            "result"=>$result_vector,
            "count"=>sizeof($result_vector),
            "method"=>$method,
            "query"=>$search,
            "params"=>$params,
            "query_params"=>array(
                "bool"=>$boolean_type,
                "loose"=>$loose,
                "fuzzy"=>$flag_fuzzy,
                "order_by"=>$order_by,
                "filter"=>array(
                    "had_filter"=>isset($_REQUEST['filter']),
                    "filter_params"=>$filter_params,
                    "filter_literal"=>$_REQUEST["filter"]
                )
            )
        );
    }
}


$result = doSearch();

/***
 * Check for missing, important, fields.
 *
 * Uses
 * http://apiv3.iucnredlist.org/api/v3/docs
 *
 ***/

$apiTarget = "http://apiv3.iucnredlist.org/api/v3/species/";
$args = "token=" . $iucnToken;
$iucnCanProvide = array(
    "common_name" => "main_common_name",
    "species_authority" => "authority",
);

function getTaxonIucnData($taxonBase, $ignoreFlagSave = false)
{
    if (empty($taxonBase["genus"]) || empty($taxonBase["species"])) {
        return array(
            "status" => false,
            "error" => "REQUIRED_COLS_MISSING",
        );
    }
    global $apiTarget, $args, $iucnCanProvide, $db;
    $params = array(
        "genus" => $taxonBase["genus"],
        "species" => $taxonBase["species"],
    );
    $r = $db->doQuery($params, "*");
    if ($r === false) {
        return array(
            "status" => false,
            "params" => $params,
        );
    }
    $taxon = mysqli_fetch_assoc($r);
    # Check for important empty fields ....
    $doIucn = false;
    foreach ($iucnCanProvide as $field => $iucnField) {
        if (empty($taxon[$field])) {
            $doIucn = true;
            break;
        }
    }
    if ($doIucn === true) {
        # IUCN returns an empty result unless "%20" is used to separate the
        # genus and species
        $nameTarget = $taxon["genus"] . "%20" . $taxon["species"];
        try {
            $iucnRawResponse = do_post_request($apiTarget.$nameTarget, $args);
            $iucnResponse = json_decode($iucnRawResponse["response"], true);
        } catch (Exception $e) {
        }
        $iucnTaxon = $iucnResponse["result"][0];
        $flagSave = false;
        foreach ($iucnCanProvide as $field => $iucnField) {
            if (empty($taxon[$field]) && !empty($iucnTaxon[$iucnField])) {
                $taxon[$field] = $iucnTaxon[$iucnField];
                # Save the field to the database ....
                $flagSave = true;
            }
        }
        if ($flagSave && !$ignoreFlagSave) {
            $ref = array();
            $ref["id"] = $taxon["id"];
            unset($taxon["id"]);
            $saveResult = $db->updateEntry($taxon, $ref);
            $taxon["save_result"] = $saveResult;
        }
        $taxon["did_update"] = $flagSave;
        $taxon["iucn"] = $iucnTaxon;
        unset($taxon["id"]);
    }
    $hasWellFormattedSpeciesCitation = preg_match('/\(? *([\w\. \[\]]+), *([0-9]{
                        4
                    }
                    ) *\)?/im', $taxon["species_authority"]);
    if (empty($taxon["genus_authority"]) && $hasWellFormattedSpeciesCitation) {
        $authority = preg_replace('/\(? *(([\w\. \[\]]+(,|&|&amp;
                    |&amp;
                    amp;
                    )?)+), *([0-9]{
                        4
                    }
                    ) *\)?/im', '$1', $taxon["species_authority"]);
        $authorityYear = preg_replace('/\(? *(([\w\. \[\]]+(,|&|&amp;
                    |&amp;
                    amp;
                    )?)+), *([0-9]{
                        4
                    }
                    ) *\)?/im', '$4', $taxon["species_authority"]);
        $taxon["authority_year"] = json_encode(array(
            $authorityYear => $authorityYear,
        ));
        $parensState = preg_match('/\( *([\w\. \[\]]+), *([0-9]{
                        4
                    }
                    ) *\)/im', $taxon["species_authority"]) ? true:false;
        $taxon["genus_authority"] = $authority;
        $taxon["species_authority"] = $authority;
        $taxon["parens_auth_genus"] = $parensState;
        $taxon["parens_auth_species"] = $parensState;
    }
    # Finalize
    return $taxon;
}


function getUniqueVals($column)
{
    /***
     *
     ***/
    if (checkColumnExists($column) === true) {
        global $db;
        $query = "SELECT DISTINCT ".$column." FROM ".$db->getTable();
        $r = mysqli_query($db->getLink(), $query);
        if ($r === false) {
            return array(
                "status" => false,
                "error" => mysqli_error($db->getLink()),
            );
        }
        $valArray = array();
        while ($row = mysqli_fetch_row($r)) {
            if (!empty($row[0])) {
                $valArray[] = $row[0];
            }
        }
        return array(
            "status" => true,
            "values" => $valArray,
        );
    } else {
        return array(
            "status" => false,
            "error" => "INVALID_COLUMN",
        );
    }
}


if (sizeof($result["result"]) <= 5) {
    foreach ($result["result"] as $i => $taxon) {
        # Check for important empty fields ....
        $doIucn = false;
        foreach ($iucnCanProvide as $field => $iucnField) {
            if (empty($taxon[$field]) && isset($taxon[$field])) {
                $doIucn = true;
                break;
            }
        }
        if ($doIucn === true) {
            # IUCN returns an empty result unless "%20" is used to separate the
            # genus and species
            $nameTarget = $taxon["genus"] . "%20" . $taxon["species"];
            try {
                $iucnRawResponse = do_post_request($apiTarget.$nameTarget, $args);
                $iucnResponse = json_decode($iucnRawResponse["response"], true);
            } catch (Exception $e) {
                continue;
            }
            $iucnTaxon = $iucnResponse["result"][0];
            $flagSave = false;
            foreach ($iucnCanProvide as $field => $iucnField) {
                if (empty($taxon[$field]) && !empty($iucnTaxon[$iucnField])) {
                    $taxon[$field] = $iucnTaxon[$iucnField];
                    # Save the field to the database ....
                    $flagSave = true;
                }
            }
            if ($flagSave) {
                global $db;
                $ref = array();
                $ref["id"] = $taxon["id"];
                unset($taxon["id"]);
                $saveResult = $db->updateEntry($taxon, $ref);
                $taxon["saveResult"] = $saveResult;
            }
            $taxon["iucn"] = $iucnTaxon;
            unset($taxon["id"]);
            $result["result"][$i] = $taxon;
            continue;
        }
    }
    $result["do_client_update"] = false;
} else {
    $result["do_client_update"] = true;
}

function getDarwinCore($result, $mapOnly = false, $reverseMap = false)
{
    # DarwinCore mapping
    # http://rs.tdwg.org/dwc/terms/
    $dwcResultMap = array(
        "subspecies" => "subspecificEpithet",
        "genus" => "genus",
        "species" => "specificEpithet",
        "canonical_sciname" => "scientificName",
        "citation" => "namePublishedIn",
        "common_name" => "vernacularName",
        "linnean_order" => "order",
        "linnean_family" => "family",
    );
    if ($mapOnly === true) {
        if ($reverseMap === true) {
            # Map DarwinCore to internal DB terms
            foreach ($dwcResultMap as $db => $dc) {
                if ($result == $dc) {
                    return $db;
                }
            }
            # Return the original as a fallback
            return $result;
        }
        return $dwcResultMap[$result];
    }
    $higherClassificationMap = array(
        "simple_linnean_group" => "cohort",
        "major_type" => "magnaorder",
        "major_subtype" => "superorder",
    );
    $dwcTotal = array();
    foreach ($result["result"] as $i => $taxon) {
        $dwcResult = array();
        $higherClassification = array();
        foreach ($taxon as $key => $value) {
            if (array_key_exists($key, $dwcResultMap)) {
                $dwcResult[$dwcResultMap[$key]] = $value;
            }
            if (array_key_exists($key, $higherClassificationMap) && !empty($value)) {
                $higherClassification[$higherClassificationMap[$key]] = $value;
            }
        }
        # Lucky us, it's alphabetical
        ksort($higherClassification);
        $list = implode("|", $higherClassification);
        $higherClassification["list"] = $list;
        $dwcResult["higherClassification"] = $higherClassification;
        if (isset($taxon["species_authority"])) {
            $years = json_decode($taxon["authority_year"], true);
            $genusYear = key($years);
            $speciesYear = current($years);
            $genus = empty($genusYear) ? $taxon["genus_authority"] : $taxon["genus_authority"] . ", " . $genusYear;
            $species = empty($speciesYear) ? $taxon["species_authority"] : $taxon["species_authority"] . ", " . $speciesYear;
            $genus = toBool($taxon["parens_auth_genus"]) ? "($genus)" : $genus;
            $species = toBool($taxon["parens_auth_species"]) ? "($species)" : $species;
            $dwcResult["scientificNameAuthorship"] = array(
                "genus" => $genus,
                "species" => $species,
            );
        }
        $dwcResult["taxonRank"] = "species";
        $dwcResult["class"] = "mammalia";
        $dwcResult["taxonomicStatus"] = "accepted";
        if (isset($taxon["canonical_sciname"])) {
            $dwcResult["dcterms:bibliographicCitation"] = $taxon["canonical_sciname"]." (ASM Species Account Database #".$taxon["internal_id"].") fetched ".date(DATE_ISO8601);
        }
        $dwcResult["dcterms:language"] = "en";
        if (isset($taxon["taxon_credit_date"])) {
            $creditTime = strtotime($taxon["taxon_credit_date"]);
            if ($creditTime === false) {
                $creditTime = intval($taxon["taxon_credit_date"]);
            }
            if (!is_numeric($creditTime) || $creditTime == 0) {
                $creditTime = time();
            }
            $dwcResult["dcterms:modified"] = date(DATE_ISO8601, $creditTime);
        }
        $dwcResult["dcterms:license"] = "https://creativecommons.org/licenses/by-nc/4.0/legalcode";
        $result["result"][$i]["dwc"] = $dwcResult;
        $dwcTotal[] = $dwcResult;
    }
    return $result;
}

$result = getDarwinCore($result);

if (toBool($_REQUEST["dwc_only"])) {
    $result["result"] = $dwcTotal;
}

# $as_include isn't specified, so if it is, it's from a parent file
if ($as_include !== true) {
    returnAjax($result);
}
