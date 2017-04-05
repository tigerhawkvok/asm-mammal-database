

downloadCSVList = ->
  ###
  # Download a CSV file list
  #
  # See
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/39
  ###
  animateLoad()
  #filterArg = "eyJpc19hbGllbiI6MCwiYm9vbGVhbl90eXBlIjoib3IifQ"
  #args = "filter=#{filterArg}"
  args = "q=*"
  d = new Date()
  adjMonth = d.getMonth() + 1
  month = if adjMonth.toString().length is 1 then "0#{adjMonth}" else adjMonth
  day = if d.getDate().toString().length is 1 then "0#{d.getDate().toString()}" else d.getDate()
  dateString = "#{d.getUTCFullYear()}-#{month}-#{day}"
  $.get "#{searchParams.apiPath}", args, "json"
  .done (result) ->
    try
      unless result.status is true
        throw Error("Invalid Result")
      # Parse it all out
      csvBody = """
      """
      csvHeader = new Array()
      showColumn = [
        "genus"
        "species"
        "subspecies"
        "common_name"
        "image"
        "image_credit"
        "image_license"
        "major_type"
        "major_common_type"
        "major_subtype"
        "minor_type"
        "linnean_order"
        "genus_authority"
        "species_authority"
        "deprecated_scientific"
        "notes"
        "taxon_credit"
        "taxon_credit_date"
        ]
      makeTitleCase = [
        "genus"
        "common_name"
        "taxon_author"
        "major_subtype"
        "linnean_order"
        ]
      i = 0
      for k, row of result.result
        # Line by line ... do each result
        csvRow = new Array()
        if isNull(row.genus) then continue
        for dirtyCol, dirtyColData of row
          # Escape as per RFC4180
          # https://tools.ietf.org/html/rfc4180#page-2
          col = dirtyCol.replace(/"/g,'\"\"')
          colData = dirtyColData.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
          if i is 0
            # Do the headers
            if col in showColumn
              csvHeader.push col.replace(/_/g," ").toTitleCase()
          # Sitch together the row
          if col in showColumn
            # You'd want to naively push, but we can't
            # There are formatting rules to observe
            # Deal with authorities
            if /[a-z]+_authority/.test(col)
              try
                authorityYears = JSON.parse(row.authority_year)
                genusYear = ""
                speciesYear = ""
                for k,v of authorityYears
                  genusYear = k.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
                  speciesYear = v.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
                switch col.split("_")[0]
                  when "genus"
                    tempCol = "#{colData.toTitleCase()} #{genusYear}"
                    if toInt(row.parens_auth_genus).toBool()
                      tempCol = "(#{tempCol})"
                  when "species"
                    tempCol = "#{colData.toTitleCase()} #{speciesYear}"
                    if toInt(row.parens_auth_species).toBool()
                      tempCol = "(#{tempCol})"
                colData = tempCol
                # if "\"Plestiodon\"" in csvRow and "\"egregius\"" in csvRow
                #   console.log("Plestiodon: Working with",csvRow,"inserting",tempCol)
              catch e
                # Bad authority year, just don't use it
            if col in makeTitleCase
              colData = colData.toTitleCase()
            if col is "image" and not isNull(colData)
              colData = "http://mammaldiversity.org/cndb/#{colData}"
            # Done with formatting, push it
            csvRow.push "\"#{colData}\""
        # Increment the row counter
        i++
        csvLiteralRow = csvRow.join(",")
        # if "\"Plestiodon\"" in csvRow and "\"egregius\"" in csvRow
        #   console.log("Plestiodon: Working with",csvRow,csvLiteralRow)
        csvBody +="""

        #{csvLiteralRow}
        """
      csv = """
      #{csvHeader.join(",")}
      #{csvBody}
      """
      # OK, it's all been created. Download it.
      downloadable = "data:text/csv;charset=utf-8," + encodeURIComponent(csv)
      html = """
      <paper-dialog class="download-file" id="download-csv-file" modal>
        <h2>Your file is ready</h2>
        <paper-dialog-scrollable class="dialog-content">
          <p>
            Please note that some special characters in names may be decoded incorrectly by Microsoft Excel. If this is a problem, following the steps in <a href="https://github.com/SSARHERPS/SSAR-species-database/blob/master/meta/excel_unicode_readme.md"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>this README <iron-icon icon="launch"></iron-icon></a> to force Excel to format it correctly.
          </p>
          <p class="text-center">
            <a href="#{downloadable}" download="asm-common-names-#{dateString}.csv" class="btn btn-default"><iron-icon icon="file-download"></iron-icon> Download Now</a>
          </p>
        </paper-dialog-scrollable>
        <div class="buttons">
          <paper-button dialog-dismiss>Close</paper-button>
        </div>
      </paper-dialog>
      """
      unless $("#download-csv-file").exists()
        $("body").append(html)
      else
        $("#download-csv-file").replaceWith(html)
      $("#download-chooser").get(0).close()
      safariDialogHelper("#download-csv-file")
    catch e
      stopLoadError("There was a problem creating the CSV file. Please try again later.")
      console.error("Exception in downloadCSVList() - #{e.message}")
      console.warn("Got",result,"from","#{searchParams.apiPath}?#{args}", result.status)
  .fail ->
    stopLoadError("There was a problem communicating with the server. Please try again later.")
  false




downloadHTMLList = ->
  ###
  # Download a HTML file list
  #
  # We want to set this up to look similar to the published list
  # http://mammaldiversity.org/wp-content/uploads/2014/07/HC_39_7thEd.pdf
  # Starting with page 11
  #
  # Configured Bootstrap:
  # https://gist.github.com/e14c62a4d4eee8f40b6b
  #
  # Bootstrap Config Link:
  # http://getbootstrap.com/customize/?id=e14c62a4d4eee8f40b6b
  #
  # See
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/40
  ###
  animateLoad()
  d = new Date()
  adjMonth = d.getMonth() + 1
  month = if adjMonth.toString().length is 1 then "0#{adjMonth}" else adjMonth
  day = if d.getDate().toString().length is 1 then "0#{d.getDate().toString()}" else d.getDate()
  dateString = "#{d.getUTCFullYear()}-#{month}-#{day}"
  htmlBody = """
      <!doctype html>
      <html lang="en">
        <head>
          <title>SSAR Common Names Checklist ver. #{dateString}</title>
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta charset="UTF-8"/>
          <meta name="theme-color" content="#445e14"/>
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <link href='http://fonts.googleapis.com/css?family=Droid+Serif:400,700,700italic,400italic|Roboto+Slab:400,700' rel='stylesheet' type='text/css' />
          <style type="text/css" id="asm-checklist-inline-stylesheet">
/*!
 * Bootstrap v3.3.5 (http://getbootstrap.com)
 * Copyright 2011-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 */

/*!
 * Generated using the Bootstrap Customizer (http://getbootstrap.com/customize/?id=e14c62a4d4eee8f40b6b)
 * Config saved to config.json and https://gist.github.com/e14c62a4d4eee8f40b6b
 *//*!
 * Bootstrap v3.3.5 (http://getbootstrap.com)
 * Copyright 2011-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 *//*! normalize.css v3.0.3 | MIT License | github.com/necolas/normalize.css */html{font-family:sans-serif;-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}body{margin:0}article,aside,details,figcaption,figure,footer,header,hgroup,main,menu,nav,section,summary{display:block}audio,canvas,progress,video{display:inline-block;vertical-align:baseline}audio:not([controls]){display:none;height:0}[hidden],template{display:none}a{background-color:transparent}a:active,a:hover{outline:0}abbr[title]{border-bottom:1px dotted}b,strong{font-weight:bold}dfn{font-style:italic}h1{font-size:2em;margin:0.67em 0}mark{background:#ff0;color:#000}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sup{top:-0.5em}sub{bottom:-0.25em}img{border:0}svg:not(:root){overflow:hidden}figure{margin:1em 40px}hr{-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;height:0}pre{overflow:auto}code,kbd,pre,samp{font-family:monospace, monospace;font-size:1em}button,input,optgroup,select,textarea{color:inherit;font:inherit;margin:0}button{overflow:visible}button,select{text-transform:none}button,html input[type="button"],input[type="reset"],input[type="submit"]{-webkit-appearance:button;cursor:pointer}button[disabled],html input[disabled]{cursor:default}button::-moz-focus-inner,input::-moz-focus-inner{border:0;padding:0}input{line-height:normal}input[type="checkbox"],input[type="radio"]{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding:0}input[type="number"]::-webkit-inner-spin-button,input[type="number"]::-webkit-outer-spin-button{height:auto}input[type="search"]{-webkit-appearance:textfield;-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box}input[type="search"]::-webkit-search-cancel-button,input[type="search"]::-webkit-search-decoration{-webkit-appearance:none}fieldset{border:1px solid #c0c0c0;margin:0 2px;padding:0.35em 0.625em 0.75em}legend{border:0;padding:0}textarea{overflow:auto}optgroup{font-weight:bold}table{border-collapse:collapse;border-spacing:0}td,th{padding:0}/*! Source: https://github.com/h5bp/html5-boilerplate/blob/master/src/css/main.css */@media print{*,*:before,*:after{background:transparent !important;color:#000 !important;-webkit-box-shadow:none !important;box-shadow:none !important;text-shadow:none !important}a,a:visited{text-decoration:underline}a[href]:after{content:" (" attr(href) ")"}abbr[title]:after{content:" (" attr(title) ")"}a[href^="#"]:after,a[href^="javascript:"]:after{content:""}pre,blockquote{border:1px solid #999;page-break-inside:avoid}thead{display:table-header-group}tr,img{page-break-inside:avoid}img{max-width:100% !important}p,h2,h3{orphans:3;widows:3}h2,h3{page-break-after:avoid}.navbar{display:none}.btn>.caret,.dropup>.btn>.caret{border-top-color:#000 !important}.label{border:1px solid #000}.table{border-collapse:collapse !important}.table td,.table th{background-color:#fff !important}.table-bordered th,.table-bordered td{border:1px solid #ddd !important}}*{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}*:before,*:after{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}html{font-size:10px;-webkit-tap-highlight-color:rgba(0,0,0,0)}body{font-family:"Roboto Slab","Droid Serif",Cambria,Georgia,"Times New Roman",Times,serif;font-size:14px;line-height:1.42857143;color:#333;background-color:#fff}input,button,select,textarea{font-family:inherit;font-size:inherit;line-height:inherit}a{color:#337ab7;text-decoration:none}a:hover,a:focus{color:#23527c;text-decoration:underline}a:focus{outline:thin dotted;outline:5px auto -webkit-focus-ring-color;outline-offset:-2px}figure{margin:0}img{vertical-align:middle}.img-responsive{display:block;max-width:100%;height:auto}.img-rounded{border-radius:6px}.img-thumbnail{padding:4px;line-height:1.42857143;background-color:#fff;border:1px solid #ddd;border-radius:4px;-webkit-transition:all .2s ease-in-out;-o-transition:all .2s ease-in-out;transition:all .2s ease-in-out;display:inline-block;max-width:100%;height:auto}.img-circle{border-radius:50%}hr{margin-top:20px;margin-bottom:20px;border:0;border-top:1px solid #eee}.sr-only{position:absolute;width:1px;height:1px;margin:-1px;padding:0;overflow:hidden;clip:rect(0, 0, 0, 0);border:0}.sr-only-focusable:active,.sr-only-focusable:focus{position:static;width:auto;height:auto;margin:0;overflow:visible;clip:auto}[role="button"]{cursor:pointer}h1,h2,h3,h4,h5,h6,.h1,.h2,.h3,.h4,.h5,.h6{font-family:inherit;font-weight:500;line-height:1.1;color:inherit}h1 small,h2 small,h3 small,h4 small,h5 small,h6 small,.h1 small,.h2 small,.h3 small,.h4 small,.h5 small,.h6 small,h1 .small,h2 .small,h3 .small,h4 .small,h5 .small,h6 .small,.h1 .small,.h2 .small,.h3 .small,.h4 .small,.h5 .small,.h6 .small{font-weight:normal;line-height:1;color:#777}h1,.h1,h2,.h2,h3,.h3{margin-top:20px;margin-bottom:10px}h1 small,.h1 small,h2 small,.h2 small,h3 small,.h3 small,h1 .small,.h1 .small,h2 .small,.h2 .small,h3 .small,.h3 .small{font-size:65%}h4,.h4,h5,.h5,h6,.h6{margin-top:10px;margin-bottom:10px}h4 small,.h4 small,h5 small,.h5 small,h6 small,.h6 small,h4 .small,.h4 .small,h5 .small,.h5 .small,h6 .small,.h6 .small{font-size:75%}h1,.h1{font-size:36px}h2,.h2{font-size:30px}h3,.h3{font-size:24px}h4,.h4{font-size:18px}h5,.h5{font-size:14px}h6,.h6{font-size:12px}p{margin:0 0 10px}.lead{margin-bottom:20px;font-size:16px;font-weight:300;line-height:1.4}@media (min-width:768px){.lead{font-size:21px}}small,.small{font-size:85%}mark,.mark{background-color:#fcf8e3;padding:.2em}.text-left{text-align:left}.text-right{text-align:right}.text-center{text-align:center}.text-justify{text-align:justify}.text-nowrap{white-space:nowrap}.text-lowercase{text-transform:lowercase}.text-uppercase{text-transform:uppercase}.text-capitalize{text-transform:capitalize}.text-muted{color:#777}.text-primary{color:#337ab7}a.text-primary:hover,a.text-primary:focus{color:#286090}.text-success{color:#3c763d}a.text-success:hover,a.text-success:focus{color:#2b542c}.text-info{color:#31708f}a.text-info:hover,a.text-info:focus{color:#245269}.text-warning{color:#8a6d3b}a.text-warning:hover,a.text-warning:focus{color:#66512c}.text-danger{color:#a94442}a.text-danger:hover,a.text-danger:focus{color:#843534}.bg-primary{color:#fff;background-color:#337ab7}a.bg-primary:hover,a.bg-primary:focus{background-color:#286090}.bg-success{background-color:#dff0d8}a.bg-success:hover,a.bg-success:focus{background-color:#c1e2b3}.bg-info{background-color:#d9edf7}a.bg-info:hover,a.bg-info:focus{background-color:#afd9ee}.bg-warning{background-color:#fcf8e3}a.bg-warning:hover,a.bg-warning:focus{background-color:#f7ecb5}.bg-danger{background-color:#f2dede}a.bg-danger:hover,a.bg-danger:focus{background-color:#e4b9b9}.page-header{padding-bottom:9px;margin:40px 0 20px;border-bottom:1px solid #eee}ul,ol{margin-top:0;margin-bottom:10px}ul ul,ol ul,ul ol,ol ol{margin-bottom:0}.list-unstyled{padding-left:0;list-style:none}.list-inline{padding-left:0;list-style:none;margin-left:-5px}.list-inline>li{display:inline-block;padding-left:5px;padding-right:5px}dl{margin-top:0;margin-bottom:20px}dt,dd{line-height:1.42857143}dt{font-weight:bold}dd{margin-left:0}@media (min-width:768px){.dl-horizontal dt{float:left;width:160px;clear:left;text-align:right;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.dl-horizontal dd{margin-left:180px}}abbr[title],abbr[data-original-title]{cursor:help;border-bottom:1px dotted #777}.initialism{font-size:90%;text-transform:uppercase}blockquote{padding:10px 20px;margin:0 0 20px;font-size:17.5px;border-left:5px solid #eee}blockquote p:last-child,blockquote ul:last-child,blockquote ol:last-child{margin-bottom:0}blockquote footer,blockquote small,blockquote .small{display:block;font-size:80%;line-height:1.42857143;color:#777}blockquote footer:before,blockquote small:before,blockquote .small:before{content:'\x2014 \x00A0'}.blockquote-reverse,blockquote.pull-right{padding-right:15px;padding-left:0;border-right:5px solid #eee;border-left:0;text-align:right}.blockquote-reverse footer:before,blockquote.pull-right footer:before,.blockquote-reverse small:before,blockquote.pull-right small:before,.blockquote-reverse .small:before,blockquote.pull-right .small:before{content:''}.blockquote-reverse footer:after,blockquote.pull-right footer:after,.blockquote-reverse small:after,blockquote.pull-right small:after,.blockquote-reverse .small:after,blockquote.pull-right .small:after{content:'\x00A0 \x2014'}address{margin-bottom:20px;font-style:normal;line-height:1.42857143}.clearfix:before,.clearfix:after,.dl-horizontal dd:before,.dl-horizontal dd:after{content:" ";display:table}.clearfix:after,.dl-horizontal dd:after{clear:both}.center-block{display:block;margin-left:auto;margin-right:auto}.pull-right{float:right !important}.pull-left{float:left !important}.hide{display:none !important}.show{display:block !important}.invisible{visibility:hidden}.text-hide{font:0/0 a;color:transparent;text-shadow:none;background-color:transparent;border:0}.hidden{display:none !important}.affix{position:fixed}
           /* Manual Overrides */
           .sciname {
             font-style: italic;
             }
           .entry-sciname {
             font-style: italic;
             font-weight: bold;
             }
            body { padding: 1rem; }
            .species-entry aside:first-child {
              margin-top: 5rem;
              }
            section .entry-header {
              text-indent: 2em;
              }
            .clade-declaration {
              font-variant: small-caps;
              border-top: 1px solid #000;
              border-bottom: 1px solid #000;
              page-break-before: always;
              break-before: always;
              }
            .species-entry {
              page-break-inside: avoid;
              break-inside: avoid;
              }
            @media print {
              body {
                font-size:12px;
                }
              .h4 {
                font-size: 13px;
                }
              @page {
                counter-increment: page;
                /*counter-reset: page 1;*/
                 @bottom-right {
                  content: counter(page);
                 }
                 /* margin: 0px auto; */
                }
            }
          </style>
        </head>
        <body>
          <div class="container-fluid">
            <article>
              <h1 class="text-center">SSAR Common Names Checklist ver. #{dateString}</h1>
  """
  args = "q=*&order=linnean_order,genus,species,subspecies"
  $.get "#{searchParams.apiPath}", args, "json"
  .done (result) ->
    try
      unless result.status is true
        throw Error("Invalid Result")
      ###
      # Let's work with each result
      #
      # We're going to construct an entry for each, then go through
      # and append that to to the text blobb htmlBody
      ###
      hasReadGenus = new Array()
      hasReadClade = new Array()
      for k, row of result.result
        if isNull(row.genus) or isNull(row.species)
          # Skip this clearly unfinished entry
          continue
        # Prep the authorities
        try
          authorityYears = JSON.parse(row.authority_year)
          genusYear = ""
          speciesYear = ""
          for c,v of authorityYears
            genusYear = c.replace(/&#39;/g,"'")
            speciesYear = v.replace(/&#39;/g,"'")
          genusAuth = "#{row.genus_authority.toTitleCase()} #{genusYear}"
          if toInt(row.parens_auth_genus).toBool()
            genusAuth = "(#{genusAuth})"
          speciesAuth = "#{row.species_authority.toTitleCase()} #{speciesYear}"
          if toInt(row.parens_auth_species).toBool()
            speciesAuth = "(#{speciesAuth})"
        catch e
          # There was a data problem for the authority year!
          # However, we want it to be non-fatal.
          console.warn("There was a problem parsing the authority information for _#{row.genus} #{row.species} #{row.subspecies}_ - #{e.message}")
          console.warn(e.stack)
          console.warn("We were working with",authorityYears,genusYear,genusAuth,speciesYear, speciesAuth)
        try
          htmlNotes = markdown.toHTML(row.notes)
        catch e
          console.warn("Unable to parse Markdown for _#{row.genus} #{row.species} #{row.subspecies}_")
          htmlNotes = row.notes
        htmlCredit = ""
        unless isNull(htmlNotes) or isNull(row.taxon_credit)
          taxonCreditDate = ""
          unless isNull(row.taxon_credit_date)
            taxonCreditDate = ", #{row.taxon_credit_date}"
          htmlCredit = """
            <p class="text-right small text-muted">
              <cite>
                #{row.taxon_credit}#{taxonCreditDate}
              </cite>
            </p>
          """
        # Now for each result, we want to create a text blob
        oneOffHtml = ""
        unless row.linnean_order.trim() in hasReadClade
          oneOffHtml += """
          <h2 class="clade-declaration text-capitalize text-center">#{row.linnean_order} &#8212; #{row.major_common_type}</h2>
          """
          hasReadClade.push row.linnean_order.trim()
        unless row.genus in hasReadGenus
          # Show the genus header
          oneOffHtml += """
          <aside class="genus-declaration lead">
            <span class="entry-sciname text-capitalize">#{row.genus}</span>
            <span class="entry-authority">#{genusAuth}</span>
          </aside>
          """
          hasReadGenus.push row.genus
        shortGenus = "#{row.genus.slice(0,1)}. "
        entryHtml = """
        <section class="species-entry">
          #{oneOffHtml}
          <p class="h4 entry-header">
            <span class="entry-sciname">
              <span class="text-capitalize">#{shortGenus}</span> #{row.species} #{row.subspecies}
            </span>
            <span class="entry-authority">
              #{speciesAuth}
            </span>
            &#8212;
            <span class="common_name no-cap">
              #{smartUpperCasing row.common_name}
            </span>
          </p>
          <div class="entry-content">
            #{htmlNotes}
            #{htmlCredit}
          </div>
        </section>
        """
        # Append it to htmlBody
        htmlBody += entryHtml
        ## End for loop
      # Now let's close up that HTML file
      htmlBody += """
      </article>
      </div>
      </body>
      </html>
      """
      downloadable = "data:text/html;charset=utf-8,#{encodeURIComponent(htmlBody)}"
      dialogHtml = """
      <paper-dialog  modal class="download-file" id="download-html-file">
        <h2>Your file is ready</h2>
        <paper-dialog-scrollable class="dialog-content">
          <p class="text-center">
            <a href="#{downloadable}" download="asm-common-names-#{dateString}.html" class="btn btn-default"><iron-icon icon="file-download"></iron-icon> Download Now</a>
          </p>
        </paper-dialog-scrollable>
        <div class="buttons">
          <paper-button dialog-dismiss>Close</paper-button>
        </div>
      </paper-dialog>
      """
      unless $("#download-html-file").exists()
        $("body").append(dialogHtml)
      else
        $("#download-html-file").replaceWith(dialogHtml)
      $("#download-chooser").get(0).close()
      safariDialogHelper("#download-html-file")
      $.post "pdf/pdfwrapper.php", "html=#{encodeURIComponent(htmlBody)}", "json"
      .done (result) ->
        console.debug "PDF result", result
        if result.status
          pdfDownloadPath = "#{uri.urlString}#{result.file}"
          console.debug pdfDownloadPath
        else
          console.error "Couldn't make PDF file"
        false
      .error (result, status) ->
        console.error "Wasn't able to fetch PDF"
    catch e
      stopLoadError("There was a problem creating your file. Please try again later.")
      console.error("Exception in downloadHTMLList() - #{e.message}")
      console.warn("Got",result,"from","#{searchParams.apiPath}?#{args}", result.status)
      console.warn(e.stack)
  .fail  ->
    stopLoadError("There was a problem communicating with the server. Please try again later.")
  false

showDownloadChooser = ->
  html = """
  <paper-dialog id="download-chooser" modal>
    <h2>Select Download Type</h2>
    <paper-dialog-scrollable class="dialog-content">
      <p>
        Once you select a file type, it will take a moment to prepare your download. Please be patient.
      </p>
    </paper-dialog-scrollable>
    <div class="buttons">
      <paper-button dialog-dismiss>Cancel</paper-button>
      <paper-button dialog-confirm id="initiate-csv-download">CSV</paper-button>
      <paper-button dialog-confirm id="initiate-html-download">HTML</paper-button>
    </div>
  </paper-dialog>
  """
  unless $("#download-chooser").exists()
    $("body").append(html)
  d$("#initiate-csv-download").click ->
    downloadCSVList()
  d$("#initiate-html-download").click ->
    downloadHTMLList()
  safariDialogHelper("#download-chooser")
  false
