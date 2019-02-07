nightcrawler
============

Collects JavaScript from a list of sites on a daily basis.

`fetchall.sh`: Reads a list of sites, and for each one calls `fetchsite.sh`

`fetchsite.sh`: Performs a wget request on a specified site. Calls
`parse-html.py` to extract inline scripts from html files.

`parse-html.py`: Extracts inline scripts from html files using the `lxml`
package.
