<?php
/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 *
 * All Flatboard code is released under the MIT license.
 * See COPYRIGHT.txt and LICENSE.txt.
*/
# SetLocal
setlocale(LC_ALL, "en_US");
# Définit le décalage horaire par défaut de toutes les fonctions date/heure  
date_default_timezone_set("Europe/London");
# Definit l'encodage interne
mb_internal_encoding("ISO-8859-1");

$lang['fr-FR']             = 'French';
$lang['en-US']             = 'English';
$lang['ru-RU']             = 'Russian';

$lang['in']  = ' <i class="fa fa-clock-o"></i>';
/************* install.php ***************/
$lang['php_version'] = 'You must have a server with <b>PHP 5.2</b> or later to install <b>Flatboard</b>!';
$lang['flatBoard_installer'] = 'FlatBoard Installer';
$lang['welcome_installer'] = 'Welcome to the Flatboard installer';
$lang['site_title'] = 'Your site title';
$lang['site_slogan'] = 'Subtitle / Site description';
$lang['your_admin_psw'] = 'Your admin password account here';
$lang['site_mail'] = 'Your admin mail account here';
$lang['install'] = 'Install';
$lang['installed_title'] = '<i class="fa fa-bullhorn"></i> Yeah! Flatboard is now installed';
$lang['installed_msg'] = 'Now, create forums and start discussing with the world! Need help? Please <a href="http://flatboard.free.fr/view.php/plugin/page/p/docs">read the DOC</a>.';

/************* config.php ***************/
$lang['homepage'] = 'Home Page';
$lang['footer_text'] = 'Footer text';
$lang['announcement'] = 'Announcement';
$lang['announcement_desc'] = 'Leave blank to not display announcement (HTML allowed).';
$lang['ItemByPage'] = 'Item by page';
$lang['date_format'] = 'Date Format';
$lang['date_format_placeholder'] = 'Y/m/d H:i';
$lang['maintenance'] = 'Maintenance';
$lang['maintenance_desc'] = ' Forums are down for maintenance. Please check back shortly. :)';
$lang['ban_list'] = 'Ban List';
$lang['ban_ok']  = 'This IP address is now unauthorized.';
$lang['ban_fail'] = 'This IP address is already banned.';
$lang['notifications_center'] = 'Notifications Center';
$lang['add_worker'] = 'Add a moderator';
$lang['save'] = 'Save';
$lang['update'] = 'Update ';
$lang['theme'] = 'Theme';
$lang['theme_desc'] = '<a href="config.php/deletecache" class="label error outline">Delete cache</a>';
$lang['cache_clean'] = 'Cache Cleaned';
$lang['folder_deleted'] = 'Folder sucessfully deleted';
$lang['folder_error'] = 'Error during the folder deletion';
$lang['lang'] = 'Language';
$lang['editor'] = 'Editor';
$lang['bbcode'] = 'BBcode';
$lang['markdown'] = 'Markdown';
$lang['editor_desc'] = 'BBcode or markdown format';
$lang['style'] = 'Style';
$lang['style_placeholder'] = 'slateblue, #000000…';
$lang['style_desc'] = 'Allows you to customize the color of the navigation bar.';
$lang['nb_page_scroll_infinite'] = 'How many pages to scroll automatically';
$lang['nb_page_scroll_desc'] = 'Set to 1 to disable automatic scrolling.';
$lang['salt'] = 'Key security';
$lang['salt_desc'] = 'Leave blank to generate a key';

/************* Msg System ***************/
$lang['warning_installation_file'] = 'install.php file can still be found at your Flatboard root.<br />For security reasons, it is strongly recommended to <a class="button secondary outline small" role="button" href="config.php/delinstallfile" title="delete now?">delete it</a>.';
$lang['update_version_%1$s'] = 'You can update to <a href="http://flatboard.free.fr/download.php">FlatBoard %1$s</a>. Download the package and install it manually.';
$lang['no_update'] = 'Flatboard is already up to date.';
$lang['update_error'] = 'Update check failed for an unknown reason.';
$lang['allow_url_fopen'] = 'Can\'t check for updates as long as \'allow_url_fopen\' is disabled on this system';
$lang['change_defaut_password'] = 'You use at present the password supplied by default, <a href="auth.php/password">we recommend you to change it</a> by more difficult one.';

/************* add.php ***************/
$lang['topic_added'] = 'Topic added!';
$lang['reply_added'] = 'Reply added!';
$lang['forum_added'] = 'Forum added!';
$lang['write_post'] = 'Write a Post...';
$lang['modo_added'] = 'New moderator added!';

$lang['trip_desc'] = 'There is no need to “register”, just enter the same name<span style="color:red">#</span>password of your choice every time, or leave blank for anonymous post. Your password will be displayed encrypted and hashed to visitors for security reasons!';

$lang['trip'] = 'Pseudo ';

$lang['badge_color'] = 'Badge color';
$lang['badge_color_desc'] = 'Enter a hexadecimal color.';
$lang['font_icon'] = 'Icon category';
$lang['font_icon_placeholder'] = 'fa-folder';
$lang['font_icon_desc'] = 'Go to <a href="http://fontawesome.io/icons/">Font Awesome</a> website for choose a icon';
$lang['email_sent'] = 'Email sent successfully';
$lang['email_nosent'] = 'Could not send email';
$lang['report_desc'] = 'Note: The moderator will be made aware link to the page you are reporting.<br />This form is ONLY for reporting objectionable content and should not be used as a means of communicating with moderators for other reasons.';
$lang['your_email'] = 'Your email address just in case';
$lang['click_to_view_post'] = 'Click here to view the post';
$lang['order'] = 'Order';

