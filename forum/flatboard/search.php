<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'search';
require_once __DIR__ . '/header.php';

$cur = 'search'; # Indicateur de page
$out['subtitle'] = $lang['search'];

if(HTMLForm::checkBot() && HTMLForm::check('topic') && CSRF::check($token) )
{
	$wordSearch = HTMLForm::clean($_POST['topic']);
	$foundTopics = array();
	foreach(flatDB::listEntry('topic') as $topic)
	{
		// Load datas
		$topicEntry = flatDB::readEntry('topic', $topic);
		$forumEntry = flatDB::readEntry('forum', $topicEntry['forum']);
		if(mb_stripos($topicEntry['title'], $wordSearch) !== false || mb_stripos($topicEntry['content'], $wordSearch) !== false)
		{
			$foundTopics[$topic] = $topicEntry['title'];
		}
	}
	$out['content'] .= '<div class="row">
    <div class="col col-12">';
	if($foundTopics)
	{
		$out['content'] .= '<h6>' .$lang['search_term_found']. '</h6><hr />
    	<ol>';				
		foreach($foundTopics as $topic => $title)
		{
			$out['content'] .= '<li>' .entryLink::manageTopic($topic). '
				<a href="view.php' . DS . 'topic' . DS . $topic. '">
					' .Parser::title($title). '
				</a>
			</li>';
		}
		$out['content'] .= '</ol>';
	}
	else
	{
		$out['content'] .= '<div class="message focus" data-component="message">' .$lang['none']. '<span class="close small"></span></div>';
	}
	$out['content'] .= '
	</div>
</div>';





}

$out['content'] .= HTMLForm::form('search.php',
	HTMLForm::text('topic', '', 'search', 'w50').
	HTMLForm::submit('search'));

require PATH_ROOT . DS . 'footer.php';

?>
