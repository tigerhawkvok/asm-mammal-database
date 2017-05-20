<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

if(!isset($out))
{
	exit;
}
# Template pour les fils RSS
if($out['self'] === 'feed')
{
	require THEME_DIR . $config['theme'] . DS . 'feed.tpl.php';
}
# Sinon on intègre le template par défaut (main.tpl.php)
else
{
    # Statistiques / Menu déroulant des forums / Flux RSS
	$out['content'] .= '
	<aside>';
	
	# Affichage des Statistiques uniquement sur la liste des forums et la page d’accueil
	if(in_array($cur, array('forum','home','viewTopic','viewForum'))) {
		
	$out['content'] .= '<div class="well stats">
						<ul>
							<li>
								<div><span class="count">' .count(flatDB::listEntry('topic')). '</span> ' .$lang['topic']. Util::pluralize(count(flatDB::listEntry('topic')),$lang['plural']). '</div>
							</li>
							<li>
								<div><span class="count">' .count(flatDB::listEntry('reply')). '</span> ' .$lang['reply']. Util::pluralize(count(flatDB::listEntry('reply')),$lang['plural']). '</div>
							</li>
							<li>
								<div><span class="count">' .count(array_merge(flatDB::listEntry('topic'), flatDB::listEntry('reply'))). '</span> ' .$lang['count']. Util::pluralize(count(array_merge(flatDB::listEntry('topic'), flatDB::listEntry('reply'))),$lang['plural']). '</div>
							</li>
						</ul>
					</div>';

	# Liste des forums par menu déroulant    	    
    $out['content'] .= '
    	<div class="row align-center">
    	  <div class="col col-12">
    	  
	        <div class="float-left">
			    <button class="btn btn-small" data-component="dropdown" data-target="#quickNav">' .$lang['quickNav']. ' <span class="caret down"></span></button>
				<ul class="dropdown hide" id="quickNav">';
				$forums = flatDB::listEntry('forum');
				asort($forums);
				foreach($forums as $forum)
				{
					$forumEntry = flatDB::readEntry('forum', $forum);
					$out['content'] .= '<li>&nbsp;<a href="view.php' . DS . 'forum' . DS . $forum. '"><i class="fa ' .$forumEntry['font_icon']. '" style="color:' .$forumEntry['badge_color']. '!important">&nbsp;</i> ' .$forumEntry['name']. '</a></li>';
				}
				$out['content'] .= '</ul>
		    </div>';
	}	    
	# Flux RSS	
	if ($cur=='home') {				
    	$out['content'] .= '		    
	        <div class="float-right">
			  <a class="label warning upper" href="feed.php' . DS . 'topic"><i class="fa fa-rss"></i> '.Util::lang('feed topic').'</a>&nbsp; 
			  <a class="label warning upper" href="feed.php' . DS . 'reply"><i class="fa fa-rss"></i> '.Util::lang('feed reply').'</a>
		    </div>';
	} else if ($cur=='viewForum') {	
   		$out['content'] .= '		    
	        <div class="float-right">
			  <a class="label warning upper" href="feed.php' . DS . 'forum' . DS . $_GET['forum']. '"><i class="fa fa-rss"></i> '.Util::lang('feed forum').'</a>
		    </div>';	
	} else if ($cur=='viewTopic') {	
   		$out['content'] .= '		    
	        <div class="float-right">
			  <a class="label warning upper" href="feed.php' . DS . 'topic' . DS . $_GET['topic']. '"><i class="fa fa-rss"></i> '.Util::lang('feed thread').'</a>
		    </div>';	
	} 
		 			
	$out['content'] .= '
    	  </div>		   
	    </div>	
	</aside>';
	
	require THEME_DIR . $config['theme'] . DS . 'main.tpl.php';
}

?>
