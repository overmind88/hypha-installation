mkdir -p certs

openssl dhparam -out certs/dhparam.pem 2048
openssl req -x509 -nodes -days 365 -subj \
/C=RU/ST=Moscow/L=Moscow/O=EXAMPLE/CN=localhost \
-newkey rsa:2048 -keyout certs/nginx-selfsigned.key \
-out certs/nginx-selfsigned.crt
