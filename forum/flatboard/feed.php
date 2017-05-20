<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'feed';
require_once __DIR__ . '/header.php';
# FILS SUR TOUTES LES DISCUSSIONS GLOBALE
if(Util::isGET('topic'))
{
	$out['subtitle'] = $lang['topic'];
	$out['type'] = 'topic';
		
	$topics = flatDB::listEntry('topic');
    $nb = $config['ItemByPage'];
	$total = Paginate::countPage($topics, $nb);
	$p = Paginate::pid($total);	
	arsort($topics, SORT_NATURAL | SORT_FLAG_CASE);
	if($topics)
	{
		foreach(Paginate::viewPage($topics, $p, $nb) as $topic)
		{
			$topicEntry = flatDB::readEntry('topic', $topic);
			$url = 'view.php' . DS . 'topic' . DS . $topic;
			$out['content'] .= '<entry>
				<id>' .$out['baseURL'] . $url. '</id>
				<title>' .$topicEntry['trip']. ': ' .$topicEntry['title']. '</title>
				<updated>' .Util::toDate($topic, 'c'). '</updated>
				<link href="' .$url. '"/>
				<summary type="html">' .htmlspecialchars(Parser::summary(Parser::content($topicEntry['content'],true)), ENT_QUOTES). '</summary>
			</entry>';
		}
	}
}
# FILS SUR TOUTES LES REPONSES
else if(Util::isGET('reply'))
{
	$out['subtitle'] = $lang['reply'];
	$out['type'] = 'reply';
	
	$replies = flatDB::listEntry('reply');
    $nb = $config['ItemByPage'];
	$total = Paginate::countPage($replies, $nb);
	$p = Paginate::pid($total);	
	arsort($replies, SORT_NATURAL | SORT_FLAG_CASE);	
	if($replies)
	{
		foreach(Paginate::viewPage($replies, $p, $nb) as $reply)
		{
			$replyEntry = flatDB::readEntry('reply', $reply);
			$topicEntry = flatDB::readEntry('topic', $replyEntry['topic']);
			$url = 'view.php' . DS . 'topic' . DS . $replyEntry['topic'] . DS . 'p' . DS . Util::onPage($reply, $topicEntry['reply']). '#' .$reply;
			$out['content'] .= '<entry>
				<id>' .$out['baseURL'].$url. '</id>
				<title>' .$replyEntry['trip']. ': ' .$topicEntry['title']. '</title>
				<updated>' .Util::toDate($reply, 'c'). '</updated>
				<link href="' .$url. '"/>
				<summary type="html">' .htmlspecialchars(Parser::summary(Parser::content($replyEntry['content'],true)), ENT_QUOTES). '</summary>
			</entry>';
		}
	}
}
# FILS SUR TOUTES LES DISCUSSIONS D'UN FORUM
else if(Util::isGETValidEntry('forum', 'forum'))
{
	$forumEntry = flatDB::readEntry('forum', $_GET['forum']);
	$out['subtitle'] = $forumEntry['name'];
	$out['type'] = 'forum';
		
	$topics = $forumEntry['topic'];	
	
    $nb = $config['ItemByPage'];
	$total = Paginate::countPage($topics, $nb);
	$p = Paginate::pid($total);
	arsort($topics, SORT_NATURAL | SORT_FLAG_CASE);
	if($topics)
	{
		foreach(Paginate::viewPage($topics, $p, $nb) as $topic)
		{
			$topicEntry = flatDB::readEntry('topic', $topic);
			$url = 'view.php' . DS . 'topic' . DS . $topic;
			$out['content'] .= '<entry>
				<id>' .$out['baseURL'] . $url. '</id>
				<title>' .$topicEntry['trip']. ': ' .$topicEntry['title']. '</title>
				<updated>' .Util::toDate($topic, 'c'). '</updated>
				<link href="' .$url. '"/>
				<summary type="html">' .htmlspecialchars(Parser::summary(Parser::content($topicEntry['content'],true)), ENT_QUOTES). '</summary>
			</entry>';
		}
	}
}
# FILS D'UNE DISCUSSIONS
else if(Util::isGETValidEntry('topic', 'topic'))
{
	$topicEntry = flatDB::readEntry('topic', $_GET['topic']);
	
	$out['subtitle'] = $topicEntry['title'];
	$out['type'] = 'thread';
	
	$topic = $_GET['topic'];
	$url = 'view.php' . DS . 'topic' . DS . $topic;
	$out['content'] .= '<entry>
				<id>' .$out['baseURL'] . $url. '</id>
				<title>' .$topicEntry['trip']. ': ' .$topicEntry['title']. '</title>
				<updated>' .Util::toDate($topic, 'c'). '</updated>
				<link href="' .$url. '"/>
				<summary type="html">' .htmlspecialchars(Parser::summary(Parser::content($topicEntry['content'],true)), ENT_QUOTES). '</summary>
			</entry>';
}
else
{
	Util::redirect('index.php' . DS . '404');
}

require PATH_ROOT . DS . 'footer.php';

?>