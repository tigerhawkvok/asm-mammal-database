ASM Mammalian Diversity Database
======================


You can find the most current version at https://mammaldiversity.org/


## Stateful URI

The URIs are stateful! You can always use the same link to recreate the exact parameters.

Specifically, the URI is a Base-64 encoded query string of what is loaded asynchronously.

Therefore,

https://mammaldiversity.org/#dXJzdXMrYXJjdG9zJmxvb3NlPXRydWU

has the query string reconstructed from the bit after the hash:

```javascript
Base64.decode("dXJzdXMrYXJjdG9zJmxvb3NlPXRydWU")
// returns "ursus+arctos&loose=true"
```

You can generate links that way, corresponding to the options given in the following API section.

## API

### Search query parameters

**Note**: Boolean values are "truthy" in the application; `"true"`, `true`, and `1` all evaluate to `true`; `"false"`, `false`, and `0` all evaluate to `false`.

1. `q`: **string** The main query, for common names or species.
2. `fuzzy`: **boolean** Use a similar sounding search for results, like
   SOUNDEX. Note this won't work for authority years or deprecated
   scientific names. *Default `false`*
3. `loose`: **boolean** Don't check for strict matches, allow partials and
   case-insensitivity *Application default `true`; API default
   `false`*
3. `global_search`: **boolean** Check all non-boolean columns for the search string simultaneously. *Default `false`*
4. `only`: **string** restrict search to this csv column list. Return an error if
   invalid column specified.
5. `include`: **string** Include additional search columns in this csv
   list. Return an error if invalid column specified.
6. `type`: **string** restrict search to this `major_type`. Literal scientific
   match only. Return an error if the type does not exist. *Default
   `null`*
7. `filter`: **json** restrict search by this list of {"`column`":"value"}
   object list. Requires key "BOOLEAN_TYPE" set to either "AND" or
   "OR". Return an error if the key does not exist, or if an unknown
   column is specified. This should be supplied as a URL-encoded JSON
   string (eg,
   `%7B%22species_authority%22:%22neill%22,%22boolean_type%22:%22and%22%7D`)
   or a Base64-encoded string (eg,
   `eyJzcGVjaWVzX2F1dGhvcml0eSI6Im5laWxsIiwiYm9vbGVhbl90eXBlIjoiYW5kIn0`),
   where both examples represent
   `{"species_authority":"neill","boolean_type":"and"}`. *Default
   `null`*
8. `limit`: **int** Search result return limit. *Default unlimited*
9. `order`: **string** A csv list of columns to order by. *Defaults to genus,
   species, subspecies*
