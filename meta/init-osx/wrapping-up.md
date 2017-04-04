# Wrapping Up

## Configuring `mod_userdir`

Most of the work has been done, now we need to configure your Apache module `userdir`.

You'll need to make edits to the file `/etc/apache2/users/<your short user name>.conf`. Open that file **as an administrator** in your favorite text editor.

If it's empty, it should be configured to look something like this:

```conf
<Directory "/Users/<your short user name>/<path/to/git/repo>/">
    Options Indexes MultiViews
    AllowOverride None
    Order allow,deny
    Allow from localhost
    Require all granted
</Directory>
```

If it already has contents, just change the path of `Directory` so that it points to the Git repo. Close your editor -- it's running as an admin, and doing the next step as an admin may mess with system permissions.

## Changing internal references

Now you'll need to change the directories expected by the script. Open your favorite text editor and open for editing:

`<path/to/git/repo>/admin/CONFIG.php`

Line 33 at the time of this writing should look like:

```php
$working_subdirectory = "~philip/admin/";
```

Change `~philip` to `~<your short username>`

## Restart apache2

In your terminal, run


```
sudo apachectl -k restart
```

## Create an administrative user for yourself


The site should be up an running at `http://localhost/~<your short username>/` , but you'll want an admin user for yourself.

Visit `http://localhost/~<your short username>/admin-login.php` and create a user. You'll be told you need confirmation, but don't worry!


Return to the command line, and run:

```sh
mysql -u root -p
```

This should dump you into the MariaDB / MySQL prompt. (Your default password should be empty)

From there, run:

```sql
\r asm_sadb
select id, username, flag, admin_flag, su_flag from userdata;
```

Note that the last row should have your username, and take note of the ID in the first column of that row. Then run:

```sql
UPDATE userdata SET `flag`=1, `admin_flag`=1, `su_flag`=1 WHERE `id`=YOUR_USER_ID_NUMBER;
```

That should complete successfully, after which you can just write `exit` and your user should be enabled and flagged as an administrator.
