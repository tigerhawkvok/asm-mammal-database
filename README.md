ASM Mammalian Diversity Database
======================


You can find the most current version at http://mammaldiversity.org/


## Stateful URI

The URIs are stateful! You can always use the same link to recreate the exact parameters.

Specifically, the URI is a Base-64 encoded query string of what is loaded asynchronously.

Therefore,

http://mammaldiversity.org/#YmF0cmFjaG9zZXBzJmxvb3NlPXRydWU

has the query string reconstructed from the bit after the hash:

```javascript
Base64.decode("YmF0cmFjaG9zZXBzJmxvb3NlPXRydWU")
// returns "batrachoseps&loose=true"
```

You can generate links that way, corresponding to the options given in the following API section.

## API

### Search query parameters

1. `q`: The main query, for common names or species.
2. `fuzzy`: if truthy, use a similar sounding search for results, like
   SOUNDEX. Note this won't work for authority years or deprecated
   scientific names. **Default `false`**
3. `loose`: Truthy. Don't check for strict matches, allow partials and
   case-insensitivity **Application default `true`; API default
   `false`**
4. `only`: restrict search to this csv column list. Return an error if
   invalid column specified.
5. `include`: Include additional search columns in this csv
   list. Return an error if invalid column specified.
6. `type`: restrict search to this `major_type`. Literal scientific
   match only. Return an error if the type does not exist. **Default
   none**
7. `filter`: restrict search by this list of {"`column`":"value"}
   object list. Requires key "BOOLEAN_TYPE" set to either "AND" or
   "OR". Return an error if the key does not exist, or if an unknown
   column is specified. This should be supplied as a URL-encoded JSON
   string (eg,
   `%7B%22species_authority%22:%22neill%22,%22boolean_type%22:%22and%22%7D`)
   or a Base64-encoded string (eg,
   `eyJzcGVjaWVzX2F1dGhvcml0eSI6Im5laWxsIiwiYm9vbGVhbl90eXBlIjoiYW5kIn0`),
   where both examples represent
   `{"species_authority":"neill","boolean_type":"and"}`. **Default
   none**
8. `limit`: Search result return limit. **Default unlimited**
9. `order`: A csv list of columns to order by. **Defaults to genus,
   species, subspecies**


### API return

The JSON result gives the following parameters:

1. `status`: boolean `true` or `false`. `true` is returned on an good
   search, regardless of hits.
2. (false status only) `error`: A technical error message
3. (false status only) `human_error`: A message to display to users.
3. (bad parameters only) `given`: The provided parameters.
3. (bad filter only) `columns`: The provided column list.
3. (bad filter only) `bad_coulmn`: The invalid column.
4. `result`: An object containing one taxon per numeric key, which
   itself contains:

    ```php
    id # internal counter
    common_name
    genus
    species
    subspecies
    deprecated_scientific # Object, eg {"Genus species":"Authority:Year"}
    major_type # eg, prototheria, metatheria, eutheria
    major_common_type # eg, marsupial, 'placental mammal'
    major_subtype # eg, rodent, bat, etc
    minor_type # eg, chiroptera, lagomorph; roughly a ranked "family", scientific only
    linnean_order # Deprecated, included for compatibility
    genus_authority #  eg, "Linnaeus"
    species_authority # eg, "Attenborough"
    authority_year # eg, {2013:2014} in the format {"Genus Authority Year":"Species Authority Year"}
    notes # Miscellaneous notes
    image # Path to an image, relative to mammaldiversity.org/, if it exists
    image_credit
    image_license
    taxon_author # Last edited by ...
    taxon_credit # Cite taxon info
    ```
5. `count`: The number of results
6. `method`: The way the search was executed
7. `query`: The requested search
8. `params`: The checked matches
9. `query_params`: A breakdown of your computed query
   1. `bool`: The used `boolean_type`
   2. `loose`: boolean `true` or `false`
   3. `fuzzy`: boolean `true` or `false`
   4. `order_by`: The way the results are sorted
   5. `filter`: An object representing any applied filters
      1. `had_filter`: boolean `true` or `false`
      2. `filter_params`: The used filter parameters
      3. `filter_literal`: The provided filter in the query
