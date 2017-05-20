<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'index';
require_once __DIR__ . '/header.php';

/**
 * LISTE DES FORUMS
 **/
if(Util::isGET('forum'))
{
    $cur = 'forum'; # Indicateur de page
	$out['subtitle'] = $lang['forum'];
	$out['sub_prefix'] = User::isAdmin()? '<a href="add.php' . DS . 'forum" class="hint--top hint--rounded" data-hint="' .$lang['add_forum']. '"><i class="fa fa-plus-circle"></i></a> ' : '';
	$forums = flatDB::readEntry('config', 'forumOrder');
	$options = '';
	if($forums)
	{
		if(User::isAdmin() && !empty($_POST) && CSRF::check($token))
		{
			foreach($forums as $forum)
			{
				$order[$forum] = Util::isPOST($forum)? $_POST[$forum] : '0';
			}
			asort($order);
			$order = array_keys($order);
			$forums = array_combine($order, $order);
			flatDB::saveEntry('config', 'forumOrder', $forums);
		}

		$num = range(1, count($forums));
		$options = array_combine($num, $num);

		$controlStr = '';
		$out['content'] .= '
			<table class="bordered striped">
				<thead class="bg-highlight">
					<tr>
						<th class="w5">&nbsp;</th>
						<th class="w65">' .$lang['forum']. '</th>
						<th class="w10">' .$lang['topic']. '</th>
						<th class="w20">' .$lang['date']. '</th>
					</tr>
				</thead>
				<tbody>';
			#asort($forums);
			foreach(array_values($forums) as $key => $forum)
			{
				$forumEntry = flatDB::readEntry('forum', $forum);
				$lang[$forum] = $forumEntry['name'];
				$controlStr .= HTMLForm::select($forum, $options, $key+1, 'w20');
				$out['content'] .= '
				<tr>
					<td style="color:' .$forumEntry['badge_color']. '">
						<i class="fa fa-3x ' .$forumEntry['font_icon']. '"></i>
					</td>
					<td>
						' .entryLink::manageForum($forum). '<a href="view.php' . DS . 'forum' . DS . $forum. '"><b>' .$forumEntry['name']. '</b></a><br />
					   <span class="muted"> &raquo; ' .$forumEntry['info']. '</span>
					</td>
					<td class="text-centered">
						<span class="label big">' .Util::shortNum(count($forumEntry['topic'])). '</span>
					</td>
					<td>
						' .($forumEntry['topic']? Util::toDate(end($forumEntry['topic'])) : '---'). '
					</td>
				</tr>';
			}
			$out['content'] .= '
				</tbody>
			</table>'.
			# ON GÉNÈRE LE FORMULAIRE D’ORDONNANCE DES FORUMS
			(User::isAdmin()? 
			'<button data-component="toggleme" data-target="#order" data-text="' .$lang['sort_forums']. '"><i class="fa fa-sort"></i> ' .$lang['sort_forums']. '</button>
			<div id="order" class="w50 hide">'.HTMLForm::form('index.php/forum',
					$controlStr.
					HTMLForm::simple_submit(). '
			</div>') : '');	
	}
	else
	{
		$out['content'] .= '<p>' .$lang['none']. '</p>';
	}
}
/*
** AFFICHE LA PAGE D’ERREUR 404
*/
else if(Util::isGET('404'))
{
    $cur = 'error'; # Indicateur de page
	$out['subtitle'] = 'HTTP 404';
	$out['content'] .= '<p>' .$lang['notFound']. '</p>';
}
/*
** Whois
*/
else if(Util::isGET('whois'))
{
	require_once LIB_DIR . 'Whois.lib.php';
	$whois = new Whois;
    $cur = 'whois'; # Indicateur de page
	$out['subtitle'] = 'Whois Loockup';
	$out['content'] .= (User::isWorker()? $whois->whoislookup($_GET['whois']) : 'You don\'t have permission to access on this page.');
}
/**
 * PAGE D’ACCUEIL/NOUVEAUX MESSAGES
 **/
else
{
    $cur = 'home'; # Indicateur de page
	$out['subtitle'] = $lang['new'];
	$out['sub_prefix'] = '';
	$config = flatDB::readEntry('config', 'config');

	#$mixes = Util::_max(array_merge(flatDB::listEntry('topic'), flatDB::listEntry('reply')), $config['ItemByPage']);
	$mixes = array_merge(flatDB::listEntry('topic'), flatDB::listEntry('reply'));
	$nb = $config['ItemByPage'];
	$total = Paginate::countPage($mixes, $nb);
	$p = Paginate::pid($total);
		
	if($mixes)
	{
		rsort($mixes);
		$topic = $mixes[0];
		if(!flatDB::isValidEntry('topic', $topic))
		{
			$replyEntry = flatDB::readEntry('reply', $topic);
			$topic = $replyEntry['topic'];
		}
		$topicEntry = flatDB::readEntry('topic', $topic);
		$count = count($topicEntry['reply'])+1;
		$width = $count <= 4 ? 12/$count : 3;
		# ON RETOURNE LA DERNIÈRE DISCUSSION		
		$out['content'] .= '
			<div class="col col-12">
			       <p class="h1">
			    		' .Parser::title($topicEntry['title']). '
				   </p>	    
	               <div class="big">
	               		' .Parser::summary(Parser::content($topicEntry['content'],true),30). '
	               </div>
	               <div id="action-buttons">
	               		<p>
	               		' .($topicEntry['locked']? 
	               		'<a title="' .Util::lang('topic locked'). '" class="button red large" href="view.php' . DS . 'topic' . DS . $topic. '">' .$lang['more']. ' <i class="fa fa-lock"></i></a>' : 
	               		'<a title="' .$lang['more']. '" class="button large" href="view.php' . DS . 'topic' . DS . $topic. '">' .$lang['more']. ' <i class="fa fa-arrow-circle-right"></i></a>'). '
	               		</p>
	               </div>
            </div>
            <hr />';
            # ON LISTE LES 3 DERNIÈRES RÉPONSES S’IL Y EN A
            if($topicEntry['reply']){
				$out['content'] .= '			
			<div class="row gutters">';    
					foreach(array_slice($topicEntry['reply'], -3) as $reply)
					{
						$replyEntry = flatDB::readEntry('reply', $reply);
						$out['content'] .= '
						<div class="col col-4 small">
							' .Plugin::hook('profile_index', $replyEntry['trip']). '
							<a title="' .$lang['more']. '" class="float-right" href="view.php' . DS . 'topic' . DS . $replyEntry['topic']. DS. 'p'. DS . Util::onPage($reply, $topicEntry['reply']). '#' .$reply. '"><i class="fa fa-external-link-square" aria-hidden="true"></i></a>
							<span class="user ' .$replyEntry['role']. '">'.$replyEntry['trip']. '</span>: 							' .Parser::summary(Parser::content($replyEntry['content'], true), 20). '
						</div>';
					}
				$out['content'] .= '
			</div>';					
            }
			$out['content'] .= '
			<hr />
			<div class="row gutters">
			
				<div class="col col-4">';
				# LISTE DES FORUMS
				$forums = flatDB::readEntry('config', 'forumOrder');
				if($forums)
				{
					if(User::isAdmin() && !empty($_POST) && CSRF::check($token))
					{
						foreach($forums as $forum)
						{
							$order[$forum] = Util::isPOST($forum)? $_POST[$forum] : '0';
						}
						asort($order);
						$order = array_keys($order);
						$forums = array_combine($order, $order);
						flatDB::saveEntry('config', 'forumOrder', $forums);
					}
			
					$num = range(1, count($forums));
					$options = array_combine($num, $num);
			
					$controlStr = '';
					$out['content'] .= '
					<table class="striped bordered">
						<thead class="bg-highlight">
							<tr>
								<th>' .(User::isAdmin()? '<a href="add.php' . DS . 'forum" class="hint--top hint--rounded" data-hint="' .$lang['add_forum']. '"><i class="fa fa-plus-circle"></i></a> ' : '').$lang['forum']. '</th>
							</tr>
						</thead>
						
						<tbody>
						<tr>
							<td>
								<ul class="unstyled">';
								#asort($forums);
								foreach(array_values($forums) as $key => $forum)
								{
									$forumEntry = flatDB::readEntry('forum', $forum);
									$lang[$forum] = $forumEntry['name'];
									$controlStr .= HTMLForm::select($forum, $options, $key+1, 'w20');
									$out['content'] .= '<li>' .entryLink::manageForum($forum). '<i class="label badge" style="background-color:' .$forumEntry['badge_color']. '!important">' .count($forumEntry['topic']). '</i> <a class="hint--top hint--rounded" data-hint="' .Parser::summary($forumEntry['info'],30). '" href="view.php' . DS . 'forum' . DS . $forum. '">' .$forumEntry['name']. '</a>
									</li>';
								}
								$out['content'] .= '
								</ul>
							</td>
						</tr>
						</tbody>
					</table>'.
					
					# ON GÉNÈRE LE FORMULAIRE D’ORDONNANCE DES FORUMS
					(User::isAdmin()? 
					'<button data-component="toggleme" data-target="#order" data-text="' .$lang['sort_forums']. '"><i class="fa fa-sort"></i> ' .$lang['sort_forums']. '</button>
					<div id="order" class="hide">'.HTMLForm::form('index.php/forum',
								$controlStr.
								HTMLForm::simple_submit(). '
					</div>') : '');	
				}
				else
				{
					$out['content'] .= '<p>' .$lang['none']. '</p>';
				}
				
		$out['content'] .= '
				</div>
				<!-- /.col col-4 -->';
		
				# TABLEAU DE SUGGESTION DES DERNIERS SUJETS & RÉPONSES		
				$out['content'] .= '
				<div class="col col-8">
								
					<table class="ajaxscroll striped">
					<thead class="bg-highlight">
						<tr>
							<th class="w60">' .$lang['topic']. '</th>
							<th class="w40">' .$lang['forum']. ' / Stats</th>
						</tr>
					</thead>
					<tbody>';
					rsort($mixes); // For sort the pagination!
					foreach(Paginate::viewPage($mixes, $p, $nb) as $mix)			
					#foreach($mixes as $mix)
					{
						if(flatDB::isValidEntry('topic', $mix))
						{
							$topic = $mix;
							$topicEntry = flatDB::readEntry('topic', $topic);
							$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
							$out['content'] .= '
							<tr class="item">
								<td>
									' .entryLink::manageTopic($topic).'<a href="view.php' . DS . 'topic' . DS . $topic. '">' .Parser::title($topicEntry['title']). '</a><br />
									' .Plugin::hook('profile_index', $topicEntry['trip']). '
									<span class="user ' .$topicEntry['role']. '">'.$topicEntry['trip']. '</span> ' .$lang['started']. ' ' .Util::toDate($topic, $config['date_format']). '
								</td>
								<td>
									<span class="float-right">' .Util::shortNum($topicEntry['view']). '&nbsp;<i class="fa fa-eye" title="' .$lang['view']. '"></i></span>
									<a class="label badge" style="background-color:' .$forumEntry['badge_color']. '!important" href="view.php' . DS . 'forum' . DS . $topicEntry['forum']. '"><i class="fa ' .$forumEntry['font_icon']. '"></i> ' .$forumEntry['name']. '</a><br /> 		
									<span class="float-right">' .Util::shortNum(count($topicEntry['reply'])). '&nbsp;<i class="fa fa-comment-o" title="' .$lang['reply']. '"></i></span>
								</td>
							</tr>';
						}
						else
						{
							$reply = $mix;
							$replyEntry = flatDB::readEntry('reply', $reply);
							$topicEntry = flatDB::readEntry('topic', $replyEntry['topic']);
							$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
							$out['content'] .= '
							<tr class="item">
								<td>
									' .entryLink::manageReply($reply).'<a href="view.php' . DS . 'topic' . DS . $replyEntry['topic']. DS. 'p'. DS . Util::onPage($reply, $topicEntry['reply']). '#' .$reply. '">' .Parser::title($topicEntry['title']). '</a><br />
									' .Plugin::hook('profile_index', $replyEntry['trip']). '
									<span class="user ' .$replyEntry['role']. '">'.$replyEntry['trip']. '</span> ' .$lang['replied']. ' ' .Util::toDate($reply, $config['date_format']). '
								</td>
								<td>
									<span class="float-right">' .Util::shortNum($topicEntry['view']). '&nbsp;<i class="fa fa-eye" title="' .$lang['view']. '"></i></span>
									<a class="label badge" style="background-color:' .$forumEntry['badge_color']. '!important" href="view.php' . DS . 'forum' . DS . $topicEntry['forum']. '"><i class="fa ' .$forumEntry['font_icon']. '"></i> ' .$forumEntry['name']. '</a><br /> 
									<span class="float-right">' .Util::shortNum(count($topicEntry['reply'])). '&nbsp;<i class="fa fa-comment-o" title="' .$lang['reply']. '"></i></span>
								</td>
							</tr>';
						}
					}
					$out['content'] .= '</tbody>
					</table>
					' .Paginate::pageLink($p, $total, 'index.php' . DS . 'news' . DS . 'o'). '
				</div>
				<!-- /.col col-8 -->
		
			</div>
			<!-- /.row gutters -->';
	}
	else
	{
		$out['content'] .= '<p>' .$lang['none']. '</p>';
	}

}

require PATH_ROOT . DS . 'footer.php';

?>