/************* delete.php ***************/
$lang['topic_deleted'] = 'Topic deleted!';
$lang['reply_deleted'] = 'Reply deleted!';
$lang['forum_deleted'] = 'Forum deleted!';
$lang['worker_deleted'] = 'Moderator deleted!';
$lang['ip_not_banned'] = 'This IP address was not banned.';
$lang['ip_removed'] = 'The IP address has been removed.';

/************* edit.php ***************/
$lang['topic_edited'] = 'Topic edited!';
$lang['reply_edited'] = 'Reply edited!';
$lang['forum_edited'] = 'Forum edited!';
$lang['pinned_homepage'] = 'Pinned in home';

$lang['useSpace'] = true;
$lang['home'] = 'Home';
$lang['thread_sug']  = 'Thread Suggest';
$lang['change_pwd']  = 'Change my password';
$lang['topic'] = 'Topic';
$lang['newthread'] = 'Start a Discussion';
$lang['reply'] = 'Reply';
$lang['newreply'] = 'New reply';
$lang['quote_reply'] = 'Reply in quote';
$lang['quote_by'] = 'Quote by';
$lang['add_forum']   = 'Add Forum';
$lang['plugin'] = 'Plugin';
$lang['config'] = 'Config';
$lang['logout'] = 'Logout';
$lang['login'] = 'Login';
$lang['redirect'] = 'Go back to';
$lang['add'] = 'Add';
$lang['edit'] = 'Edit';
$lang['delete'] = 'Delete';
$lang['title'] = 'Title';
$lang['content'] = 'Content';
$lang['name'] = 'Name';
$lang['mail'] = 'Email';
$lang['search'] = 'Search';
$lang['forum'] = 'Forum';
$lang['password'] = 'Password';
$lang['confirm_password'] = 'confirm password';
$lang['powered'] = 'Created with <a href="http://flatboard.free.fr" onclick="window.open(this.href); return false;">Flatboard</a> and <i class="fa fa-heart"></i>.';
$lang['feed'] = 'Feed';
$lang['none'] = 'No entry so far';
$lang['info'] = 'Information';
$lang['date'] = 'Date';
$lang['view'] = 'View';
$lang['count'] = 'Post';
$lang['new'] = 'New';
$lang['more'] = 'More';
$lang['submit'] = 'Submit';
$lang['admin'] = 'Administrator';
$lang['worker'] = 'Moderator';
$lang['sort_forums'] = 'Sort forums';
$lang['yes'] = 'Yes';
$lang['no'] = 'No';
$lang['locked'] = 'Locked';
$lang['no_reply'] = 'Can\'t Reply';
$lang['locked_discussion'] = 'locked the discussion.';
$lang['report'] = 'Report';
$lang['day'] = 'day';
$lang['hour'] = 'hour';
$lang['minute'] = 'minute';
$lang['second'] = 'second';
$lang['plural'] = 's';
$lang['ago'] = 'ago';
$lang['errLen'] = 'Too short / long';
$lang['errBot'] = 'Incorrect CAPTCHA';
$lang['errNb'] = 'This is not a positive whole number';
$lang['pinned'] = 'Pinned';
$lang['stickied_discussion'] = 'stickied the discussion.';
$lang['replied'] = '<i class="fa fa-share-square"></i> replied ';
$lang['started'] = '<i class="fa fa-bolt"></i> started ';
$lang['notFound'] = 'Oops! The page does not exist :(';
$lang['errNotMatch'] = 'Mismatched password';
$lang['captcha'] = 'Captcha';
$lang['enter_code'] = 'Enter security code';
$lang['r_captcha']   = 'Reload picture';
$lang['quickNav'] = 'Quick Navigation';
$lang['invalid_token'] = 'Invalid token!';
$lang['mail_available'] = 'Mail sending function available';
$lang['mail_not_available'] = 'Mail sending function unavailable';

/************* view.php ***************/
$lang['permalink'] = 'Permalink';
$lang['solved'] = 'solved';
$lang['original_message'] = 'DISCUSSION OF ORIGIN';

/************* search.php ***************/
$lang['search_term_found'] = 'Search term found.';

/************* Plugin ***************/
$lang['state']        = 'On/Off plugin';
$lang['state_on']     = 'On';
$lang['state_off']    = 'Off';
$lang['data_save']    = 'Datas Save !';
$lang['description']  = 'Description';
$lang['author']       = 'Author';
$lang['check_all']    = 'Check All';
$lang['plugin_help']    = '<i class="fa fa-warning"></i> Help';
$lang['manage_plugin']    = 'Manage plugin';

/************* auth.php ***************/
$lang['password_changed'] = 'Your password was modified successfully!';
$lang['edit_password'] = 'Change your password';
$lang['login_confirm'] = 'You are now login!';
$lang['logout_confirm'] = 'You are now logout!';
$lang['incorrect_password'] = 'Incorrect password.';
$lang['error_maxlogin'] = 'Too many failed login. Retry in % s minutes.';

/************* services.php ***************/
$lang['ban_user'] = 'Ban this IP';
$lang['unban_user'] = 'Unban this IP';
$lang['banned'] = 'You have been banned!';
$lang['your_banned'] = 'You have been permanently banned from this forum.<br />Contact the administrator of the forum for more info.<br />Reason for ban: as part of our policy active against spam,<br />your ip: ';
$lang['has_banned'] = ' has been banned!';
$lang['ban'] = 'IP address / IP address ranges';
?>