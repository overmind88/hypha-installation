#!/bin/bash

openssl dhparam -out ssl/ssl-dhparams.pem 2048
openssl req -x509 -nodes -days 365 -subj \
#/C=RU/ST=Moscow/L=Moscow/O=EXAMPLE/CN=localhost \
-newkey rsa:2048 -keyout ssl/privkey.pem \
-out ssl/fullchain.pem
