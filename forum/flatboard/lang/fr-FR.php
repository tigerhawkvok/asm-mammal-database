<?php
/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 *
 * All Flatboard code is released under the MIT license.
 * See COPYRIGHT.txt and LICENSE.txt.
*/
# On défini le fuseau horaire
setlocale (LC_TIME, 'fr_FR','fra');
# Définit le décalage horaire par défaut de toutes les fonctions date/heure  
date_default_timezone_set("Europe/Paris");
# Definit l'encodage interne
mb_internal_encoding("UTF-8");

$lang['fr-FR']             = 'Français';
$lang['en-US']             = 'Anglais';
$lang['ru-RU']             = 'Russe';

$lang['in']               = ' <i class="fa fa-clock-o"></i>';
/************* install.php ***************/
$lang['php_version']      = 'Vous devez disposer d’un serveur équipé de <b>PHP 5.2</b> ou plus pour installer <b>Flatboard</b> !';
$lang['flatBoard_installer'] = 'Installation de FlatBoard';
$lang['welcome_installer'] = 'Bienvenue dans l’assistant d’installation de Flatboard';
$lang['site_title'] = 'Votre titre du site';
$lang['site_slogan'] = 'Slogan / Description du site';
$lang['your_admin_psw'] = 'Mot de passe pour votre compte administrateur';
$lang['site_mail'] = 'Adresse de couriel pour votre compte administrateur';
$lang['install'] = 'Installer';
$lang['installed_title'] = '<i class="fa fa-bullhorn"></i> Génial, Flatboard est désormais installé !';
$lang['installed_msg'] = 'Maintenant, créez des forums et commencez à discuter avec le monde ! Besoin d’aide ? Veuillez lire la <a href="http://flatboard.free.fr/view.php/plugin/page/p/docs">documentation</a>.';

/************* config.php ***************/
$lang['homepage']         = 'Page d’accueil';
$lang['footer_text'] = 'Texte en pied de page';
$lang['announcement'] = 'Annonce';
$lang['announcement_desc'] = 'Laisser vide pour ne pas afficher d’annonce (code HTML autorisé).';
$lang['ItemByPage'] 	  = 'Nombre de discussions/Réponses par page';
$lang['date_format']      = 'Format de la date';
$lang['date_format_placeholder'] = 'd M Y à H:i';
$lang['maintenance']      = 'Maintenance';
$lang['maintenance_desc'] = 'Site en maintenance, merci de revenir plus tard.';
$lang['ban_list']         = 'Liste d’IP bannies';
$lang['ban_ok']           = 'Cette adresse est désormais non-autorisée.';
$lang['ban_fail']         = 'Cette adresse est déjà bannie.';
$lang['notifications_center'] = 'Centre de Notifications';
$lang['add_worker'] = 'Ajouter un modérateur';
$lang['save'] = 'Enregistrer';
$lang['update'] = 'Mis à jour le ';
$lang['theme'] = 'Thème';
$lang['theme_desc'] = '<a href="config.php/deletecache" class="label error outline">Supprimer le cache</a>';
$lang['cache_clean'] = 'Cache vidé';
$lang['folder_deleted'] = 'Dossier supprimé avec succès';
$lang['folder_error'] = 'Erreur pendant la suppression du dossier';
$lang['lang'] = 'Language';
$lang['editor'] = 'Editor';
$lang['bbcode'] = 'BBcode';
$lang['markdown'] = 'Markdown';
$lang['editor_desc'] = 'BBcode or markdown format';
$lang['style'] = 'Style';
$lang['style_placeholder'] = 'slateblue, #000000…';
$lang['style_desc'] = 'Permet de personnaliser la couleur du bandeau de navigation.';
$lang['nb_page_scroll_infinite'] = 'Combien de pages à scroller automatiquement';
$lang['nb_page_scroll_desc'] = 'Mettre 1 pour désactiver le scroll automatique.';
$lang['salt'] = 'Clé de sécurité';
$lang['salt_desc'] = 'Laissez vide pour générer une clé automatiquement';

