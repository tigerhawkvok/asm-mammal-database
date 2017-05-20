<?php
/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 *
 * All Flatboard code is released under the MIT license.
 * See COPYRIGHT.txt and LICENSE.txt.
*/
/****** Russian Translation http://avcore.ru ******/
# SetLocal
setlocale(LC_ALL, "en_US");
# Définit le décalage horaire par défaut de toutes les fonctions date/heure  
date_default_timezone_set("Europe/London");
# Definit l'encodage interne
mb_internal_encoding("ISO-8859-1");

$lang['en-US']             = 'English';
$lang['fr-FR']             = 'French';
$lang['ru-RU']             = 'Russian';


$lang['in']  = ' <i class="fa fa-clock-o"></i>';
/************* install.php ***************/
$lang['php_version'] = 'Для установки <b>Flatboard</b> требуется <b>PHP 5.2</b> и выше!';
$lang['flatBoard_installer'] = 'Установка FlatBoard';
$lang['welcome_installer'] = 'Добро пожаловать!';
$lang['site_title'] = 'Название сайта';
$lang['site_slogan'] = 'Описание сайта';
$lang['your_admin_psw'] = 'Пароль администратора';
$lang['site_mail'] = 'Ваша учетная запись администратора здесь';
$lang['install'] = 'Установка';
$lang['installed_title'] = '<i class="fa fa-bullhorn"></i> Flatboard установлен';
$lang['installed_msg'] = 'Теперь можно содавать форумы! Нужна помощь? Пожалуйста <a href="http://flatboard.free.fr/view.php/plugin/page/p/docs">прочтите</a>.';

/************* config.php ***************/
$lang['homepage'] = 'Главная страница';
$lang['footer_text'] = 'Текст в подвале';
$lang['announcement'] = 'Объявление';
$lang['announcement_desc'] = 'Оставьте пустым, чтобы не показывать объявления (HTML разрешено).';
$lang['ItemByPage'] = 'Количество тем на странице';
$lang['date_format'] = 'Формат даты';
$lang['date_format_placeholder'] = 'Год/месяц/день Часы:минуты';
$lang['maintenance'] = 'Обслужтвание';
$lang['maintenance_desc'] = 'Сайт на обслуживании, зайдите позже.';
$lang['ban_list'] = 'Бан лист';
$lang['ban_ok']  = 'IP-адрес заблокирован.';
$lang['ban_fail'] = 'IP-адрес уже заблокирован.';
$lang['notifications_center'] = 'Настройки';
$lang['add_worker'] = 'Добавить модератора';
$lang['save'] = 'Сохранить';
$lang['update'] = 'Оббновить ';
$lang['theme'] = 'Тема';
$lang['theme_desc'] = '<a href="config.php/deletecache" class="label error outline">Delete cache</a>';
$lang['cache_clean'] = 'Cache Cleaned';
$lang['folder_deleted'] = 'Папка успешно удалена';
$lang['folder_error'] = 'Ошибка во время удаления папки';
$lang['lang'] = 'Язык';
$lang['editor'] = 'Editor';
$lang['bbcode'] = 'BBcode';
$lang['markdown'] = 'Markdown';
$lang['editor_desc'] = 'BBcode or markdown format';
$lang['style'] = 'Стиль';
$lang['style_placeholder'] = 'slateblue, #000000…';
$lang['style_desc'] = 'Позволяет настроить цвет панели навигации, например #000000.';
$lang['nb_page_scroll_infinite'] = 'Сколько страниц для прокрутки автоматически';
$lang['nb_page_scroll_desc'] = 'Установите 1, чтобы отключить автоматическую прокрутку.';
$lang['salt'] = 'Key security';
$lang['salt_desc'] = 'Leave blank to generate a key';

