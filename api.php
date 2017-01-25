<?php

/***********************************************************
 * SSAR Common names database API target
 *
 * Find the full API description here:
 *
 * https://github.com/tigerhawkvok/SSAR-species-database/blob/master/README.md
 *
 * @param boolean fuzzy
 * @param boolean loose
 * @param int limit
 * @param string order (comma-seperated values)
 * @param string only (comma-seperated values)
 * @param string include (comma-seperated values)
 * @param string type
 * @param JSON filter
 *
 * Initial version by Philip Kahn
 * Started July 2014
 * https://github.com/SSARHERPS/SSAR-species-database
 **********************************************************/

/*****************
 * Setup
 *****************/

#$show_debug = true;

require_once("CONFIG.php");
require_once(dirname(__FILE__)."/core/core.php");
# This is a public API
header("Access-Control-Allow-Origin: *");

$db = new DBHelper($default_database,$default_sql_user,$default_sql_password,$default_sql_url,$default_table,$db_cols);

if(isset($_SERVER['QUERY_STRING'])) parse_str($_SERVER['QUERY_STRING'],$_REQUEST);

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

function returnAjax($data)
{
  /***
   * Return the data as a JSON object
   *
   * @param array $data
   *
   ***/
  if(!is_array($data)) $data=array($data);
  $data["execution_time"] = elapsed();
  header('Cache-Control: no-cache, must-revalidate');
  header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
  header('Content-type: application/json');
  $json = json_encode($data,JSON_FORCE_OBJECT);
  $replace_array = array("&quot;","&#34;");
  print str_replace($replace_array,"\\\"",$json);
  exit();
}

