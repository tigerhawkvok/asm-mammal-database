<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
 *
 * BBCode to HTML converter
*/

class BBCode
{
	protected $bbcode_table = array();
    /**
     * Protected constructor since this is a static class.
     *
     * @access  protected
     */
	  public function __construct () {
	    // Replace [b]...[/b] with <strong>...</strong>
	    $this->bbcode_table["/\[b\](.*?)\[\/b\]/is"] = function ($match) {
	      return "<strong>$match[1]</strong>";
	    };
		
	    // Replace [i]...[/i] with <em>...</em>
	    $this->bbcode_table["/\[i\](.*?)\[\/i\]/is"] = function ($match) {
	      return "<em>$match[1]</em>";
	    };	
	
	    // Replace [code]...[/code] with <pre><code>...</code></pre>
	    $this->bbcode_table["/\[code\](.*?)\[\/code\]/is"] = function ($match) {
		  global $summary;
		  return ($summary) ? '<i class="fa fa-code"></i>&hellip; ' : '<pre class="message w90">' .str_replace('<br />', '', $match[1]). '</pre>';
	      #return "<pre><code>$match[1]</code></pre>";  
	    };

	    // Replace [blockquote]...[/blockquote] with <blockquote><p>...</p></blockquote>
	    $this->bbcode_table["/\[blockquote\](.*?)\[\/blockquote\]/is"] = function ($match) {
	      return "<blockquote><p>$match[1]</p></blockquote>";
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
	   
	    // Replace [size=30]...[/size] with <span style="font-size:30%">...</span>
	    $this->bbcode_table["/\[size=(\d+)\](.*?)\[\/size\]/is"] = function ($match) {
	      return "<span style=\"font-size:$match[1]px\">$match[2]</span>";
	    };
	
	    // Replace [s] with <del>
	    $this->bbcode_table["/\[s\](.*?)\[\/s\]/is"] = function ($match) {
	      return "<del>$match[1]</del>";
	    };
		
	    // Replace [u]...[/u] with <span style="text-decoration:underline;">...</span>
	    $this->bbcode_table["/\[u\](.*?)\[\/u\]/is"] = function ($match) {
	      return '<span style="text-decoration:underline;">' . $match[1] . '</span>';
	    };
	    
	    // Replace [center]...[/center] with <div style="text-align:center;">...</div>
	    $this->bbcode_table["/\[center\](.*?)\[\/center\]/is"] = function ($match) {
	      return '<div style="text-align:center;">' . $match[1] . '</div>';
	    };

	    // Replace [right]...[/right] with <div style="text-align:right;">...</div>
	    $this->bbcode_table["/\[right\](.*?)\[\/right\]/is"] = function ($match) {
	      return '<div style="text-align:right;">' . $match[1] . '</div>';
	    };	
	    	
	    // Replace [color=somecolor]...[/c	olor] with <span style="color:somecolor">...</span>
	    $this->bbcode_table["/\[color=([#a-z0-9]+)\](.*?)\[\/color\]/is"] = function ($match) {
	      return '<span style="color:'. $match[1] . ';">' . $match[2] . '</span>';
	    };
	
	    // Replace [email]...[/email] with <a href="mailto:...">...</a>
	    $this->bbcode_table["/\[email\](.*?)\[\/email\]/is"] = function ($match) {
	      return "<a href=\"mailto:$match[1]\">$match[1]</a>"; 
	    };
	
	    // Replace [email=someone@somewhere.com]An e-mail link[/email] with <a href="mailto:someone@somewhere.com">An e-mail link</a>
	    $this->bbcode_table["/\[email=(.*?)\](.*?)\[\/email\]/is"] = function ($match) {
	      return "<a href=\"mailto:$match[1]\">$match[2]</a>"; 
	    };
		
	    // Replace [url]...[/url] with <a href="...">...</a>
	    $this->bbcode_table["/\[url\](.*?)\[\/url\]/is"] = function ($match) {
	      return "<a href=\"$match[1]\">$match[1]</a>"; 
	    };
	   
	    // Replace [url=http://www.google.com/]A link to google[/url] with <a href="http://www.google.com/">A link to google</a>
	    $this->bbcode_table["/\[url=(.*?)\](.*?)\[\/url\]/is"] = function ($match) {
	      return "<a href=\"$match[1]\">$match[2]</a>"; 
	    };    
	
	    // Replace [img]...[/img] with <img src="..."/>
	    $this->bbcode_table["/\[img\](.*?)\[\/img\]/is"] = function ($match) {
	      return '<span class="zoom"><img class="img-zoom" src="'.$match[1].'" alt="image"/></span>'; 
	    };
	    	    
	    // Replace [list]...[/list] with <ul><li>...</li></ul>
	    $this->bbcode_table["/\[list\](.*?)\[\/list\]/is"] = function ($match) {
	      $match[1] = preg_replace_callback("/\[\*\]([^\[\*\]]*)/is", function ($submatch) {
	        return "<li>" . preg_replace("/[\n\r?]$/", "", $submatch[1]) . "</li>";
	      }, $match[1]);
	
	      return "<ul>" . preg_replace("/[\n\r?]/", "", $match[1]) . "</ul>";
	    };
		
	    // Replace [list=1|a]...[/list] with <ul|ol><li>...</li></ul|ol>
	    $this->bbcode_table["/\[list=(1|a)\](.*?)\[\/list\]/is"] = function ($match) {
	      if ($match[1] == '1') {
	        $list_type = '<ol>';
	      } else if ($match[1] == 'a') {
	        $list_type = '<ol style="list-style-type: lower-alpha">';
	      } else {
	        $list_type = '<ol>';
	      }
	
	      $match[2] = preg_replace_callback("/\[\*\]([^\[\*\]]*)/is", function ($submatch) {
	        return "<li>" . preg_replace("/[\n\r?]$/", "", $submatch[1]) . "</li>";
	      }, $match[2]);
	
	      return $list_type . preg_replace("/[\n\r?]/", "", $match[2]) . "</ol>";
	    };
		
	    // Replace [youtube]...[/youtube] with <iframe src="..."></iframe>
	    $this->bbcode_table["/\[youtube\](?:http?:\/\/)?(?:www\.)?youtu(?:\.be\/|be\.com\/watch\?v=)([A-Z0-9\-_]+)(?:&(.*?))?\[\/youtube\]/i"] = function ($match) {
		  global $summary;
		  $url = urldecode(rawurldecode($match[1]));
		  return ($summary) ? "<i class=\"fa fa-youtube\"></i>&hellip; " : "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/\"$match[1]\" frameborder=\"0\" allowfullscreen></iframe>";	  
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