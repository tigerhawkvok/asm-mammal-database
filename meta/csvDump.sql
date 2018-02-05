SELECT * INTO OUTFILE './exported-table.csv'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
       LINES TERMINATED BY '\n'
       FROM `mammal_diversity_database`;
