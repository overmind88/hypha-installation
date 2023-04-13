#!/bin/bash

PASSPHRASE=mycesys

openssl dhparam -out ssl/ssl-dhparams.pem 2048

openssl genrsa -des3 -passout pass:${PASSPHRASE} -out ssl/privkey.pem 2048

openssl req -new -passin pass:${PASSPHRASE} -passout pass:${PASSPHRASE} -key ssl/privkey.pem -out ssl/fullchain.csr -config ssl/ssl.cfg

openssl x509 -req -passin pass:${PASSPHRASE} -in ssl/fullchain.csr -signkey ssl/privkey.pem -out ssl/fullchain.pem -days 3650 -sha256 -extfile ssl/v3.ext

openssl pkcs12 -export -passin pass:${PASSPHRASE} -passout pass:${PASSPHRASE} -in ssl/fullchain.pem -inkey ssl/privkey.pem -out ssl/identity.p12 -name "hypha"

cp selfsigned/options-ssl-nginx.conf ssl/options-ssl-nginx.conf
