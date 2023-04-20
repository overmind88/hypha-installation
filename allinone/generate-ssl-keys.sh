#!/bin/bash

#Password for private key
PASSPHRASE=mycesys_ssl_pass

#Generate Diffie-Hellman (DH) key-exchange
openssl dhparam -out ssl/ssl-dhparams.pem 2048

#Generate private key
openssl genrsa -des3 -passout pass:${PASSPHRASE} -out ssl/privkey.pem 2048

#Generate SSL certificate
openssl req -new -passin pass:${PASSPHRASE} -passout pass:${PASSPHRASE} -key ssl/privkey.pem -out ssl/fullchain.csr -config ssl/ssl.cfg

#Add SAM parameters to certificate
openssl x509 -req -passin pass:${PASSPHRASE} -in ssl/fullchain.csr -signkey ssl/privkey.pem -out ssl/fullchain.pem -days 3650 -sha256 -extfile ssl/v3.ext

#Create pkcs12 keystore with certificate
openssl pkcs12 -export -passin pass:${PASSPHRASE} -passout pass:${PASSPHRASE} -in ssl/fullchain.pem -inkey ssl/privkey.pem -out ssl/identity.p12 -name "hypha"

#Copy nginx SSL options
cp selfsigned/options-ssl-nginx.conf ssl/options-ssl-nginx.conf

#Add private key password to nginx configuration file
echo "$PASSPHRASE" >> ssl/ssl_passwords
echo "ssl_password_file /etc/ssl/ssl_passwords;" >> ssl/options-ssl-nginx.conf
sed -i "s/mycesys_ssl_pass/$PASSPHRASE/" ./add-ssl-keys-to-jdk.sh