/************* Msg System ***************/
$lang['warning_installation_file'] = 'install.php все еще находится в корневом каталоге Flatboard.<br />Из соображений безопасности, настоятельно рекомендуется <a class="button secondary outline small" role="button" href="config.php/delinstallfile" title="удалить сейчас?">удалить</a>.';
$lang['update_version_%1$s'] = 'Вы можете обновить <a href="http://flatboard.free.fr/download.php">FlatBoard %1$s</a>. Загрузите пакет и установите его вручную.';
$lang['no_update'] = 'У вас есть последняя версия Flatboard.';
$lang['update_error'] = 'При проверке обновления произошел сбой по неизвестной причине';
$lang['allow_url_fopen'] = 'Не удалось проверить наличие обновлений, как \'allow_url_fopen\' отключен на этой системе';
$lang['change_defaut_password'] = 'Вы используете пароль, предоставленный по умолчанию, <a href="auth.php/password">мы рекомендуем вам изменить его</a> на более сложный.';

/************* add.php ***************/
$lang['topic_added'] = 'Тема добавлена!';
$lang['reply_added'] = 'Ответ добавлен!';
$lang['forum_added'] = 'Форум добавлен!';
$lang['write_post'] = 'Write a Post...';
$lang['modo_added'] = 'Новый модератор добавлен!';

$lang['trip_desc'] = 'Не нужно "регистрироваться", просто введите одно и то же имя<span style="color:red">#</sapn>пароль по вашему выбору каждый раз или оставьте поле пустым для анонимной публикации. Ваш пароль будет отображаться зашифрованным и хэшированным для посетителей по соображениям безопасности!';

$lang['trip'] = 'Имя ';

$lang['badge_color'] = 'Badge color';
$lang['badge_color_desc'] = 'Введите шестнадцатеричный цвет или название цвета';
$lang['font_icon'] = 'Icon category';
$lang['font_icon_placeholder'] = 'fa-folder';
$lang['font_icon_desc'] = 'Go to <a href="http://fontawesome.io/icons/">Font Awesome</a> website for choose a icon';
$lang['email_sent'] = 'Письмо успешно отправлено';
$lang['email_nosent'] = 'Не удалось отправить электронную почту';
$lang['report_desc'] = 'Примечание: Модератор получит уведомление - ссылку на страницу, о которой вы сообщите. <br /> Эта форма предназначена только для сообщений о нарушениях и не используется в качестве средств общения с модераторами.';
$lang['your_email'] = 'Ваш адрес электронной почты';
$lang['click_to_view_post'] = 'Нажмите здесь, чтобы просмотреть запись';
$lang['order'] = 'Order';

/************* delete.php ***************/
$lang['topic_deleted'] = 'Тема удалена!';
$lang['reply_deleted'] = 'Ответ удален!';
$lang['forum_deleted'] = 'Форум удален!';
$lang['worker_deleted'] = 'Модератор удален!';
$lang['ip_not_banned'] = 'IP-адрес не был заблокирован.';
$lang['ip_removed'] = 'IP-адрес был удален.';

/************* edit.php ***************/
$lang['topic_edited'] = 'Тема отредактирована!';
$lang['reply_edited'] = 'Ответ отредактирован!';
$lang['forum_edited'] = 'Форум отредактирован!';
$lang['pinned_homepage'] = 'Закреплен на главной странице';

