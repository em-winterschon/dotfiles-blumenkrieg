#!/bin/bash
## Name: shopify.convert-csv.sh
## Purpose: takes an OpenCart user database CSV export and converts it into Shopify's expected format
## Date: 2019-12-26

if [ $1 = "--help" ]; then
    cat<<EOF
Example format of expected CSV delimiters
-----------------------------------------
First Name,Last Name,Email,Company,Address1,Address2,City,Province,Province Code,Country,Country Code,Zip,Phone,Accepts Marketing,Total Spent,Total Orders,Tags,Note,Tax Exempt
John,Doe,john.doe@shopify.com,,123 Fake Street,,Ottawa,Ontario,ON,Canada,CA,a1b2c3,,no,100,1,,,yes

Incoming CSV format from OpenCart
lastname,firstname,email

EOF
fi

file="/home/mwinterschon/Downloads/OA-Customers_20190912-converted.csv"

cat $file | while read line; do
    echo $line | awk -F, '{print $2","$1","$3}' >> shopify-converted.output.csv
done

cat shopify-converted.output.csv | sort > shopify-converted.output_alpha-ordered.csv
echo "Converted file available here: shopify-converted.output_alpha-ordered.csv"
