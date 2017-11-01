# Qualys SSL Labs Checker

This bash script iterates through the provided url file and uses the Qualys SSL Labs API to check the grade rating of the HTTPS certificate. Next to console output, a HTML report is generated as "results_`date "+%Y-%m-%d_%H:%M:%S"`.html".

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


# Screenshots
![screenshot](https://i.imgur.com/rY59XIC.png)
![screenshot](https://i.imgur.com/qRe3AQz.png)


