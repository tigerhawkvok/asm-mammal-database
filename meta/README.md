Project Meta Files
===================


## The Database

### CSV -> SQL

```bash
cd meta/parsers/db
# If from a human-edited source ....
python clean_asm_db_source.py
# Always
python parse_csv_to_sql.py
cd ../..
mysql -u root -p
MariaDB > use asm_sadb;
MariaDB [asm_sadb]> source FILENAME_OF_OUTPUT.csv
```

### Exporting SQL -> CSV

```bash
mysql -u root -p asm_sadb -e "select * from mammal_diversity_database" -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > meta/exported-table.csv
```
