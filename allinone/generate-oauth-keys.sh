#!/bin/bash

openssl genrsa -out oauth.key 2048
openssl pkcs8 -topk8 -in oauth.key -nocrypt -out oauth/keys/oauth
openssl rsa -in oauth/keys/oauth -outform PEM -pubout -out oauth/keys/oauth.pub
