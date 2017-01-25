# Excel and Unicode

<!--
Based off the excellent README here:
http://support.mobileapptracking.com/entries/27347804-How-To-Import-a-Unicode-CSV-to-Excel
-->

When opening up a CSV file, Microsoft Excel will by default assume the text isn't Unicode. This means some non-english names will appear incorrectly formatted.

You'll have to jump through some hoops to get this to work correctly.

1. Open up Excel. From there, navigate to the "Data" tab, and in the "Get External Data" panel, click **From Text**
   <img src="https://raw.githubusercontent.com/SSARHERPS/SSAR-species-database/master/meta/excel_unicode_images/start_import.png" />

2. Navigate to and select your SSAR download in the resulting Open dialog

3. Mark that your data has **data headers**, is **delimited**, and, most importantly, that the **file origin** is `Unicode (UTF-8)`
   <img src="https://raw.githubusercontent.com/SSARHERPS/SSAR-species-database/master/meta/excel_unicode_images/set_import_params.png" />

4. Click **Next** to get to step 2 of the wizard.

5. Uncheck any delimiters other than **Comma**, and make sure **Comma** is checked.
   <img src="https://raw.githubusercontent.com/SSARHERPS/SSAR-species-database/master/meta/excel_unicode_images/set_import_delim.png" />

6. Click "Finish"

7. In the final resulting dialog, click **New Worksheet**, then **OK**
   <img src="https://raw.githubusercontent.com/SSARHERPS/SSAR-species-database/master/meta/excel_unicode_images/finalize_import.png" />

You'll be set!