function checkColumnExists($column_list)
{
  /***
   * Check if a comma-seperated list of columns exists in the
   * database.
   * @param string $column_list (comma-sep)
   * @return array
   ***/
  if(empty($column_list)) return true;
  global $db;
  $cols = $db->getCols();
  foreach(explode(",",$column_list) as $column)
    {
      if(!array_key_exists($column,$cols))
        {
          returnAjax(array("status"=>false,"error"=>"Invalid column. If it exists, it may be an illegal lookup column.","human_error"=>"Sorry, you specified a lookup criterion that doesn't exist. Please try again.","columns"=>$column_list,"bad_column"=>$column));
        }
    }
  return true;
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

$order_by = isset($_REQUEST['order']) ? $_REQUEST['order']:"genus,species,subspecies";

$params = array();
$boolean_type = false; # This is always set by the filter
$filter_params = null;
$extra_deprecated_params = null;
if(isset($_REQUEST['filter']))
  {
    $params = smart_decode64($_REQUEST['filter']);
    if(empty($params))
      {
        # Not base 64 encoded
        $params_temp = json_decode($_REQUEST['filter'],true);
        if(!empty($params_temp))
          {
            $params = array();
            foreach($params_temp as $col=>$lookup)
              {
                  # Smart_decode takes care of this for us
                $params[$db->sanitize(deEscape($col))] = $db->sanitize(deEscape($lookup));
              }
          }
      }
    if(!empty($params))
      {
        # De-escape the columns, since they'll be checked for
        # existence anyway
        $params_temp = $params;
        $params = array();
        foreach($params_temp as $col=>$lookup)
          {
            $params[deEscape($col)] = $lookup;
          }
        $filter_params = $params;
        # Does the "BOOLEAN_TYPE" key exist?
        if(isset($params["boolean_type"]))
          {
            $params["BOOLEAN_TYPE"] = $params["boolean_type"];
            unset($params["boolean_type"]);
          }
        if(!array_key_exists("BOOLEAN_TYPE",$params)) returnAjax(array("status"=>false,"error"=>"Missing required parameter","human_error"=>"The key 'BOOLEAN_TYPE' must exist and be either 'AND' or 'OR' when the \"filter\" parameter is specified.","given"=>$params));
        # Is it valid?
        if(strtoupper($params['BOOLEAN_TYPE']) != "AND" && strtoupper($params['BOOLEAN_TYPE']) != "OR") returnAjax(array("status"=>false,"error"=>"Missing required parameter","human_error"=>"The key 'BOOLEAN_TYPE' must be either 'AND' or 'OR'.","given"=>$params));
        $boolean_type = strtoupper($params['BOOLEAN_TYPE']);
        unset($params['BOOLEAN_TYPE']);
        if($boolean_type == "OR")
        {
            # If the params include an authority, check the deprecated
            if(isset($params["genus_authority"]) || isset($param["species_authority"]))
            {
                if(!isset($params["deprecated_scientific"]))
                {
                    $params["deprecated_scientific"] = isset($params["genus_authority"]) ? $params["genus_authority"]:$params["species_authority"];
                }
            }
        }
        else
        {
            # AND search. If the params include an authority, check the deprecated
            if(isset($params["genus_authority"]) || isset($param["species_authority"]))
            {
                $deprecated_params = isset($params["genus_authority"]) ? $params["genus_authority"]:$params["species_authority"];
                $extra_deprecated_params = "LOWER(`deprecated_scientific`) LIKE '%".$deprecated_params."%'";
            }
        }
        # Do all the columns exist?
        foreach($params as $col=>$lookup)
          {
            checkColumnExists($col);
          }
      }
  }


$search = strtolower($db->sanitize(deEscape(urldecode($_REQUEST['q']))));



/*****************************
 * The actual handlers
 *****************************/

function areSimilar($string1,$string2,$distance=70,$depth=3)
{
  /*
   * Returns a TRUE if $string2 is similar to $string1,
   * FALSE otherwise.
   */
  # Is it a substring?
  $i=1;
  if(metaphone($string1) == metaphone($string2) && $i<=$depth ) return true;
  $i++;
  if(soundex($string1) == soundex($string2) && $i<=$depth) return true;
  $i++;
  $similar_difference = similar_text($string1,$string2,$percent);
  if($percent >= $distance && $i <=$depth) return true;
  $i++;
  $max_distance = strlen($string1)*($distance/100);
  if(levenshtein($string1,$string2) < $max_distance && $i<=$depth) return true;
  $i++;
  return false;
}

function handleParamSearch($filter_params,$loose = false,$boolean_type = "AND", $extra_params = false)
{
  /***
   * Handle the searches when they're using advanced options
   *
   * @param extra_params a literal query
   * @return array the result vector
   ***/
   if(!is_array($filter_params) || sizeof($filter_params) === 0)
     {
       global $method;
       returnAjax(array("status"=>false,"error"=>"Invalid filter","human_error"=>"You cannot perform a parameter/filter search without setting the primary filters.","method"=>$method,"given"=>$filter_params));
     }
  global $db;
  $query = "SELECT * FROM `".$db->getTable()."` WHERE ";
  $where_arr = array();
  foreach($filter_params as $col=>$crit)
    {
      $where_arr[] = $loose ? "LOWER(`".$col."`) LIKE '%".$crit."%'":"`".$col."`='".$crit."'";
    }
  $where = "".implode(" ".strtoupper($boolean_type)." ",$where_arr)."";
  if(!empty($extra_params))
    {
        global $extra_deprecated_params;
        if(!empty($extra_deprecated_params))
        {
            $where =  "(".$where." OR " . $extra_deprecated_params .")";
        }
      $where .= " AND (".$extra_params.")";
      # $where .= " " . strtoupper($boolean_type) . " (".$extra_params.")";
    }
  else if(!empty($extra_deprecated_params))
  {
      $where .= " OR (".$extra_deprecated_params.")";
  }
  $where = "(".$where.")";
  $query .= $where;
  global $order_by;
  $ordering = explode(",",$order_by);
  $order = " ORDER BY "."`".implode("`,`",$ordering)."`";
  $query .= $order;
  # echo $query;
  $l = $db->openDB();
  $r = mysqli_query($l,$query);
  if($r === false)
    {
      global $method;
      returnAjax(array("status"=>false,"error"=>mysqli_error($l),"human_error"=>"There was an error executing this query","query"=>$query,"method"=>$method,"given"=>$filter_params));
    }
  $result_vector = array();
  while($row = mysqli_fetch_assoc($r))
    {
      $result_vector[] = $row;
    }
  # $result_vector["query"] = $query;
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
    if(!empty($overrideSearch))
    {
        $search = $overrideSearch;

    }
    $result_vector = array();
    if(empty($params) || !empty($search))
    {
        # There was either a parsing failure, or no filter set.
        if(empty($search))
        {
            # For the full list, just return scientific data
            $search_list = $order_by;
            $col = "species";
            $params[$col] = $search;
            $loose = true;
            $method = "full_simple_list";
            $l = $db->openDB();
            $query = "SELECT ".$search_list." FROM `".$db->getTable()."` WHERE (`$col`!='' AND `$col` IS NOT NULL) ORDER BY ".$order_by;
            $r = mysqli_query($l,$query);
            try
            {
                while($row = mysqli_fetch_assoc($r))
                {
                    $result_vector[] = $row;
                }
            }
            catch(Exception $e)
            {
                if(is_string($r)) $error = $r;
                else $error = $e;
            }
        }
        else if ($search == "*") {
            # Do a full list search, no qualifications
            $method = "full_detail_list";
            $l = $db->openDB();
            $query = "SELECT * FROM `".$db->getTable()."` ORDER BY ".$order_by;
            $r = mysqli_query($l,$query);
            try
            {
                while($row = mysqli_fetch_assoc($r))
                {
                    $result_vector[] = $row;
                }
            }
            catch(Exception $e)
            {
                if(is_string($r)) $error = $r;
                else $error = $e;
            }
        }
        else if(is_numeric($search))
        {
            $method="year_search";
            $col = "authority_year";
            $loose = true; # Always true because of the way data is stored
            $params[$col] = $search;
            $r = $db->doQuery($params,"*","or",$loose,true,$order_by);
            try
            {
                while($row = mysqli_fetch_assoc($r))
                {
                    $result_vector[] = $row;
                }
            }
            catch(Exception $e)
            {
                if(is_string($r)) $error = $r;
                else $error = $e;
            }
        }
        else if (strpos($search," ") === false)
        {
            $method="spaceless_search";
            # No space in search
            if($boolean_type !== false)
            {
                # Handle the complicated statement. It'll need to be
                # escaped from normal handling.
                $method = "spaceless_search_param";
                $extra_params = array();
                $extra_boolean_type = " OR ";
                if(!isset($_REQUEST['only']))
                {
                    $extra_params["common_name"] = $search;
                    $extra_params["genus"] = $search;
                    $extra_params["species"] = $search;
                    $extra_params["subspecies"] = $search;
                    $extra_params["major_common_type"] = $search;
                    $extra_params["major_subtype"] = $search;
                    $extra_params["deprecated_scientific"] = $search;
                }
                else
                {
                    foreach(explode(",",$_REQUEST['only']) as $column)
                    {
                        $extra_params[$db->sanitize($column)] = $search;
                    }
                }
                if(isset($_REQUEST['include']))
                {
                    foreach(explode(",",$_REQUEST['include']) as $column)
                    {
                        $extra_params[$db->sanitize($column)] = $search;
                    }
                }
                foreach($extra_params as $col => $search)
                {
                    $extra_params[$col] = $loose ? "LOWER(`".$col."`) LIKE '%".$search."%'":"`".$col."`='".$search."'";
                }
                $extra_filter = implode($extra_boolean_type,$extra_params);
                $result_vector = handleParamSearch($params,$loose,$boolean_type,$extra_filter);
            }
            else
            {
                $method = "spaceless_search_direct";
                $boolean_type = "OR";
                if(!isset($_REQUEST['only']))
                {
                    $params["common_name"] = $search;
                    $params["genus"] = $search;
                    $params["species"] = $search;
                    $params["subspecies"] = $search;
                    $params["major_common_type"] = $search;
                    $params["major_subtype"] = $search;
                    $params["deprecated_scientific"] = $search;
                }
                else
                {
                    foreach(explode(",",$_REQUEST['only']) as $column)
                    {
                        $params[$db->sanitize($column)] = $search;
                    }
                }
                if(isset($_REQUEST['include']))
                {
                    foreach(explode(",",$_REQUEST['include']) as $column)
                    {
                        $params[$db->sanitize($column)] = $search;
                    }
                }
                if(!$flag_fuzzy)
                {
                    $r = $db->doQuery($params,"*",$boolean_type,$loose,true,$order_by);
                    try {
                        while($row = mysqli_fetch_assoc($r))
                        {
                            $result_vector[] = $row;
                        }
                    }
                    catch(Exception $e)
                    {
                        if(is_string($r)) $error = $r;
                        else $error = $e;
                    }
                    if($show_debug === true) $result_vector["debug"] = $db->doQuery($params,"*",$boolean_type,$loose,true,$order_by,true);
                }
                else
                {
                    foreach($params as $search_column=>$search_criteria)
                    {
                        $r = $db->doSoundex(array($search_column=>$search_criteria),"*",true,$order_by);
                        try
                        {
                            while($row = mysqli_fetch_assoc($r))
                            {
                                $result_vector[] = $row;
                            }
                        }
                        catch(Exception $e)
                        {
                            if(is_string($r)) $error = $r;
                            else $error = $e;
                        }
                    }
                }
            }
        }
        else
        {
            # Spaces in search
            ###############################
            ## Not convinced this makes sense here .... maybe only with
            ## common names?
            if(isset($_REQUEST['only']))
            {
                foreach(explode(",",$_REQUEST['only']) as $column)
                {
                    $params[$db->sanitize($column)] = $search;
                }
            }
            if(isset($_REQUEST['include']))
            {
                foreach(explode(",",$_REQUEST['include']) as $column)
                {
                    $params[$db->sanitize($column)] = $search;
                }
            }
            ###################################
            if($boolean_type !== false)
            {
                # Handle the complicated statement. It'll need to be
                # escaped from normal handling.
                $extra_params = array();
                $exp = explode(" ",$search);
                $fallback = true;
                $method = "scientific";
                if(sizeof($exp) == 2 || sizeof($exp) == 3)
                {
                    $extra_boolean_type = " AND ";
                    $extra_params["genus"] = $exp[0];
                    $extra_params["species"] = $exp[1];
                    if(sizeof($exp) == 3) $extra_params["subspecies"] = $exp[2];
                    $where_arr = array();
                    foreach($extra_params as $col=>$crit)
                    {
                        $where_arr[] = $loose ? "LOWER(`".$col."`) LIKE '%".$crit."%'":"`".$col."`='".$crit."'";
                    }
                    $extra_filter = implode($extra_boolean_type,$where_arr);
                }
                $result_vector = handleParamSearch($params,$loose,$boolean_type,$extra_filter);
                if(sizeof($result_vector) == 0)
                {
                    $result_vector = handleParamSearch($params,$loose,$boolean_type,"LOWER(`deprecated_scientific`) LIKE '%".$search."%'");
                    $method = "deprecated_scientific";
                    if(sizeof($result_vector) == 0)
                    {
                        $col = "common_name";
                        $method = "no_scientific_common";
                        $extra_filter = $loose ? "LOWER(`".$col."`) LIKE '%".$search."%'":"`".$col."`='".$search."'";
                        $result_vector = handleParamSearch($params,$loose,$boolean_type,$extra_filter);
                    }
                }
            }
            else
            {
                $exp = explode(" ",$search);
                $fallback = true;
                if(sizeof($exp) == 2 || sizeof($exp) == 3)
                {
                    $boolean_type = "and";
                    $params["genus"] = $exp[0];
                    $params["species"] = $exp[1];
                    if(sizeof($exp) == 3) $params["subspecies"] = $exp[2];
                    $r = $db->doQuery($params,"*",$boolean_type,$loose,true,$order_by);
                    try
                    {
                        $method = "scientific_raw";
                        $fallback = false;
                        if(mysqli_num_rows($r) > 0)
                        {
                            while($row = mysqli_fetch_assoc($r))
                            {
                                $result_vector[] = $row;
                            }
                            if ($loose) {
                                # For a loose query, append deprecated results
                                try {
                                    $r2 = $db->doQuery(array("deprecated_scientific"=>$search),"*",$boolean_type,true,true,$order_by);
                                    while($row = mysqli_fetch_assoc($r2))
                                    {
                                        $result_vector[] = $row;
                                    }
                                }
                                catch(Exception $e)
                                {
                                    # Do nothing - we already have the main result
                                }
                            }
                        }
                        else
                        {
                            # Always has to be a loose query
                            $method = "deprecated_scientific_raw";
                            $fallback = false;
                            $r = $db->doQuery(array("deprecated_scientific"=>$search),"*",$boolean_type,true,true,$order_by);
                            try
                            {
                                while($row = mysqli_fetch_assoc($r))
                                {
                                    $result_vector[] = $row;
                                }
                                if(sizeof($result_vector) == 0)
                                {
                                    # Fall back one last time to a common
                                    # name search
                                    $fallback = true;
                                    $boolean_type = "or";
                                }
                            }
                            catch(Exception $e)
                            {
                                if(is_string($r)) $error = $r;
                                else $error = $e;
                            }
                        }
                    }
                    catch(Exception $e)
                    {
                        if(is_string($r)) $error = $r;
                        else $error = $e;
                    }
                }
                if($fallback)
                {
                    if(!$flag_fuzzy)
                    {
                        /*
                         * If we're doing a fuzzy search, we'll just fall
                         * straight back to the grabby/loose fallback and
                         * skip this block.
                         */
                        $method = "space_common_fallback";
                        $params["common_name"] = $search;
                        if($boolean_type === false)
                        {
                            # If it hasn't been assigned already, use the
                            # loose "or" search
                            $boolean_type = "or";
                        }
                        $r = $db->doQuery($params,"*",$boolean_type,$loose,true,$order_by);
                        #if($show_debug === true) $result_vector["debug"] =
                        $db->doQuery($params,"*",$boolean_type,$loose,true,$order_by,true);
                    }
                    else $r = false;
                    $id_list = array();
                    try
                    {
                        while($row = mysqli_fetch_assoc($r))
                        {
                            $result_vector[] = $row;
                            $id_list[] = intval($row["id"]);
                        }
                        if((sizeof($result_vector) == 0 && $loose) || $flag_fuzzy)
                        {
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
                            $search_cols = array("common_name","major_common_type","major_subtype");
                            $search_words = explode(" ",$search);
                            $where_glue = " or ";
                            $match_glue = " and ";
                            foreach($search_cols as $col)
                            {
                                # Reset params
                                $params = array();
                                $fuzzy_params = array();
                                foreach($search_words as $word)
                                {
                                    if($flag_fuzzy)
                                    {
                                        $fuzzy_params[] = "STRCMP(SUBSTR(SOUNDEX(".$col."),1,LENGTH(SOUNDEX('".$word."'))),SOUNDEX('".$word."'))=0";
                                    }
                                    $params[] = "(`".$col."` LIKE '%".$word."%')";
                                }
                                $where[] = "(".implode($match_glue,$params).")";
                                if($flag_fuzzy)
                                {
                                    /*
                                     * @note this isn't doing much right
                                     * now - substring soundex matches
                                     * just don't behave nicely. It's here
                                     * for edge cases, but I need to write
                                     * something smarter.
                                     */
                                    $where[] = "(".implode($match_glue,$fuzzy_params).")";
                                }
                            }
                            $params = null; # Clear it out for the return
                            $where_statement = implode($where_glue,$where);
                            $l = $db->openDB();
                            $query = "SELECT * FROM `".$db->getTable()."` WHERE ";
                            $query .= $where_statement . " ORDER BY ".$order_by;
                            $r = mysqli_query($l,$query);
                            try
                            {
                                while($row = mysqli_fetch_assoc($r))
                                {
                                    $result_vector[] = $row;
                                }
                            }
                            catch(Exception $e)
                            {
                                if(is_string($r)) $error = $r;
                                else $error = $e;
                            }
                        }
                    }
                    catch(Exception $e)
                    {
                        if(is_string($r)) $error = $r;
                        else $error = $e;
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
                    if ($method == "space_common_fallback")
                    {
                        $params["common_name"] = str_replace(" ", "", $search);
                        $r = $db->doQuery($params,"*",$boolean_type,$loose,true,$order_by);
                        try
                        {
                            while($row = mysqli_fetch_assoc($r))
                            {
                                if ( !in_array( intval($row["id"]), $id_list) ) 
                                {
                                    $result_vector[] = $row;
                                    $id_list[] = intval($row["id"]);   
                                }
                            }
                        }
                        catch(Exception $e)
                        {
                            if(is_string($r)) $error = $r;
                            else $error = $e;
                        }
                                    
                    }
                }
            }
        }
    }
    else
    {
        $result_vector = handleParamSearch($params,$loose,$boolean_type);
    }
    if(isset($error))
    {
        return array("status"=>false,"error"=>$error,"human_error"=>"There was a problem performing this query. Please try again.","method"=>$method);
    }
    else
    {
        foreach($result_vector as $k=>$v) {
            if (is_array($v)) {
                foreach($v as $rk=>$vk) {
                    $v[$rk] = html_entity_decode($vk,ENT_HTML5,"UTF-8");
                }
            }
            else {
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
if ($search == "mohave" || $search == "mojave")
{
    if ($search == "mohave") $search = "mojave";
    else $search = "mohave";
    foreach($params as $key=>$param) {
        $params[$key] = $search;
    }
    $result2 = doSearch($search);
    $result["query"] = $result["query"] . " && " . $result2["query"];
    $result["method"] = $result["method"] . " && " . $result2["method"];
    $final_array = array();
    foreach($result["result"] as $key=>$value)
    {
        if(!in_array($value,$result2["result"]))
        {
            $final_array[] = $value;
        }
    }
    $result["result"] = array_merge($result2["result"],$final_array);
    $result["count"] = sizeof($result["result"]);
    $result["original_alt"] = $result2;

}
returnAjax($result);

?>