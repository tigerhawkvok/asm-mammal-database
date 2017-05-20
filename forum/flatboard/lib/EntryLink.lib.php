<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/
class entryLink
{
    /**
     * Protected constructor since this is a static class.
     *
     * @access  protected
     */
    protected function __construct()
    {
        // Nothing here
    }	
	# Généralisation du lien avec paramètres
	public static function createLink($hint, $link, $lang_hint, $icon)
	{
	    global $lang;
		return '<a class="hint--top ' .$hint. ' hint--rounded" href="' .$link. '" data-hint="' .$lang[$lang_hint]. '"><i class="' .$icon. '"></i></a>&nbsp;';
	}
	# ÉDITION/SUPPRESSION D’UNE DISCUSSSION
	public static function manageTopic($topic)
	{
		return (User::isWorker() || User::isAuthor($topic)? 
			entryLink::createLink('hint--success', 'edit.php' . DS . 'topic' . DS . $topic, 'edit', 'fa fa-edit').
			entryLink::createLink('hint--error', 'delete.php' . DS . 'topic' . DS . $topic, 'delete', 'fa fa-trash-o') : '').
			Plugin::hook('manageTopic', $topic);
	}
	# ÉDITION/SUPPRESSION D’UNE RÉPONSE	
	public static function manageReply($reply)
	{
		return (User::isWorker() || User::isAuthor($reply)? 
			entryLink::createLink('hint--success', 'edit.php' . DS . 'reply' . DS . $reply, 'edit', 'fa fa-edit').
			entryLink::createLink('hint--error', 'delete.php' . DS . 'reply' . DS . $reply, 'delete', 'fa fa-trash-o') : '').
			Plugin::hook('manageReply', $reply);
	}
	# ÉDITION/SUPPRESSION D’UN FORUM
	public static function manageForum($forum)
	{
		return (User::isAdmin()? 
			entryLink::createLink('hint--success', 'edit.php' . DS . 'forum' . DS . $forum, 'edit', 'fa fa-edit').
			entryLink::createLink('hint--error', 'delete.php' . DS . 'forum' . DS . $forum, 'delete', 'fa fa-trash-o') : '').
			Plugin::hook('manageForum', $forum);
	}
	# ÉDITION D’UN PLUGIN
	public static function managePlugin($plugin)
	{
		return (User::isAdmin()? 
			entryLink::createLink('hint--success', 'config.php' . DS . 'plugin' . DS . $plugin, 'edit', 'fa fa-edit') : '').
			Plugin::hook('managePlugin', $plugin);
	}	
	# AJOUT/SUPPRESSION D’UNE IP
	public static function userBan($user)
	{
		return (User::isAdmin()? 
			entryLink::createLink('hint--error', 'add.php' . DS . 'ban' . DS . $user, 'ban_user', 'fa fa-ban').
			entryLink::createLink('hint--success', 'delete.php' . DS . 'ban' . DS . $user, 'unban_user', 'fa fa-circle-o') : '').
			Plugin::hook('userBan', $user);
	}

}