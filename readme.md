# Qualys SSL Labs Checker
consoleSSLlabs enables you to run multiple Qualys SSL Labs scans in an automated manner.
Next to the console output, a HTML report is generated as "results_`date "+%Y-%m-%d_%H:%M:%S"`.html".

# Usage
Run on any Unix system with CURL installed as such:
```sh
$  ./consoleSSLlabs urlfile
```
The url file must use the following format:
* One line only
* urls seperated by semicolon ;

Example:
www.github.com;www.arstechnica.com;nvd.nist.gov;


# Example Output
![screenshot](https://i.imgur.com/SZFkbnp.png)

# HTML Report
![screenshot](https://i.imgur.com/3K0yfpH.png)


