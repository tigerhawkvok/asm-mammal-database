<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'view';
require_once __DIR__ . '/header.php';
/**
 * AFFICHE UNE DISCUSSION
 **/
if(Util::isGETValidEntry('topic', 'topic'))
{
	$cur = 'viewTopic'; # Indicateur de page	
	$topicEntry = flatDB::readEntry('topic', $_GET['topic']);
	$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
	# Boutton de signalement
	$report =(function_exists('mail') ? ' <a class="button red small hint--top hint--rounded" href="add.php' . DS . 'report' . DS . $_GET['topic']. '" data-hint="' .$lang['report']. '"><i class="fa fa-exclamation-triangle"></i></a>' : '');
	$role = (!$topicEntry['role'] == '' ? $topicEntry['role'] : 'admin');
	
	$getTopic = (isset($forumEntry['pinnedTopic'][$_GET['topic']]) ? $forumEntry['pinnedTopic'][$_GET['topic']] : null);
	
	# Topic view++
	$topicEntry['view']++;
	flatDB::saveEntry('topic', $_GET['topic'], $topicEntry);

	$out['subtitle'] = $topicEntry['title'];
	# FIL D’ARIANE
	$out['content'] .= '<nav class="breadcrumbs">
    <ul>
		<li><a href="index.php' . DS . 'forum">' .$lang['forum']. '</a></li>
		<li><a href="view.php' . DS . 'forum' . DS . $topicEntry['forum']. '">' .$forumEntry['name']. '</a></li>
		<li><span>' .Parser::title($out['subtitle']). '</span></li>
		<li class="muted">' .$lang['count']. ' <span class="label focus outline">' .(count($topicEntry['reply']) + 1). '</span></li>
    </ul>
    </nav>
    
		<table class="topic w100">
			<thead>
				<tr>
					<th class="w20">&nbsp;</th>
					<th class="w80"><span class="upper float-right"><i class="fa fa-calendar"></i> ' .Util::toDate($_GET['topic'], $config['date_format']). '</span></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>
					   <ul class="unstyled">
					   <li class="user ' .$topicEntry['role']. '">' .entryLink::manageTopic($_GET['topic']).$topicEntry['trip']. '</li>';
					   if($topicEntry['role'] === 'admin') $out['content'] .= '<li class="label error outline"><i class="fa fa-user-secret"></i> ' .$lang['admin']. '</li>';        
					   if($topicEntry['role'] === 'worker') $out['content'] .= '<li class="label success outline"><i class="fa fa-user"></i> ' .$lang['modo']. '</li>';	        	
					   $out['content'] .= 
			           Plugin::hook('profile', $topicEntry['trip']).
			           (User::isWorker()? '
					   <li>' .entryLink::userBan($topicEntry['ip']). '<span class="label label-outline">' .$topicEntry['ip']. '</span></li>' : ''). '
					   </ul>			           					
					</td>
					
					<td>
			            ' .Parser::content($topicEntry['content']). '			            
			          
			            ' .($getTopic ? '<hr /><span style="color:#2D8C61;font-size:14px !important"><i class="fa fa-thumb-tack"></i> ' .Util::lang('%s stickied_discussion', $lang[$role]). '</span>' : '').
			            
			            ($topicEntry['locked'] ? '<hr /><span style="color:#d13e32;font-size:14px !important"><i class="fa fa-lock"></i> ' .Util::lang('%s locked_discussion', $lang[$role]). '</span>' : ''). '
						
						<div class="hook_topic">' .Plugin::hook('afterTopic', $_GET['topic']). '</div>				
					</td>
				</tr>
			</tbody>
			<tfoot>
				<tr class="bold">
					<td colspan="2">
						' .(!$topicEntry['locked']? 
						'<a class="button small" href="add.php' . DS . 'reply' . DS . $_GET['topic']. '"><i class="fa fa-plus"></i> ' .$lang['newreply']. '</a> 
						' .$report : '<span class="button red disabled small"><i class="fa fa-lock"></i> ' .$lang['no_reply']. '</span>'). 
						Plugin::hook('bottomTopic', $_GET['topic']). '
					</td>
				</tr>
			</tfoot>
		</table>';
	# AFFICHAGE DES RÉPONSES	
    asort($topicEntry['reply']);
    $nb = $config['ItemByPage'];
	$total = Paginate::countPage($topicEntry['reply'], $nb);
	$p = Paginate::pid($total);
	if($topicEntry['reply'])
	{
		foreach(Paginate::viewPage($topicEntry['reply'], $p, $nb) as $reply)
		{
			$replyEntry = flatDB::readEntry('reply', $reply);
			$out['content'] .= '
		<table id="' .$reply. '" class="w100">
			<thead>
				<tr>
					<th class="w20">
						<a class="hint--top hint--rounded" href="view.php' . DS . 'topic' . DS . $replyEntry['topic'] . DS . 'p' . DS . Util::onPage($reply, $topicEntry['reply']). '#' .$reply. '" data-hint="' .$lang['permalink']. '"><i class="fa fa-anchor"></i></a>
					</th>
					<th class="w80"><span class="upper float-right"><i class="fa fa-calendar"></i> ' .Util::toDate($reply, $config['date_format']). '</span></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>
					   <ul class="unstyled">
					   <li class="user ' .$replyEntry['role']. '">' .entryLink::manageReply($reply).$replyEntry['trip']. '</li>';
					   if($replyEntry['role'] === 'admin') $out['content'] .= '<li class="label error outline"><i class="fa fa-user-secret"></i> ' .$lang['admin']. '</li>';
					   if($replyEntry['role'] === 'worker') $out['content'] .= '<li class="label success outline"><i class="fa fa-user"></i> ' .$lang['modo']. '</li>';
					   
					   $out['content'] .=
			           Plugin::hook('profile', $replyEntry['trip']).
					  (User::isWorker()? '
					   <li>' .entryLink::userBan($replyEntry['ip']). '<span class="label black outline">' .$replyEntry['ip']. '</span></li>' : ''). '		
				       </ul>		
					</td>
					
					<td>
			            ' .Parser::content($replyEntry['content']). '
			            <div class="hook_topic">' .Plugin::hook('afterReply', $reply). '</div>				
					</td>
				</tr>
			</tbody>
			<tfoot>
				<tr class="bold">
					<td colspan="2">
						' .(!$topicEntry['locked']? 
						'<a class="button secondary small" href="add.php' . DS . 'reply' . DS . $_GET['topic']. DS. 'q' . DS .$reply. '"><i class="fa fa-comments"></i> ' .$lang['quote_reply']. '</a> 
						<a class="button small" href="add.php' . DS . 'reply' . DS . $_GET['topic']. '"><i class="fa fa-plus"></i> ' .$lang['newreply']. '</a> 
						' .$report : ''). 
						
					Plugin::hook('bottomReply', $reply). '
					</td>
				</tr>
			</tfoot>
		</table>';
		}
	}
	/**
	 * SUGGESTIONS DE SUJETS
	 **/
	$out['content'] .= Paginate::pageLink($p, $total, 'view.php' . DS . 'topic' . DS . $_GET['topic']).
	'<table class="striped">
	 <thead class="bg-highlight">
		<tr>
			<th class="w60">' .$lang['thread_sug']. '</th>
			<th class="w20">' .$lang['view']. ' / ' .$lang['reply']. '</th>
			<th class="w20">' .$lang['forum']. '</th>
		</tr>
	</thead>
	<tbody>';
	$topics = flatDB::listEntry('topic');
	shuffle($topics);
	foreach(array_slice($topics, 0, 4) as $topic)
	{
		$topicEntry = flatDB::readEntry('topic', $topic);
		$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
		$out['content'] .= '<tr>
			<td>' .entryLink::manageTopic($topic). ' <span class="user ' .$topicEntry['role']. '">' .$topicEntry['trip']. '</span> ' .$lang['started']. ' <a href="view.php' . DS . 'topic' . DS . $topic. '">' .Parser::title($topicEntry['title']). '</a></td>
			<td>' .Util::shortNum($topicEntry['view']). ' / ' .count($topicEntry['reply']). '</td>
			<td><a href="view.php' . DS . 'forum' . DS . $topicEntry['forum']. '">' .$forumEntry['name']. '</a></td>
		</tr>';
	}
	$out['content'] .= '</tbody>
	</table>';
}
/**
 * AFFICHE LA LISTE DES SUJETS D’UN FORUM
 **/
else if(Util::isGETValidEntry('forum', 'forum'))
{
	$cur = 'viewForum'; # Indicateur de page
	$forumEntry = flatDB::readEntry('forum', $_GET['forum']);
	$out['subtitle'] = $forumEntry['name'];
	$out['sub_prefix'] = entryLink::manageForum($_GET['forum']);
	$out['content'] .= '
	<div class="well" style="background-color:' .$forumEntry['badge_color']. '!important">
		 <i class="fa fa-2x ' .$forumEntry['font_icon']. '"></i> ' .$forumEntry['info'].
		 Plugin::hook('afterForum', $_GET['forum']).
	'</div>
	<p>	
		<a class="button large" role="button" href="add.php' . DS . 'topic' . DS . $_GET['forum']. '"><i class="fa fa-plus"></i> ' .$lang['newthread']. '</a>
    </p>';
	
	$pinnedTopic = array_diff($forumEntry['topic'], $forumEntry['pinnedTopic']);	
	$topics = array_merge($forumEntry['pinnedTopic'], array_reverse($pinnedTopic));	
	# Fixed for sort files by last modified date
	#usort($topics, function($x, $y) {
	#    return @filemtime($x) < @filemtime($y);
	#});	
    $nb = $config['ItemByPage'];
	$total = Paginate::countPage($topics, $nb);
	$p = Paginate::pid($total);

	if($topics)
	{
		$out['content'] .= '<table class="striped">
		<thead class="bg-highlight">
			<tr>
				<th>' .$lang['topic']. '</th>
				<th>' .$lang['author']. '</th>
				<th>' .$lang['view']. ' / ' .$lang['reply']. '</th>
			</tr>
		</thead>
		<tbody>';
		# On filtre par la date de dernière modification
	    arsort($topics, SORT_NATURAL | SORT_FLAG_CASE);
		foreach(Paginate::viewPage($topics, $p, $nb) as $topic)
		{
			$topicEntry = flatDB::readEntry('topic', $topic);
			$out['content'] .= '
			<tr>
				<td>
					' .entryLink::manageTopic($topic).(isset($forumEntry['pinnedTopic'][$topic])? '<span class="label badge warning hint--top  hint--rounded" data-hint="' .$lang['pinned']. '"><i class="fa fa-thumb-tack"></i></span> ':'').($topicEntry['locked']? '<span class="label badge error hint--top  hint--rounded" data-hint="' .$lang['locked']. '"><i class="fa fa-lock"></i></span> ':''). ' ' .Plugin::hook('titleTopic', $topic). '
					<a href="view.php' . DS . 'topic' . DS . $topic. '"><strong>' .Parser::title($topicEntry['title']). '</strong></a>
				</td>
				
				<td>
					' .Plugin::hook('profile_index', $topicEntry['trip']). '
					<span class="user ' .$topicEntry['role']. '">'.$topicEntry['trip']. '</span> <span class="muted">' .$lang['started']. ' ' .Util::toDate($topic, $config['date_format']). '</span>
				</td>
				
				<td>
					<span class="float-right">' .Util::shortNum($topicEntry['view']). '&nbsp;<i class="fa fa-eye" title="' .$lang['view']. '"></i></span>
					<br /> 		
					<span class="float-right">' .Util::shortNum(count($topicEntry['reply'])). '&nbsp;<i class="fa fa-comment-o" title="' .$lang['reply']. '"></i></span>
				</td>				
			</tr>';
		}
		$out['content'] .= '</tbody>
		</table>';
	}
	$out['content'] .= Paginate::pageLink($p, $total, 'view.php' . DS . 'forum' . DS . $_GET['forum']);
}
/**
 * AFFICHE LA PAGE DU PLUGIN
 **/
else if(Util::isGETValidHook('view', 'plugin'))
{
	$cur = (isset($_GET['plugin']) ? $_GET['plugin'] : null); # Indicateur de page
	$subtitle = (isset($_GET['plugin']) ? $lang[$_GET['plugin'].'name'] : null);
	$out['subtitle'] = $subtitle;
	$out['content'] .= Plugin::myHook('view', $_GET['plugin']);
}
/**
 * RETURN LA PAGE 404
 **/
else
{
	Util::redirect('index.php' . DS . '404');
}

require PATH_ROOT . DS . 'footer.php';

?>