$lang['useSpace'] = true;
$lang['home'] = 'Главная';
$lang['thread_sug']  = 'Thread Suggest';
$lang['change_pwd']  = 'Изменить пароль';
$lang['topic'] = 'Тема';
$lang['newthread'] = 'Создать тему';
$lang['reply'] = 'Ответить';
$lang['newreply'] = 'Новый ответ';
$lang['quote_reply'] = 'Цитировать';
$lang['quote_by'] = 'Цитата от ';
$lang['add_forum']   = 'Добавить форум';
$lang['plugin'] = 'Плагин';
$lang['config'] = 'Конфигурация';
$lang['logout'] = 'Выход';
$lang['login'] = 'Вход';
$lang['redirect'] = ' ';
$lang['add'] = 'Добавить';
$lang['edit'] = 'Редактировать';
$lang['delete'] = 'Удалить';
$lang['title'] = 'Заголовок';
$lang['content'] = 'Содержание';
$lang['name'] = 'Имя';
$lang['mail'] = 'Email';
$lang['search'] = 'Поиск';
$lang['forum'] = 'Форум';
$lang['password'] = 'Пароль';
$lang['confirm_password'] = 'Подтвердить пароль';
$lang['powered'] = 'Создано в <a href="http://flatboard.free.fr" onclick="window.open(this.href); return false;">Flatboard</a> и <i class="fa fa-heart"></i>.';
$lang['feed'] = 'Лента';
$lang['none'] = 'Нет записи до сих пор';
$lang['info'] = 'Информация';
$lang['date'] = 'Дата';
$lang['view'] = 'Просмотр';
$lang['count'] = 'Пост';
$lang['new'] = 'Новое';
$lang['more'] = 'Больше';
$lang['submit'] = 'Отправить';
$lang['admin'] = 'Администратор';
$lang['worker'] = 'Модератор';
$lang['sort_forums'] = 'Сортировать форумы';
$lang['yes'] = 'Да';
$lang['no'] = 'Нет';
$lang['locked'] = 'Заблокирован';
$lang['no_reply'] = 'Вы не можете ответить';
$lang['locked_discussion'] = 'заблокировал обсуждение.';
$lang['report'] = 'Отчет';
$lang['day'] = 'день';
$lang['hour'] = 'час';
$lang['minute'] = 'минут';
$lang['second'] = 'секунд';
$lang['plural'] = ' ';
$lang['ago'] = 'тому назад';
$lang['errLen'] = 'Слишком короткий или слишком длинный текст';
$lang['errBot'] = 'Неправильный код CAPTCHA';
$lang['errNb'] = 'Не является положительным целым числом';
$lang['pinned'] = 'Закрепить';
$lang['stickied_discussion'] = 'Закрепленная тема.';
$lang['replied'] = '<i class="fa fa-share-square"></i> отвечен ';
$lang['started'] = '<i class="fa fa-bolt"></i> запущен ';
$lang['notFound'] = 'Страница не существует!';
$lang['errNotMatch'] = 'Неправильный пароль';
$lang['captcha'] = 'Captcha';
$lang['enter_code'] = 'Enter security code';
$lang['r_captcha']   = 'Показать другой код';
$lang['quickNav'] = 'Быстрая навигация';
$lang['invalid_token'] = 'Недействительный символ!';
$lang['mail_available'] = 'Функция отправки электронной почты доступна ';
$lang['mail_not_available'] = 'Функция отправки электронной почты не доступна';

/************* view.php ***************/
$lang['permalink'] = 'Постоянная ссылка';
$lang['solved'] = 'Решена';
$lang['original_message'] = 'ОБСУЖДЕНИЕ ПРОИСХОЖДЕНИЯ';

/************* search.php ***************/
$lang['search_term_found'] = 'Поисковый запрос найден.';

/************* Plugin ***************/
$lang['state']        = 'Вкл./Выкл. плагин';
$lang['state_on']     = 'Вкл.';
$lang['state_off']    = 'Выкл.';
$lang['data_save']    = 'Защищенные данные!';
$lang['description']  = 'Описание';
$lang['author']       = 'Автор';
$lang['check_all']    = 'Проверить все';
$lang['plugin_help']    = '<i class="fa fa-warning"></i> Помощь';
$lang['manage_plugin']    = 'Управление плагином';

/************* auth.php ***************/
$lang['password_changed'] = 'Ваш пароль был успешно изменен!';
$lang['edit_password'] = 'Изменить пароль';
$lang['login_confirm'] = 'Вы успешно вошли!';
$lang['logout_confirm'] = 'Вы вышли!';
$lang['incorrect_password'] = 'Неправильный пароль.';
$lang['error_maxlogin'] = 'Слишком много неудачных Войти. Повторите попытку через% S минут.';

/************* services.php ***************/
$lang['ban_user'] = 'Запретить этот IP';
$lang['unban_user'] = 'Разрешить этот IP';
$lang['banned'] = 'Вы были заблокированы!';
$lang['your_banned'] = 'Вы были удалены на форуме.<br />Свяжитесь с администратором форума для получения информации.<br />Причина запрета: как часть нашей политики, активной против спама,<br />ваш ip: ';
$lang['has_banned'] = ' был запрещен!';
$lang['ban'] = 'IP-адрес / диапазоны IP-адреса';
?>