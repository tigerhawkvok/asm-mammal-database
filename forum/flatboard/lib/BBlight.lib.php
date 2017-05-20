<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
 *
 * BBCode to HTML converter
*/

class BBlight
{
	protected $bbcode_table = array();
    /**
     * Protected constructor since this is a static class.
     *
     * @access  protected
     */
	  public function __construct () {
	    // Replace [code]...[/code] with <pre><code>...</code></pre>
	    $this->bbcode_table["/\[code\](.*?)\[\/code\]/is"] = function ($match) {
		  global $summary;
		  return ($summary) ? '<i class="fa fa-code"></i>&hellip; ' : '<pre class="message w90">' .str_replace('<br />', '', $match[1]). '</pre>';
	      #return "<pre><code>$match[1]</code></pre>";  
	    };
	
	    // Replace [quote]2017-03-221103009fd11[/quote] with <blockquote>User</blockquote>
	    $this->bbcode_table["/\[quote\](\d{4}-\d{2}-\d{8}[a-z\d]{5})\[\/quote\]/is"] = function ($match) {
		    $reply = $match[1];
			if(flatDB::isValidEntry('reply', $reply))
			{
			    global $lang;
				$replyEntry = flatDB::readEntry('reply', $reply);
				$topicEntry = flatDB::readEntry('topic', $replyEntry['topic']);
				return '<a class="PostMention hint--top hint--rounded" href="view.php/topic/' .$replyEntry['topic']. '/p/' .Util::onPage($reply, $topicEntry['reply']). '#' .$reply. '" data-hint="' .$lang['quote_by']. ' ' .$replyEntry['trip']. '"><i class="fa fa-quote-left"></i> '.$replyEntry['trip']. '</a> ';
			}
			else
			{
				return '<a class="button secondary">[?]</a>';
			}
	    };	
	  }
	  
	  public function toHTML ($str, $escapeHTML=false, $nr2br=false) {
	    if (!$str) { 
	      return "";
	    }
	    
	    if ($escapeHTML) {
	      $str = htmlspecialchars($str);
	    }
	
	    foreach($this->bbcode_table as $key => $val) {
	      $str = preg_replace_callback($key, $val, $str);
	    }
	
	    if ($nr2br) {
	      $str = preg_replace_callback("/\n\r?/", function ($match) { return "<br/>"; }, $str);
	    }
	       
	    return $str;
	  }	  
}