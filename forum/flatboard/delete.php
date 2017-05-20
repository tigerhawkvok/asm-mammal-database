<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'delete';
require_once __DIR__ . '/header.php';

if(Util::isGETValidEntry('topic', 'topic') && (User::isWorker() || User::isAuthor($_GET['topic'])))
{
	$topicEntry = flatDB::readEntry('topic', $_GET['topic']);
	$out['subtitle'] = Util::lang('delete topic : %s', $topicEntry['title']);
	if(HTMLForm::checkBot() && CSRF::check($token) )
	{
		flatDB::deleteEntry('topic', $_GET['topic']);

		$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
		unset($forumEntry['topic'][$_GET['topic']]);
		unset($forumEntry['pinnedTopic'][$_GET['topic']]);
		flatDB::saveEntry('forum', $topicEntry['forum'], $forumEntry);

		foreach($topicEntry['reply'] as $reply)
		{
			flatDB::deleteEntry('reply', $reply);
		}
		$out['content'] .= Plugin::redirectMsg($lang['topic_deleted'], 'view.php' . DS . 'forum' . DS . $topicEntry['forum'], $forumEntry['name']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('delete.php' . DS . 'topic' . DS . $_GET['topic'],
			HTMLForm::submit());
	}
}
else if(Util::isGETValidEntry('reply', 'reply') && (User::isWorker() || User::isAuthor($_GET['reply'])))
{
	$replyEntry = flatDB::readEntry('reply', $_GET['reply']);
	$out['subtitle'] = Util::lang('delete reply');
	if(HTMLForm::checkBot() && CSRF::check($token) )
	{
		flatDB::deleteEntry('reply', $_GET['reply']);

		$topicEntry = flatDB::readEntry('topic', $replyEntry['topic']);
		unset($topicEntry['reply'][$_GET['reply']]);
		flatDB::saveEntry('topic', $replyEntry['topic'], $topicEntry);
		
		$out['content'] .= Plugin::redirectMsg($lang['reply_deleted'], 'view.php' . DS . 'topic' . DS . $replyEntry['topic'], $topicEntry['title']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('delete.php' . DS . 'reply' . DS . $_GET['reply'],
			HTMLForm::submit());
	}
}
else if(Util::isGETValidEntry('forum', 'forum') && User::isAdmin())
{
	$forumEntry = flatDB::readEntry('forum', $_GET['forum']);
	$out['subtitle'] = Util::lang('delete forum : %s', $forumEntry['name']);
	if(HTMLForm::checkBot() && CSRF::check($token) )
	{
		flatDB::deleteEntry('forum', $_GET['forum']);
		$forums = flatDB::readEntry('config', 'forumOrder');
		unset($forums[$_GET['forum']]);
		flatDB::saveEntry('config', 'forumOrder', $forums);

		foreach($forumEntry['topic'] as $topic)
		{
			$topicEntry = flatDB::readEntry('topic', $topic);
			flatDB::deleteEntry('topic', $topic);

			foreach($topicEntry['reply'] as $reply)
			{
				flatDB::deleteEntry('reply', $reply);
			}
		}
		$out['content'] .= Plugin::redirectMsg($lang['forum_deleted'], 'index.php' . DS . 'forum', $lang['forum']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('delete.php' . DS . 'forum' . DS . $_GET['forum'],
			HTMLForm::submit());
	}
}
else if(Util::isGET('worker') && User::isAdmin() && isset($config['worker'][$_GET['worker']]))
{
	$out['subtitle'] = Util::lang('delete worker : %s', $config['worker'][$_GET['worker']]);
	if($_SERVER['REQUEST_METHOD'] == 'POST')
	{
		unset($config['worker'][$_GET['worker']]);
		flatDB::saveEntry('config', 'config', $config);
		
		$out['content'] .= Plugin::redirectMsg($lang['worker_deleted'], 'config.php' . DS . 'worker', $lang['worker']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('delete.php' . DS . 'worker' . DS . $_GET['worker'],
		HTMLForm::simple_submit('delete'));
	}
}
/*
** ENLEVE LE BANISSEMENT D'UNE IP
*/
else if(Util::isGET('ban') && User::isAdmin())
{
	$out['subtitle'] = Util::lang('delete : %s', $_GET['ban']);    	
	if(!empty($_POST) && CSRF::check($token) )
	{
     $contenu_debut = file_get_contents(BAN_FILE);
     $contenu = str_replace($_GET['ban'] . "\n", '', $contenu_debut);
      
     $fichier = fopen(BAN_FILE, 'w');
     fwrite($fichier, $contenu);
     fclose($fichier);
     if ($contenu_debut == $contenu) 
          $msg = $lang['ip_not_banned'];
     else
          $msg = $lang['ip_removed'];
          
	 $out['content'] .= Plugin::redirectMsg($msg, 'config.php' . DS . 'ban', $lang['ban_list']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('delete.php' . DS . 'ban' . DS . $_GET['ban'],
			HTMLForm::simple_submit());
	}
}
else
{
	Util::redirect('index.php' . DS . '404');
}

require PATH_ROOT . DS . 'footer.php';

?>
