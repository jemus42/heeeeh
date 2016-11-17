# heeeeh

Trying to get all the valid EBM codes from [KBV](http://www.kbv.de/) into a machine-readable table.

This is a horrible pain in the butt and I sincerely hope it's unecessary someday.

## Possible data sources:

- "Offline EBM": ZIP file here: <http://www.kbv.de/html/85.php>
- PDFs from here: <http://www.kbv.de/html/arztgruppen_ebm.php#content2398>

## Current state

Currently this code uses the "Offline-Version des EBM" from the KBV site: <http://www.kbv.de/html/85.php>.

The code in `ebm_html.R` then looks through the downloaded file, takes all the `.html` files that contain EBM data, parses them, put's them in a `data.frame` and writes both a `.csv` file and an `.rds` file for easy import in other projects.

There are still some duplicates, but they're easier to deal with than missing codes.