10. `dwc_only`: **boolean** Return only [DarwinCore](http://rs.tdwg.org/dwc/index.htm) terminology. Otherwise, the DarwinCore terminology is in each taxon result under the key `dwc`. *Default `false`*



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
    simple_linnean_group #eg, prototheria, metatheria, eutheria. Ranked "cohort"
    major_type # eg, boreoeutheria, atlantogenata. Ranked "magnaorder"
    major_subtype # eg afrotheria, euarchotoglires. Ranked "superorder"
    simple_linnean_subgroup # eg, rodent, bat, etc. ~ ranked
    linnean_family # eg, chiroptera, lagomorph. Ranked "family"
    linnean_order # Ranked "order"
    genus_authority #  eg, "Linnaeus"
    species_authority # eg, "Attenborough"
    authority_year # eg, {2013:2014} in the format {"Genus Authority Year":"Species Authority Year"}
    parens_auth_genus # If the genus authority should be in a parenthetical
    parens_auth_species # If the species authority should be in a parenthetical
    notes # Miscellaneous notes for the taxon
    entry # The long-form entry for the taxon
    internal_id # The internal ASM number for the taxon
    source # The primary data source for the entry
    citation # Citation for the taxon
    image # Path to an image, relative to mammaldiversity.org/, if it exists
    image_credit
    image_license
    taxon_author # Last edited by ...
    taxon_credit # The credit for the taxon
    taxon_credit_date # The credit edit date
    dwc # All the DarwinCore terms for the taxon
    ```

    If the `dwc_only` flag is set, only the contents of the key `dwc` are returned per taxon.

    A sample DarwinCore-formatted response (either as a subkey `dwc` or the replacement with `dwc_only`)might look like

    ```json
    {
      "scientificName": "Diceros bicornis",
      "subspecificEpithet": "",
      "order": "perissodactyla",
      "specificEpithet": "bicornis",
      "genus": "diceros",
      "vernacularName": "Black Rhinoceros",
      "family": "rhinocerotidae",
      "namePublishedIn": "",
      "higherClassification": {
        "cohort": "eutheria",
        "magnaorder": "boreoeutheria",
        "superorder": "laurasiatheria",
        "list": "eutheria|boreoeutheria|laurasiatheria"
      },
      "scientificNameAuthorship": {
        "genus": "",
        "species": "(Linnaeus, 1758)"
      },
      "taxonRank": "species",
      "class": "mammalia",
      "taxonomicStatus": "accepted",
      "dcterms:bibliographicCitation": "Diceros bicornis (ASM Species Account Database #6557) fetched 2017-03-17T15:48:30-0700"
    }
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
for `result.[taxon].notes`, `result[taxon].entry`,
`result[taxon].taxon_credit`, and `result.[taxon].image` (where an
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
   the JSON is `authority_year`. [Example](https://mammaldiversity.org/api.php?q=1758&loose=true&dwc_only=true):

    ```json
    {"status":true,"result":{"0":{"scientificName":"Ursus arctos","subspecificEpithet":"","specificEpithet":"arctos","vernacularName":"brown bear","namePublishedIn":"","higherClassification":{"magnaorder":"foobar","cohort":"eutheria","list":"foobar|eutheria"},"scientificNameAuthorship":{"genus":"test, 2017","species":"linnaeus, 1758"},"taxonRank":"species","taxonomicStatus":"accepted","dcterms:bibliographicCitation":"Ursus arctos (ASM Species Account Database #41688) fetched 2017-03-17T14:33:11-0700"}},"count":1,"method":"year_search","query":"1758","params":{"authority_year":"1758"},"query_params":{"bool":false,"loose":true,"fuzzy":false,"order_by":"genus,species,subspecies,common_name","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"do_client_update":false,"execution_time":9.9999904632568}
    ```

2. The search is then checked for the absence of the space
   character. If no overrides are set, `common_name`, `genus`,
   `species`, `subspecies`, `major_common_type`, `major_subtype`, and
   `deprecated_scientific` columns are all searched. The returned `method` is
   `spaceless_search`. [Example](https://mammaldiversity.org/api.php?q=moose&loose=true&dwc_only=true):

   ```json
   {"status":true,"result":{"0":{"scientificName":"Alces alces","subspecificEpithet":"","specificEpithet":"alces","vernacularName":"Moose","namePublishedIn":"","higherClassification":{"cohort":"eutheria","list":"eutheria"},"scientificNameAuthorship":{"genus":"","species":"(Linnaeus, 1758)"},"taxonRank":"species","taxonomicStatus":"accepted","dcterms:bibliographicCitation":"Alces alces (ASM Species Account Database #41782) fetched 2017-03-17T14:34:57-0700"}},"count":1,"method":"spaceless_search_direct","query":"moose","params":{"common_name":"moose","genus":"moose","species":"moose","subspecies":"moose","major_type":"moose","major_subtype":"moose","deprecated_scientific":"moose"},"query_params":{"bool":"OR","loose":true,"fuzzy":false,"order_by":"genus,species,subspecies,common_name","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"do_client_update":false,"execution_time":2.500057220459}
    ```

3. The search is then checked for spaces.
   1. If a `filter` is set (with the required `boolean_type` parameter):
      1. If there is two or three words, the first word is checked
         against the `genus` column, second against the `species` column,
         and third against the `subspecies` column. The returned `method` is `scientific`. [Example](https://mammaldiversity.org/api.php?q=ursus+arctos&loose=true&dwc_only=true&filter={"species_authority":"linnaeus","boolean_type":"and"})

          ```json
          {"status":true,"result":{"0":{"scientificName":"Ursus arctos","subspecificEpithet":"","specificEpithet":"arctos","vernacularName":"brown bear","namePublishedIn":"","higherClassification":{"magnaorder":"foobar","cohort":"eutheria","list":"foobar|eutheria"},"scientificNameAuthorship":{"genus":"test, 2017","species":"linnaeus, 1758"},"taxonRank":"species","taxonomicStatus":"accepted","dcterms:bibliographicCitation":"Ursus arctos (ASM Species Account Database #41688) fetched 2017-03-17T14:39:19-0700"}},"count":1,"method":"scientific","query":"ursus arctos","params":{"species_authority":"linnaeus"},"query_params":{"bool":"AND","loose":true,"fuzzy":false,"order_by":"genus,species,subspecies,common_name","filter":{"had_filter":true,"filter_params":{"species_authority":"linnaeus","boolean_type":"and"},"filter_literal":"{\"species_authority\":\"linnaeus\",\"boolean_type\":\"and\"}"}},"do_client_update":false,"execution_time":12.006044387817}
          ```
      2. If the above returns no results, the `deprecated_scientific`
         column is checked. At the time of this writing, there are no
         entries in this column and this check will always fail. The
         returned method is `deprecated_scientific`.

      3. If the above returns no results, the `common_name` column is
         checked. The returned method is `no_scientific_common`. [Example](https://mammaldiversity.org/api.php?q=brown+bear&loose=true&dwc_only=true&filter={"species_authority":"linnaeus","boolean_type":"and"}):

         ```json
         {"status":true,"result":{"0":{"scientificName":"Ursus arctos","subspecificEpithet":"","specificEpithet":"arctos","vernacularName":"brown bear","namePublishedIn":"","higherClassification":{"magnaorder":"foobar","cohort":"eutheria","list":"foobar|eutheria"},"scientificNameAuthorship":{"genus":"test, 2017","species":"linnaeus, 1758"},"taxonRank":"species","taxonomicStatus":"accepted","dcterms:bibliographicCitation":"Ursus arctos (ASM Species Account Database #41688) fetched 2017-03-17T14:41:53-0700"}},"count":1,"method":"no_scientific_common","query":"brown bear","params":{"species_authority":"linnaeus"},"query_params":{"bool":"AND","loose":true,"fuzzy":false,"order_by":"genus,species,subspecies,common_name","filter":{"had_filter":true,"filter_params":{"species_authority":"linnaeus","boolean_type":"and"},"filter_literal":"{\"species_authority\":\"linnaeus\",\"boolean_type\":\"and\"}"}},"do_client_update":false,"execution_time":33.500909805298}
         ```

    2. If the `filter` parameter isn't specified, the above scientific
       and deprecated scientific searches are executed with
       "best-guess" boolean types (with returned `method`s
       `scientific_raw` and `deprecated_scientific_raw`). [Example](https://mammaldiversity.org/api.php?q=pathera+tigris&loose=true&dwc_only=true):

       ```json
       {"status":true,"result":{"0":{"scientificName":"Panthera tigris","subspecificEpithet":"","specificEpithet":"tigris","vernacularName":"Tiger","namePublishedIn":"","higherClassification":{"cohort":"eutheria","list":"eutheria"},"scientificNameAuthorship":{"genus":"","species":"(Linnaeus, 1758)"},"taxonRank":"species","taxonomicStatus":"accepted","dcterms:bibliographicCitation":"Panthera tigris (ASM Species Account Database #15955) fetched 2017-03-17T14:43:49-0700"}},"count":1,"method":"space_common_fallback","query":"pathera tigris","params":{"genus":"pathera","species":"tigris","common_name":"patheratigris"},"query_params":{"bool":"or","loose":true,"fuzzy":false,"order_by":"genus,species,subspecies,common_name","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"do_client_update":false,"execution_time":37.499189376831}
       ```

       1. If all these fail, and `fuzzy` is `false`, the `fallback`
          flag is set and a search is done against `common_name`. The
          returned `method` is
          `space_common_fallback`. [Example](https://mammaldiversity.org/api.php?q=brown+bear&loose=true):

          ```json
          {"status":true,"result":{"0":{"scientificName":"Ursus arctos","subspecificEpithet":"","specificEpithet":"arctos","vernacularName":"brown bear","namePublishedIn":"","higherClassification":{"magnaorder":"foobar","cohort":"eutheria","list":"foobar|eutheria"},"scientificNameAuthorship":{"genus":"test, 2017","species":"linnaeus, 1758"},"taxonRank":"species","taxonomicStatus":"accepted","dcterms:bibliographicCitation":"Ursus arctos (ASM Species Account Database #41688) fetched 2017-03-17T14:44:56-0700"}},"count":1,"method":"space_common_fallback","query":"brown bear","params":{"genus":"brown","species":"bear","common_name":"brownbear"},"query_params":{"bool":"or","loose":true,"fuzzy":false,"order_by":"genus,species,subspecies,common_name","filter":{"had_filter":false,"filter_params":null,"filter_literal":null}},"do_client_update":false,"execution_time":64.501047134399}
          ```

      2. If the `fuzzy` flag is set, or the above still gives no
         results and the `loose` flag **is** set, a search is done
         word-wise on `common_name`, `major_common_type`, and
         `major_subtype` (eg, for all matches that contain each word
         as a substring in any of the columns). The returned `method`
         is `space_loose_fallback`. [Example](https://mammaldiversity.org/commonnames_api.php?q=bear&loose=true&dwc_only=true&fuzzy=true)



## Old scientific names

Old scientific names are to be stored in the field `Deprecated Scientific Names`. **This field has a rigid required structure**. They're written as a [JSON](https://en.wikipedia.org/wiki/JSON) entry with special requirements (and no braces).

Therefore, each deprecated scientific name is to be written as `"Genus species":"Authority: YYYY"`, with an arbitrarily long list of those separated by commas. Therefore, be cognizant of the following rules:

- There should be no space between colons or commas. E.g., `"foo":"bar"` and `"foo:bar","bar":"baz"` is OK, but **not** `"foo" :"bar","bar":"baz"` or `"foo":"bar", "bar":"baz"`.

- The `"Authority: YEAR"` string is optional in the space around the colon. The year has to match the rule

  ```re
  ^\d{4}$|^\d{4} (\"|')\d{4}(\"|')$
  ```

- The validity of the taxon information is not checked.


## Reporting bugs

Please use the issue tracker here to report all bugs.

**If you find a security bug**, please practice responsible disclosure! Email `support@velociraptorsystems.com` with the issue. The administrative page uses a fork of [tigerhawkvok/php-userhandler](https://github.com/tigerhawkvok/php-userhandler), As appropriate, report bugs or offer pull requests on the right branch.


## Building the application


### Dependencies

This writeup assumes you have access to a Linux-like environment. If you run Windows, set up [Bash on Ubuntu on Windows (WSL)](https://msdn.microsoft.com/en-us/commandline/wsl/about) for best results.

Your life will also be a lot easier if you have [Homebrew](https://brew.sh/) or [LinuxBrew](http://linuxbrew.sh/) installed.


#### Build dependencies

- [Yarn](https://yarnpkg.com/lang/en/docs/cli/) You can install Yarn by running `brew install yarn`
- [Grunt](http://gruntjs.com/). You can install Grunt from the command line by running `yarn global install grunt-cli`.

#### Deploy dependencies

- [Blackbox](https://github.com/StackExchange/blackbox) You can install Blackbox by runing `brew install blackbox`


### Deploying

You can update the whole application, with dependencies, by running
`grunt build` at the root directory.

#### Installation

##### Configuration Files

If you're part of the project, your PGP public key should already be registered in the application. If you need to make changes, do:

```sh
blackbox_edit_start PATH/TO/FILE.ext.gpg
# Edit your file
blackbox_edit_end PATH/TO/FILE.ext
```

The two primary configuration files are `CONFIG.php.gpg` and `admin/CONFIG.php.gpg`.


##### Paths

Install this in the root directory of the
site. **If this is to be located elsewhere**, change the variable
`searchParams.targetApi` in `/coffee/search.coffee` and recompile the
coffeescript.

You can re-prepare the files by running `grunt compile` at the root directory.

### Setting up the database

Please see the documentation in [the `meta/` directory](https://github.com/tigerhawkvok/asm-mammal-database/tree/species_account_ui/meta).


#### Administration

You can access the administration / editing interface by logging in at
https://mammaldiversity.org/admin

If you create a user, an exisiting superuser will need to authorize your access. **You will not be able to log in or access the admin interface until this occurs**.

If you log in to another device / location, all other session credentials will be invalidated. [This occurs at API-level](https://github.com/tigerhawkvok/blob/master/asm-mammal-database/admin_api.php#L43-L48), and may require a re-login if your network location changes.
