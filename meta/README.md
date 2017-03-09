Project Meta Files
===================


## The Database

### CSV -> SQL

```bash
$: cd meta/parsers/db
# If from a human-edited source ....
$: python clean_asm_db_source.py
# Always
$: python parse_csv_to_sql.py
$: cd ../..
$: mysql -u root -p
MariaDB > use asm_sadb;
MariaDB [asm_sadb]> source FILENAME_OF_OUTPUT.sql
```

### Exporting SQL -> CSV

```bash
$: mysql -u root -p asm_sadb -e "select * from mammal_diversity_database" -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > meta/exported-table.csv
```

### Backup &amp; Restore

#### Backup the database

This will contain user data. While the passwords are securely stored,
we should be respectful of any information they may consider
sensitive.

```bash
mysqldump -u root -p asm_sadb > meta/database/asm_db_backup.sql
blackbox_edit_end meta/database/asm_db_backup.sql
```

#### Restore the database

```bash
$: cd meta/database
$: blackbox_edit_start asm_db_backup.sql.gpg
$: mysql -u root -p
MariaDB > use asm_sadb;
MariaDB [asm_sadb]> source asm_db_backup.sql
MariaDB [asm_sadb]> exit;
$: blackbox_edit_end asm_db_backup.sql
```
