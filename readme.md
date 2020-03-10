# Qualys SSL Labs Checker
consoleSSLlabs enables you to run multiple Qualys SSL Labs scans in an automated manner.
Next to the console output, a HTML report is generated as "results_`date "+%Y-%m-%d_%H:%M:%S"`.html".

# Usage
Run on any Unix system with CURL installed as such:
```
Usage: consoleSSLlabs.sh [OPTIONS]
  [OPTIONS]:
  -U URLS           Path to file containing the URLs to be scanned, use ; as delimiter (required)
  -O OUTPUT         Output file (HTML report) (default: results_%Y-%m-%d_%H:%M:%S.html)
  -V VERBOSE        Use verbose output
```
# URL File
The url file must use the following format:
* One line only
* urls seperated by semicolon ;

Example:
www.github.com;www.arstechnica.com;nvd.nist.gov;


# Example Output
![screenshot](https://i.imgur.com/SZFkbnp.png)

# HTML Report
![screenshot](https://i.imgur.com/3K0yfpH.png)


