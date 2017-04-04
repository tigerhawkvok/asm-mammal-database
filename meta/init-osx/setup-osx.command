#!/bin/bash
# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# Install local environment
# - MariaDB: up-to-date / more secure version of MySQL
# - Yarn: devdependencies
# - Git: to get the one shipped with OSX up to date
# - blackbox: For the secrets in the repo
# - a2enmod: So we don't have to manually edit the httpd.conf file
brew install mariadb yarn git blackbox a2enmod
# Set up PHP7 -- PHP5 is no longer maintained
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
brew unlink php56
brew install php70
brew install php70-xdebug
brew install mcrypt php70-mcrypt
# Install the repo
git clone git@github.com:tigerhawkvok/asm-mammal-database.git
cd asm-mammal-database
# Decrypt files
blackbox_decrypt_all_files
# Set up the database
# See https://mariadb.com/kb/en/mariadb/installing-mariadb-on-macos-using-homebrew/
brew services start mariadb
mysql -u root -p < meta/database/create-sql-user.sql
mysql -u root -p < meta/asm_db_backup.sql
# Set up apache2
# Enable packages
a2dismod php5
a2dismod mpm_event
a2enmod php7.0
a2enmod mpm-prefork
a2enmod userdir
# Start service
sudo apachectl -k restart
# Scripts on OSX need the execute bit
sudo chmod +x meta/init-osx/init-server.command
# Copy startup file
cp meta/init-osx/init-server.command ~/Desktop/init-server.command
# Install devdependencies
yarn install
# Open the manual instructions
echo "Opening browser for final manual steps ..."
open https://github.com/tigerhawkvok/asm-mammal-database/blob/master/meta/init-osx/wrapping-up.md
