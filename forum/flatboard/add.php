<?php

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

$out['self'] = 'add';
require_once __DIR__ . '/header.php';
/**
 * AJOUTE UNE DISCUSSION
 **/
if(Util::isGETValidEntry('forum', 'topic'))
{
	$forumEntry = flatDB::readEntry('forum', $_GET['topic']);
	$out['subtitle'] = Util::lang('add topic : %s', $forumEntry['name']);
	if(HTMLForm::checkBot() && HTMLForm::check('trip', 0, 20) && HTMLForm::check('title', 5, 80) && HTMLForm::check('content', 1, 4000) && CSRF::check($token) )
	{
	    $topicEntry['ip'] = User::getRealIpAddr();
	    $topicEntry['role'] = $_SESSION['role'];		
		$topicEntry['title'] = HTMLForm::clean($_POST['title']);
		$topicEntry['content'] = HTMLForm::transNL(HTMLForm::clean($_POST['content']));
		$topicEntry['view'] = 0;
		$topicEntry['forum'] = $_GET['topic'];
		$topicEntry['reply'] = array();
		$topicEntry['locked'] = false;
		$topic = flatDB::newEntry();
		$topicEntry['trip'] = HTMLForm::trip(HTMLForm::clean(flatDB::removeAccents($_POST['trip'])), $topic);
		flatDB::saveEntry('topic', $topic, $topicEntry);

		$forumEntry['topic'][$topic] = $topic;
		flatDB::saveEntry('forum', $topicEntry['forum'], $forumEntry);

		$_SESSION[$topic] = $topic;	
		$out['content'] .= Plugin::redirectMsg($lang['topic_added'], 'view.php' . DS . 'topic' . DS . $topic, $topicEntry['title']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('add.php' . DS . 'topic' . DS . $_GET['topic'], '
			<div class="row gutters">
			    <div class="col col-8">
			        ' .HTMLForm::text('title', '', 'text', 'w100'). '
			    </div>
			    <div class="col col-4">
			        ' .HTMLForm::text('trip', '', 'text', 'w100', '', 'trip_desc'). '
			    </div>
			</div>'.
			HTMLForm::textarea('content', $lang['write_post'], 'w70', '', 10, 'write_post').
			HTMLForm::submit()).
		HTMLForm::preview('content');
	}
}
/**
 * AJOUTE UNE RÉPONSE
 **/
else if(Util::isGETValidEntry('topic', 'reply'))
{
	$topicEntry = flatDB::readEntry('topic', $_GET['reply']);
	if($topicEntry['locked'])
	{
		exit;
	}
	$out['subtitle'] = Util::lang('add reply : %s', $topicEntry['title']);
	
	# Protection anti brute force
	$maxlogin['counter'] = 3; # nombre de tentative de connexion autorisé dans la limite de temps autorisé
	$maxlogin['timer'] = 3 * 60; # temps d'attente limite si nombre de tentative de connexion atteint (en minutes)	

	# Initialisation variable erreur
	$error = '';
	$msg = '';

	if(isset($_SESSION['maxtry'])) {
		if( intval($_SESSION['maxtry']['counter']) >= $maxlogin['counter'] AND (time() < $_SESSION['maxtry']['timer'] + $maxlogin['timer']) ) 
		{
			# écriture dans les logs du dépassement des 3 tentatives successives de connexion
			@error_log('Flatboard: Max login failed. IP : '.User::getRealIpAddr());
			# message à affiche sur le mire de connexion
			$msg = sprintf($lang['error_maxlogin'], ($maxlogin['timer']/60));
			$out['content'] .= Plugin::redirectMsg($msg, 'index.php', $lang['home'], 'message error', FALSE);
			$error = true;
		}
		if( time() > ($_SESSION['maxtry']['timer'] + $maxlogin['timer']) ) {
			# on réinitialise le control brute force quand le temps d'attente limite est atteint
			$_SESSION['maxtry']['counter'] = 0;
			$_SESSION['maxtry']['timer'] = time();
		}
	} else {
		# initialisation de la variable qui compte les tentatives de connexion
		$_SESSION['maxtry']['counter'] = 0;
		$_SESSION['maxtry']['timer'] = time();
	}
	# on incremente la variable de session qui compte les tentatives de connexion		
	$_SESSION['maxtry']['counter']++;	
	
	$connected = false;	
		
	if(HTMLForm::checkBot() && HTMLForm::check('trip', 0, 20) && HTMLForm::check('content', 1, 4000) && CSRF::check($token) && $error=='' )
	{
	    $replyEntry['ip'] = User::getRealIpAddr();
	    $replyEntry['role'] = $_SESSION['role'];	
		$replyEntry['content'] = HTMLForm::transNL(HTMLForm::clean($_POST['content']));
		$replyEntry['topic'] = $_GET['reply'];
		$reply = flatDB::newEntry();
		$replyEntry['trip'] = HTMLForm::trip(HTMLForm::clean(flatDB::removeAccents($_POST['trip'])), $reply);
		flatDB::saveEntry('reply', $reply, $replyEntry);

		$topicEntry['reply'][$reply] = $reply;
		flatDB::saveEntry('topic', $replyEntry['topic'], $topicEntry);

		$_SESSION[$reply] = $reply;
		$connected = true;
	}
	if($connected) {
		unset($_SESSION['maxtry']);
		$out['content'] .= Plugin::redirectMsg($lang['reply_added'], 'view.php' . DS . 'topic' . DS . $_GET['reply']. DS. 'p' .DS. Util::onPage($reply, $topicEntry['reply']). '#' .$reply, $topicEntry['title']);
	} else {
		if($error) {
			$out['content'] .='';
		} else {	
			$out['content'] .= HTMLForm::form('add.php' . DS . 'reply' . DS . $_GET['reply'], 
				HTMLForm::text('trip', '', 'text', 'w30', '', 'trip_desc'). 
				HTMLForm::textarea('content', Util::isGETValidEntry('reply', 'q')? '[quote]' .$_GET['q']. '[/quote]' : $lang['write_post'], 'w70', '', 10, 'write_post').
				HTMLForm::submit('reply')).
			HTMLForm::preview('content');
		}
	}
}
/**
 * AJOUTE UN FORUM
 **/
else if(Util::isGET('forum') && User::isAdmin())
{
	$out['subtitle'] = Util::lang('add forum');
	if(HTMLForm::check('name') && HTMLForm::check('info', 1, 250) && HTMLForm::check('badge_color') && HTMLForm::check('font_icon') && CSRF::check($token) )
	{
		$forumEntry['name'] = HTMLForm::clean($_POST['name']);
		$forumEntry['info'] = HTMLForm::clean($_POST['info']);
		$forumEntry['font_icon'] = HTMLForm::clean($_POST['font_icon']);
		$forumEntry['badge_color'] = HTMLForm::clean($_POST['badge_color']);
		$forumEntry['topic'] = array();
		$forumEntry['pinnedTopic'] = array();
		#$forum = flatDB::newEntry();
		$forum = flatDB::slug($_POST['name']);
		flatDB::saveEntry('forum', $forum, $forumEntry);

		$forums = flatDB::readEntry('config', 'forumOrder');
		$forums[$forum] = $forum;
		
		flatDB::saveEntry('config', 'forumOrder', $forums);
		$out['content'] .= Plugin::redirectMsg($lang['forum_added'], 'index.php' . DS . 'forum', $lang['forum']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('add.php' . DS . 'forum',
			HTMLForm::text('name', '', 'text', 'w60').	
			HTMLForm::textarea('info', '', 'w60', '', 4). '
			<div class="row gutters">
			    <div class="col col-4">
			        ' .HTMLForm::text('font_icon', 'fa-folder', 'text', 'w100', 'font_icon_placeholder', 'font_icon_desc'). '
			    </div>
			    <div class="col col-4">
			        ' .HTMLForm::text('badge_color', 'tomato', 'color', 'w100', 'style_placeholder', 'badge_color_desc'). '
			    </div>
			</div>'.			
			HTMLForm::simple_submit('add'));
	}
}
/**
 * AJOUTE UN MODÉRATEUR
 **/
else if(Util::isGET('worker') && User::isAdmin())
{
	$out['subtitle'] = Util::lang('add worker');
	if(!empty($_POST) && HTMLForm::check('password') && CSRF::check($token) )
	{
		$config['worker'][HTMLForm::hide($_POST['password'])] = HTMLForm::clean($_POST['password']);
		flatDB::saveEntry('config', 'config', $config);
		$out['content'] .= Plugin::redirectMsg($lang['modo_added'], 'config.php' . DS . 'worker', $lang['worker']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('add.php' . DS . 'worker',
			HTMLForm::text('password').
			HTMLForm::simple_submit('add'));
	}
}
/**
 * SIGNALE UNE DISCUSSION/RÉPONSE
 **/
else if(Util::isGET('report'))
{
	$topic = $_GET['report'];
	if(flatDB::isValidEntry('topic', $topic))
		$topicEntry = flatDB::readEntry('topic', $topic);
	else
		$topicEntry = flatDB::readEntry('reply', $topic);	
		
	$out['subtitle'] = Util::lang('report : %s', $topicEntry['title']);
		
	if(HTMLForm::check('mail') && HTMLForm::check('description', 1, 250) && CSRF::check($token) )
	{		
		    $mail = HTMLForm::clean($_POST['mail']);
		    $description = '<h3>'.$topicEntry['title'].'</h3>';
		    $description .= '<p>Topic ID: '.$topic.' by '.$topicEntry['trip'].'</p>';
			$description .= '<p>Report raison: ' .HTMLForm::transNL(HTMLForm::clean($_POST['description'])).'</p>';
			$description .= '<p><a href="' .HTML_BASEPATH . DS . 'view.php' . DS . 'topic' . DS . $topic.'">' .$lang['click_to_view_post']. '</a></p>';
			$subject = $out['subtitle'];
			$destinataire = $config['mail'];
			
			$send_mail = Util::sendMail($config['title'], $mail, $destinataire, $subject, $description, 'html');				
			if ($send_mail)
				$out['content'] .=Plugin::redirectMsg($lang['email_sent'], 'index.php', $lang['new'], 'message success');
			else
				$out['content'] .=Plugin::redirectMsg($lang['email_nosent'], 'index.php', $lang['new'], 'message error');
	}
	else
	{
		$out['content'] .= HTMLForm::form('add.php' . DS . 'report' . DS . $_GET['report'],
				HTMLForm::text('mail', '', 'email', 'w50', 'your_email', 'report_desc').
				HTMLForm::textarea('description', '', 'w60', '', 4).
				HTMLForm::simple_submit('report'));
	}
}
/**
 * AJOUTE UNE IP À BANIR http://kb.site5.com/security/how-to-automatically-block-someone-using-a-php-script/
 * https://eksith.wordpress.com/2010/12/26/blocking-ips-from-file-list-php/
 **/
else if(Util::isGET('ban') && User::isAdmin())
{
    $ban = $_GET['ban'];
	$out['subtitle'] = Util::lang('ban_user : %s', $ban);
	
	if(HTMLForm::check('ban') && CSRF::check($token) )
	{
	      $user_ban = HTMLForm::clean($_POST['ban']);
          if ($user_ban != false && $user_ban != -1) {
               //Si l'IP est valide
               if (!User::is_ban(long2ip($user_ban))) {
                    $fichier = fopen(BAN_FILE, 'a') or die("can't open file"); //On ouvre en mode 'a'
                    fwrite($fichier, $user_ban . "\n"); //On ajoute la ligne avec l'IP
                    fclose($fichier); //On ferme le fichier    
                    $msg = $lang['ban_ok'];
               }
               else
                    $msg = $lang['ban_fail'];
          }
          $out['content'] .= Plugin::redirectMsg($msg, 'config.php' . DS . 'ban', $lang['ban_list']);
	}
	else
	{
		$out['content'] .= HTMLForm::form('add.php' . DS . 'ban' . DS . $_GET['ban'],
		    HTMLForm::text('ban', $ban).
			HTMLForm::simple_submit());
	}

}

else
{
	Util::redirect('index.php' . DS . '404');
}

require PATH_ROOT . DS . 'footer.php';

?>