/************* Message système config ***************/
$lang['warning_installation_file'] = 'Le fichier install.php est présent à la racine de Flatboard.<br />Pour des raisons de sécurité, il est fortement conseillé de le <a class="button secondary outline small" role="button" href="config.php/delinstallfile" title="Supprimer maintenant ?">supprimer</a>.';
$lang['update_version_%1$s'] = '<a href="http://flatboard.free.fr/download.php">FlatBoard %1$s</a> est disponible. Télécharger l’archive et l’installer manuellement.';
$lang['no_update'] = 'Vous avez la dernière version de Flatboard.';
$lang['update_error'] = 'La vérification de mise à jour a échoué pour une raison inconnue.';
$lang['allow_url_fopen'] = 'Impossible de vérifier les mises à jour tant que \'allow_url_fopen\' est désactivé sur ce système';
$lang['change_defaut_password'] = 'Vous utilisez actuellement le mot de passe fourni par défaut, <a href="auth.php/password">nous vous recommandons de le changer</a> par un plus complexe.';

/************* add.php ***************/
$lang['topic_added'] = 'Discussion ajoutée !';
$lang['reply_added'] = 'Réponse ajoutée !';
$lang['forum_added'] = 'Forum ajouté avec succès !';
$lang['write_post'] = 'Écrivez un message ...';
$lang['modo_added'] = 'Nouveau modérateur ajouté !';

$lang['trip_desc'] = 'Il n’est pas nécessaire de “s’inscrire”, il suffit d’insérer le même Nom<span style="color:red">#</span>MotDePasse de votre choix à chaque fois, pour avoir votre propre identité. Ou de laisser le champ vide pour une publication anonyme. Votre mot de passe sera affiché en crypté et haché aux visiteurs pour des raisons de sécurité !';

$lang['trip'] = 'Pseudo ';

$lang['badge_color'] = 'Couleur du badge';
$lang['badge_color_desc'] = 'Insérez une couleur hexadécimale ou son nom';
$lang['font_icon'] = 'Icône catégorie';
$lang['font_icon_placeholder'] = 'fa-folder';
$lang['font_icon_desc'] = 'Allez sur le site <a href="http://fontawesome.io/icons/">Font Awesome</a> pour choisir une icône';
$lang['email_sent'] = 'E-mail envoyé avec succès.';
$lang['email_nosent'] = 'Une erreur est survenue, l’email n’a pu être envoyé.';
$lang['report_desc'] = 'Veuillez noter : les modérateurs seront avertis avec un lien vers la page que vous signalez.<br />Ce formulaire est UNIQUEMENT pour signaler du contenu répréhensible et ne doit pas être utilisé comme moyen de communication avec les modérateurs pour toute autre raison.';
$lang['your_email'] = 'Votre mail au cas où...';
$lang['click_to_view_post'] = 'Cliquez ici pour voir le message';
$lang['order'] = 'Ordre';

/************* delete.php ***************/
$lang['topic_deleted'] = 'Discussion supprimée !';
$lang['reply_deleted'] = 'Réponse supprimée !';
$lang['forum_deleted'] = 'Forum supprimé !';
$lang['worker_deleted'] = 'Modérateur supprimé !';
$lang['ip_not_banned'] = 'Cette adresse IP n’était pas bannie.';
$lang['ip_removed'] = 'L’adresse IP a été retirée.';

/************* edit.php ***************/
$lang['topic_edited'] = 'Discussion éditée !';
$lang['reply_edited'] = 'Réponse éditée !';
$lang['forum_edited'] = 'Forum édité !';
$lang['pinned_homepage'] = 'Épinglé en page d’accueil';

