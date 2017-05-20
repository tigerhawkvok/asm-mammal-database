<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'edit';
require_once __DIR__ . '/header.php';
/**
 * ÉDITION D’UNE DISCUSSION
 **/
if(Util::isGETValidEntry('topic', 'topic') && (User::isWorker() || User::isAuthor($_GET['topic'])))
{
	$topicEntry = flatDB::readEntry('topic', $_GET['topic']);
	$out['subtitle'] = Util::lang('edit topic : %s', $topicEntry['title']);
	if(HTMLForm::checkBot() && HTMLForm::check('title', 5, 80) && HTMLForm::check('content', 1, 4000) && CSRF::check($token) )
	{
		$topicEntry['title'] = HTMLForm::clean($_POST['title']);
		$topicEntry['content'] = HTMLForm::transNL(HTMLForm::clean($_POST['content']));
		if(User::isWorker() &&
			Util::isPOST('locked') && ($_POST['locked'] === 'yes' || $_POST['locked'] === 'no') &&
			Util::isPOST('pinned') && ($_POST['pinned'] === 'yes' || $_POST['pinned'] === 'no') &&
			Util::isPOST('forum') && flatDB::isValidEntry('forum', $_POST['forum']))
		{
			$topicEntry['locked'] = $_POST['locked'] === 'yes';

			if($topicEntry['forum'] !== $_POST['forum'])
			{
				$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
				unset($forumEntry['topic'][$_GET['topic']]);
				unset($forumEntry['pinnedTopic'][$_GET['topic']]);
				flatDB::saveEntry('forum', $topicEntry['forum'], $forumEntry);

				$topicEntry['forum'] = $_POST['forum'];
				$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
				$forumEntry['topic'][$_GET['topic']] = $_GET['topic'];
				flatDB::saveEntry('forum', $topicEntry['forum'], $forumEntry);
			}

			$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
			if($_POST['pinned'] === 'yes')
			{
				$forumEntry['pinnedTopic'][$_GET['topic']] = $_GET['topic'];
			}
			else
			{
				unset($forumEntry['pinnedTopic'][$_GET['topic']]);
			}
			flatDB::saveEntry('forum', $topicEntry['forum'], $forumEntry);
		}
		flatDB::saveEntry('topic', $_GET['topic'], $topicEntry);
		$out['content'] .= Plugin::redirectMsg($lang['topic_edited'], 'view.php' . DS . 'topic' . DS . $_GET['topic'], $topicEntry['title']);
	}
	else
	{
		$forums = flatDB::listEntry('forum');
		asort($forums);
		foreach($forums as $forum)
		{
			$forumEntry = flatDB::readEntry('forum', $forum);
			$forumOptions[$forum] = $forumEntry['name'];
		}
		$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
		$out['content'] .= HTMLForm::form('edit.php' . DS . 'topic' . DS . $_GET['topic'],
			HTMLForm::text('title', $topicEntry['title']).
			HTMLForm::textarea('content', $topicEntry['content']).
			(User::isWorker()? '
			    <div class="row gutters">
			        <div class="col col-2">
			            ' .HTMLForm::select('locked', array('yes' => $lang['yes'], 'no' => $lang['no']), $topicEntry['locked']? 'yes' : 'no'). '
			        </div>
			        <div class="col col-2">
			            ' .HTMLForm::select('pinned', array('yes' => $lang['yes'], 'no' => $lang['no']), isset($forumEntry['pinnedTopic'][$_GET['topic']])? 'yes' : 'no'). '
			        </div>
			        <div class="col col-4">
			            ' .HTMLForm::select('forum', $forumOptions, $topicEntry['forum']) : ''). '
			        </div>
			    </div>'.			
			HTMLForm::submit()).
		HTMLForm::preview('content');
	}
}
/**
 * ÉDITION D’UNE RÉPONSE
 **/
else if(Util::isGETValidEntry('reply', 'reply') && (User::isWorker() || User::isAuthor($_GET['reply'])))
{
	$replyEntry = flatDB::readEntry('reply', $_GET['reply']);
	$out['subtitle'] = Util::lang('edit reply');
	if(HTMLForm::checkBot() && HTMLForm::check('content', 1, 4000) && CSRF::check($token) )
	{
		$replyEntry['content'] = HTMLForm::transNL(HTMLForm::clean($_POST['content']));
		flatDB::saveEntry('reply', $_GET['reply'], $replyEntry);
		$topicEntry = flatDB::readEntry('topic', $replyEntry['topic']);
		$out['content'] .= Plugin::redirectMsg($lang['reply_edited'], 'view.php' . DS . 'topic' . DS . $replyEntry['topic']. DS. 'p'. DS. Util::onPage($_GET['reply'], $topicEntry['reply']). '#' .$_GET['reply'], $topicEntry['title']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('edit.php' . DS . 'reply' . DS . $_GET['reply'],
			HTMLForm::textarea('content', $replyEntry['content']).
			HTMLForm::submit()).
		HTMLForm::preview('content');
	}
}
/**
 * ÉDITION D’UN FORUM
 **/
else if(Util::isGETValidEntry('forum', 'forum') && User::isAdmin())
{
	$forumEntry = flatDB::readEntry('forum', $_GET['forum']);
	$out['subtitle'] = Util::lang('edit forum : %s', $forumEntry['name']);
	if(HTMLForm::checkBot() && HTMLForm::check('info', 1, 250) && HTMLForm::check('badge_color') && HTMLForm::check('font_icon') && CSRF::check($token) )
	{
		$forumEntry['info'] = HTMLForm::clean($_POST['info']);
		$forumEntry['font_icon'] = HTMLForm::clean($_POST['font_icon']);
		$forumEntry['badge_color'] = HTMLForm::clean($_POST['badge_color']);
		flatDB::saveEntry('forum', $_GET['forum'], $forumEntry);
		$out['content'] .= Plugin::redirectMsg($lang['forum_edited'], 'index.php' . DS . 'forum', $lang['forum']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('edit.php' . DS . 'forum' . DS . $_GET['forum'],			
			HTMLForm::textarea('info', $forumEntry['info'], 'w60', '', 4). '
			<div class="row gutters">
			    <div class="col col-4">
			        ' .HTMLForm::text('font_icon', $forumEntry['font_icon'], 'text', 'w100', 'font_icon_placeholder', 'font_icon_desc'). '
			    </div>
			    <div class="col col-4">
			        ' .HTMLForm::text('badge_color', $forumEntry['badge_color'], 'color', 'w100', 'style_placeholder', 'badge_color_desc'). '
			    </div>
			</div>'.	
			HTMLForm::submit());
	}
}
else
{
	Util::redirect('index.php' . DS . '404');
}

require PATH_ROOT . DS . 'footer.php';

?>
