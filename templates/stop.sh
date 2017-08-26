#!/bin/bash

mytoken=$(curl --user "admin:{{ .product.adminPassword }}" -s http://localhost:{{ .product.http.port }}/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

curl --user "admin:{{ .product.adminPassword }}" -d "$mytoken" http://localhost:{{ .product.http.port }}/exit