$lang['useSpace'] = true;
$lang['home']        = 'Accueil';
$lang['thread_sug']  = 'Suggestion de sujet';
$lang['change_pwd']  = 'Modifier mon mot de passe';
$lang['topic'] = 'Sujet';
$lang['newthread'] = 'Démarrer une discussion';
$lang['reply'] = 'Réponse';
$lang['newreply'] = 'Répondre à cette discussion';
$lang['quote_reply'] = 'Répondre en citant';
$lang['quote_by'] = 'Cité par';
$lang['add_forum']   = 'Ajouter un Forum';
$lang['plugin'] = 'Plugin';
$lang['config'] = 'Configuration ';
$lang['logout'] = 'Déconnexion';
$lang['login'] = 'Connexion';
$lang['redirect'] = 'Redirection vers';
$lang['add'] = 'Ajouter ';
$lang['edit'] = 'Éditer ';
$lang['delete'] = 'Supprimer ';
$lang['title'] = 'Titre';
$lang['content'] = 'Message';
$lang['name'] = 'Nom';
$lang['mail'] = 'Email';
$lang['search'] = 'Rechercher';
$lang['forum'] = 'Forums';
$lang['password'] = 'Mot de Passe';
$lang['confirm_password'] = 'confirmer';
$lang['powered'] = 'Créé avec <a href="http://flatboard.free.fr" onclick="window.open(this.href); return false;">Flatboard</a> et <i class="fa fa-heart"></i>.';
$lang['feed'] = 'Flux';
$lang['none'] = 'Aucune donnée actuellement';
$lang['info'] = 'Information';
$lang['date'] = 'Date';
$lang['view'] = 'Vue';
$lang['count'] = 'Message';
$lang['new'] = 'Derniers Messages ';
$lang['more'] = 'Lire la suite';
$lang['submit'] = 'Valider';
$lang['admin'] = 'Administrateur';
$lang['worker'] = 'Modérateur';
$lang['sort_forums'] = 'Trier les forums';
$lang['yes'] = 'Oui';
$lang['no'] = 'Non';
$lang['locked'] = 'Fermé';
$lang['no_reply'] = 'Vous ne pouvez pas répondre';
$lang['locked_discussion'] = 'a verrouillé la discussion.';
$lang['report'] = 'Signaler';
$lang['day'] = 'jour';
$lang['hour'] = 'heure';
$lang['minute'] = 'minute';
$lang['second'] = 'seconde';
$lang['plural'] = 's';
$lang['ago'] = 'plus tôt.';
$lang['errLen'] = ' est trop court ou trop long';
$lang['errBot'] = 'Code Anti Spam incorrect!';
$lang['errNb'] = 'Le nombre doit être entier et positif.';
$lang['pinned'] = 'Épinglé';
$lang['stickied_discussion'] = 'a épinglé la discussion.';
$lang['replied']     = '<i class="fa fa-share-square"></i> a répondu ';
$lang['started']     = '<i class="fa fa-bolt"></i> a débuté ';
$lang['notFound'] = 'Oops ! Cette page n’existe plus :(';
$lang['errNotMatch'] = 'Les Mots de Passe ne correspondent pas';
$lang['captcha']     = 'Code de sécurité';
$lang['enter_code'] = 'Insérez le code';
$lang['r_captcha']   = 'Recharger l’image';
$lang['quickNav'] = 'Navigation rapide';
$lang['invalid_token'] = 'Mauvais hachage CSRF !';
$lang['mail_available'] = 'Fonction d’envoi de mail disponible';
$lang['mail_not_available'] = 'Fonction d’envoi de mail non disponible';

/************* view.php ***************/
$lang['permalink'] = 'Lien permanent';
$lang['solved'] = 'résolu';
$lang['original_message'] = 'DISCUSSION D’ORIGINE';

/************* search.php ***************/
$lang['search_term_found'] = 'Terme recherché trouvé.';

/************* Plugin ***************/
$lang['state']        = '<strong>Statut actuel du plugin</strong><br />Sélectionner une option dans la liste pour modifier ce statut puis valider le changement.';
$lang['state_on']     = 'Activé';
$lang['state_off']    = 'Désactivé';
$lang['data_save']    = 'Données sauvegardées !';
$lang['description']  = 'Description';
$lang['author']       = 'Auteur';
$lang['check_all']    = 'Tout cocher';
$lang['plugin_help']  = '<i class="fa fa-warning"></i> Aide';
$lang['manage_plugin']= 'Gestionnaire de plugin';

/************* auth.php ***************/
$lang['password_changed'] = 'Votre mot de passe a bien été modifié!';
$lang['edit_password'] = 'Modification du mot de passe';
$lang['login_confirm'] = 'Vous êtes connecté !';
$lang['logout_confirm'] = 'Vous êtes désormais déconnecté !';
$lang['incorrect_password'] = 'Mot de passe incorrect.';
$lang['error_maxlogin'] = 'Nombre de tentative atteinte. Réessayez dans %s minutes.';

/************* services.php ***************/
$lang['ban_user'] = 'Bannir cette IP';
$lang['unban_user'] = 'Débannir cette IP';
$lang['banned'] = 'Vous avez été banni !';
$lang['your_banned'] = 'Vous avez été banni définitivement de ce forum.<br />Contactez l’Administrateur du forum pour plus d’informations.<br />Raison du bannissement: dans le cadre de notre politique active contre le spam<br />Votre ip: ';
$lang['has_banned'] = ' a été bannie !';
$lang['ban'] = 'IP/plages d’adresses IP';
?>