10. `execution_time`: The time to execute your query and return your result, in ms.

**Please note** that all entries are returned in lower case, except
for `result.[taxon].notes` and `result.[taxon].image` (where an
image exists and the path includes mixed case).

As the rest of the data have strict formatting requirements, all other
formatting is left up to the application to correctly apply CSS styles
to generate the desired case.

### Search behaviour

**Please note that the example JSON results may not have all of the
  fields or data in the `result` key of the most recent version. There
  will be no compatability breaking. All the correct fields are listed
  above.**

The search algorithm behaves as follows:

1. If the search `is_numeric()`, a `loose` search is done against the
   `authority_year` column in the database. The returned `method` with
   the JSON is `authority_year`. [Example](https://ssarherps.org/cndb/commonnames_api.php?q=2014&loose=true):

    ```json
    {"status":true,"result":{"0":{"id":"562","genus":"eurycea","species":"subfluvicola","subspecies":"","common_name":"ouachita streambed salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"brook salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"rafinesque","species_authority":"steffen, irwin, blair, and bonett","authority_year":"{\"1822\": \"2014\"}","deprecated_scientific":"","notes":""},"1":{"id":"70","genus":"macrochelys","species":"appalachicolae","subspecies":"","common_name":"suwannee alligator snapping turtle","image":"","major_type":"testudines","major_common_type":"turtles","major_subtype":"alligator snapping turtles","minor_type":"","linnean_order":"testudines","genus_authority":"gray","species_authority":"thomas, granatosky, bourque, krysko, moler, gamble, suarez, leone, enge, and roman","authority_year":"{\"1855\": \"2014\"}","deprecated_scientific":"","notes":""}},"count":2,"method":"year_search","query":"2014","params":{"authority_year":"2014"},"query_params":{"bool":false,"loose":true,"order_by":"genus,species,subspecies","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"execution_time":1.98006629944}
    ```

2. The search is then checked for the absence of the space
   character. If no overrides are set, `common_name`, `genus`,
   `species`, `subspecies`, `major_common_type`, `major_subtype`, and
   `deprecated_scientific` columns are all searched. The returned `method` is
   `spaceless_search`. [Example](https://ssarherps.org/cndb/commonnames_api.php?q=arboreal&loose=true):

    ```json
    {"status":true,"result":{"0":{"id":"484","genus":"aneides","species":"lugubris","subspecies":"","common_name":"arboreal salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"climbing salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"hallowell","authority_year":"{\"1851\": \"1849\"}","deprecated_scientific":"","notes":""}},"count":1,"method":"spaceless_search","query":"arboreal","params":{"common_name":"arboreal","genus":"arboreal","species":"arboreal","subspecies":"arboreal","major_common_type":"arboreal","major_subtype":"arboreal","deprecated_scientific":"arboreal"},"query_params":{"bool":"OR","loose":true,"order_by":"genus,species,subspecies","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"execution_time":3.57890129089}
    ```

3. The search is then checked for spaces.
   1. If a `filter` is set (with the required `boolean_type` parameter):
      1. If there is two or three words, the first word is checked
         against the `genus` column, second against the `species` column,
         and third against the `subspecies` column. The returned `method` is `scientific`. [Example](https://ssarherps.org/cndb/commonnames_api.php?q=farancia+erytrogramma&loose=true&filter={%22species_authority%22:%22neill%22,%22boolean_type%22:%22and%22})

          ```json
          {"status":true,"result":{"0":{"id":"235","genus":"farancia","species":"erytrogramma","subspecies":"seminola","common_name":"southern florida rainbow snake","image":"","major_type":"squamata","major_common_type":"snakes","major_subtype":"mudsnakes and rainbow snakes","minor_type":"","linnean_order":"serpentes","genus_authority":"gray","species_authority":"neill","authority_year":"{\"1842\": \"1964\"}","deprecated_scientific":"","notes":""}},"count":1,"method":"scientific","query":"farancia erytrogramma","params":{"species_authority":"neill"},"query_params":{"bool":"and","loose":true,"order_by":"genus,species,subspecies","filter":{"had_filter":true,"filter_params":{"species_authority":"neill","boolean_type":"and"},"filter_literal":"{\"species_authority\":\"neill\",\"boolean_type\":\"and\"}"}},"execution_time":2.66885757446}
          ```
      2. If the above returns no results, the `deprecated_scientific`
         column is checked. At the time of this writing, there are no
         entries in this column and this check will always fail. The
         returned method is `deprecated_scientific`.

      3. If the above returns no results, the `common_name` column is
         checked. The returned method is `no_scientific_common`. [Example](https://ssarherps.org/cndb/commonnames_api.php?q=rainbow+snake&loose=true&filter={%22species_authority%22:%22neill%22,%22boolean_type%22:%22and%22}):

         ```json
         {"status":true,"result":{"0":{"id":"235","genus":"farancia","species":"erytrogramma","subspecies":"seminola","common_name":"southern florida rainbow snake","image":"","major_type":"squamata","major_common_type":"snakes","major_subtype":"mudsnakes and rainbow snakes","minor_type":"","linnean_order":"serpentes","genus_authority":"gray","species_authority":"neill","authority_year":"{\"1842\": \"1964\"}","deprecated_scientific":"","notes":""}},"count":1,"method":"no_scientific_common","query":"rainbow snake","params":{"species_authority":"neill"},"query_params":{"bool":"and","loose":true,"order_by":"genus,species,subspecies","filter":{"had_filter":true,"filter_params":{"species_authority":"neill","boolean_type":"and"},"filter_literal":"{\"species_authority\":\"neill\",\"boolean_type\":\"and\"}"}},"execution_time":1.58905982971}
         ```

    2. If the `filter` parameter isn't specified, the above scientific
       and deprecated scientific searches are executed with
       "best-guess" boolean types (with returned `method`s
       `scientific_raw` and `deprecated_scientific_raw`). [Example](https://ssarherps.org/cndb/commonnames_api.php?q=taricha+torosa&loose=true):

       ```json
       {"status":true,"result":{"0":{"id":"683","genus":"taricha","species":"torosa","subspecies":"","common_name":"california newt","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"pacific newts","minor_type":"","linnean_order":"caudata","genus_authority":"gray","species_authority":"rathke, in eschscholtz","authority_year":"{\"1850\": \"1833\"}","deprecated_scientific":"","notes":""}},"count":1,"method":"scientific_raw","query":"taricha torosa","params":{"genus":"taricha","species":"torosa"},"query_params":{"bool":"and","loose":true,"order_by":"genus,species,subspecies","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"execution_time":0.568151473999}
       ```

       1. If all these fail, and `fuzzy` is `false`, the `fallback`
          flag is set and a search is done against `common_name`. The
          returned `method` is
          `space_common_fallback`. [Example](https://ssarherps.org/cndb/commonnames_api.php?q=rainbow+snake&loose=true):

          ```json
          {"status":true,"result":{"0":{"id":"233","genus":"farancia","species":"erytrogramma","subspecies":"","common_name":"rainbow snake","image":"","major_type":"squamata","major_common_type":"snakes","major_subtype":"mudsnakes and rainbow snakes","minor_type":"","linnean_order":"serpentes","genus_authority":"gray","species_authority":"palisot de beauvois in sonnini and latreille","authority_year":"{\"1842\": \"1801\"}","deprecated_scientific":"","notes":""},"1":{"id":"234","genus":"farancia","species":"erytrogramma","subspecies":"erytrogramma","common_name":"common rainbow snake","image":"","major_type":"squamata","major_common_type":"snakes","major_subtype":"mudsnakes and rainbow snakes","minor_type":"","linnean_order":"serpentes","genus_authority":"gray","species_authority":"palisot de beauvois in sonnini and latreille","authority_year":"{\"1842\": \"1801\"}","deprecated_scientific":"","notes":""},"2":{"id":"235","genus":"farancia","species":"erytrogramma","subspecies":"seminola","common_name":"southern florida rainbow snake","image":"","major_type":"squamata","major_common_type":"snakes","major_subtype":"mudsnakes and rainbow snakes","minor_type":"","linnean_order":"serpentes","genus_authority":"gray","species_authority":"neill","authority_year":"{\"1842\": \"1964\"}","deprecated_scientific":"","notes":""}},"count":3,"method":"space_common_fallback","query":"rainbow snake","params":{"genus":"rainbow","species":"snake","common_name":"rainbow snake"},"query_params":{"bool":"or","loose":true,"order_by":"genus,species,subspecies","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"execution_time":0.930070877075}
          ```

      2. If the `fuzzy` flag is set, or the above still gives no
         results and the `loose` flag **is** set, a search is done
         word-wise on `common_name`, `major_common_type`, and
         `major_subtype` (eg, for all matches that contain each word
         as a substring in any of the columns). The returned `method`
         is `space_loose_fallback`. [Example](http://mammaldiversity.org/commonnames_api.php?q=salamander+black&loose=true)

         ```json
         {"status":true,"result":{"0":{"id":"480","genus":"aneides","species":"flavipunctatus","subspecies":"","common_name":"black salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"climbing salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"strauch","authority_year":"{\"1851\": \"1870\"}","deprecated_scientific":"","notes":""},"1":{"id":"481","genus":"aneides","species":"flavipunctatus","subspecies":"flavipunctatus","common_name":"speckled black salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"climbing salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"strauch","authority_year":"{\"1851\": \"1870\"}","deprecated_scientific":"","notes":""},"2":{"id":"482","genus":"aneides","species":"flavipunctatus","subspecies":"niger","common_name":"santa cruz black salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"climbing salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"myers and maslin","authority_year":"{\"1851\": \"1948\"}","deprecated_scientific":"","notes":""},"3":{"id":"501","genus":"batrachoseps","species":"nigriventris","subspecies":"","common_name":"black- bellied slender salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"slender salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"bonaparte","species_authority":"cope","authority_year":"{\"1839\": \"1869\"}","deprecated_scientific":"","notes":""},"4":{"id":"519","genus":"desmognathus","species":"folkertsi","subspecies":"","common_name":"dwarf black-bellied salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"dusky salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"camp, tilley, austin, and marshall","authority_year":"{\"1850\": \"2002\"}","deprecated_scientific":"","notes":""},"5":{"id":"529","genus":"desmognathus","species":"quadramaculatus","subspecies":"","common_name":"black-bellied salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"dusky salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"holbrook","authority_year":"{\"1850\": \"1840\"}","deprecated_scientific":"","notes":""},"6":{"id":"531","genus":"desmognathus","species":"welteri","subspecies":"","common_name":"black mountain salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"dusky salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"baird","species_authority":"barbour","authority_year":"{\"1850\": \"1950\"}","deprecated_scientific":"","notes":""},"7":{"id":"670","genus":"pseudotriton","species":"ruber","subspecies":"schencki","common_name":"black-chinned red salamander","image":"","major_type":"caudata","major_common_type":"salamanders","major_subtype":"red and mud salamanders","minor_type":"","linnean_order":"caudata","genus_authority":"tschudi","species_authority":"brimley","authority_year":"{\"1846\": \"1912\"}","deprecated_scientific":"","notes":""}},"count":8,"method":"space_loose_fallback","query":"salamander black","params":null,"query_params":{"bool":"or","loose":true,"fuzzy":false,"order_by":"genus,species,subspecies","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"execution_time":1.25002861023}
         ```

## Administration

You can access the administration / editing interface by logging in at
http://mammaldiversity.org/admin

If you create a user, an exisiting user [with the `admin` flag set](https://github.com/tigerhawkvok/asm-mammal-database/blob/master/admin/handlers/login_functions.php#L1973-L1995) will need to authorize your access. **You will not be able to log in or access the admin interface until this occurs**.

If you log in to another device / location, all other session credentials will be invalidated. [This occurs at API-level](https://github.com/tigerhawkvok/blob/master/asm-mammal-database/admin_api.php#L43-L48), and may require a re-login if your network location changes.

### Old scientific names

Old scientific names are to be stored in the field `Deprecated Scientific Names`. **This field has a rigid required structure**. They're written as a [JSON](https://en.wikipedia.org/wiki/JSON) entry with special requirements (and no braces).

Therefore, each deprecated scientific name is to be written as `"Genus species":"Authority: YYYY"`, with an arbitrarily long list of those separated by commas. Therefore, be cognizant of the following rules:

- There should be no space between colons or commas. E.g., `"foo":"bar"` and `"foo:bar","bar":"baz"` is OK, but **not** `"foo" :"bar","bar":"baz"` or `"foo":"bar", "bar":"baz"`.

- The `"Authority: YEAR"` string is optional in the space around the colon. The year has to match the rules [established in Issue #37](https://github.com/tigerhawkvok/SSAR-species-database/issues/37#issuecomment-105041048)

- The validity of the taxon information is not checked.


## Reporting bugs

Please use the issue tracker here to report all bugs.

**If you find a security bug**, please practice responsible disclosure! Email `support@velociraptorsystems.com` with the issue. The administrative page uses a fork of [tigerhawkvok/php-userhandler](https://github.com/tigerhawkvok/php-userhandler), As appropriate, report bugs or offer pull requests on the right branch.


## Building the application

### Grunt

Tasks are managed here by [Grunt](http://gruntjs.com/). 

You can install Grunt from the command line by running `yarn global install grunt-cli`.

### Updating

You can update the whole application, with dependencies, by running
`grunt build` at the root directory.

<!-- The main page is written with app.html. The grunt task `vulcanize` will use the [Vulcanize tool](https://github.com/polymer/vulcanize) to build a flattened version that minimizes network calls. Running the `grunt watch` command will trigger this on every saved edit of `app.html`. -->

### Installation

Install this in the root directory of the
site. **If this is to be located elsewhere**, change the variable
`searchParams.targetApi` in `/coffee/search.coffee` and recompile the
coffeescript.

You can re-prepare the files by running `grunt compile` at the root directory.

### Setting up the database

#### Manually preparing the database

1. Take your root Excel file and save it as a CSV
2. Run the file
   [`parsers/db/clean_and_parse_to_sql.py`](https://github.com/tigerhawkvok/asm-mammal-database/blob/master/parsers/db/clean_and_parse_to_sql.py)
3. The resulting file in the directory root is ready to be imported
   into the database

#### Manually importing into the database

**NOTE: This will delete the existing table**

1. You can SSH into the database and paste the contents of the `sql`
   file generated above.
2. Otherwise, you can upload the file, then SSH into the database, and
   run `source FILENAME.sql` when visiting the database in the `mysql`
   prompt:

  ```
  mysql> \r DATABASE_NAME
  mysql> source FILENAME.sql
  ```

  This is the most reliable way to do it.

#### Manually updating the database

1. Run the file
   [`parsers/db/update_sql_from_csv.py`](https://github.com/tigerhawkvok/asm-mammal-database/blob/master/parsers/db/update_sql_from_csv.py)
   and do as above.

#### Columns

```php
common_name
genus
species
subspecies
deprecated_scientific # Stored as JSON object, eg {"Genus species":"Authority:Year"}
major_type # eg, squamata
major_common_type # eg, lizard, turtle.
major_subtype # eg, snake v. non-snake, aquatic vs. tortoise. Only common, public use -- match "expectation"
minor_type # eg, lacertid, boa, pleurodire, dendrobatid; roughly a ranked "family", scientific only
linnean_order # Deprecated, included for compatibility
genus_authority #  eg, "Linnaeus"
parens_auth_genus # Boolean -- show genus authority in parenthesis. See #46
species_authority # eg, "Attenborough"
parens_auth_genus # Boolean -- show species authority in parenthesis. See #46
authority_year # eg, {2013:2014} in the format {"Genus Authority Year":"Species Authority Year"}
notes # Miscellaneous notes
image # hit calphotos api if this field is empty
image_credit # If not in public domain
image_license # If not in public domain
taxon_author # Last editor of entry
taxon_credit # Credit for `notes`
taxon_credit_date # The date for the taxon credit
```
