-- SOURCE './database/db_upgrade_20180203/asm-species-2018-02-04.sql';
SELECT * INTO OUTFILE './exported-table.csv'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
       LINES TERMINATED BY '\n'
       FROM `mammal_diversity_database`;
