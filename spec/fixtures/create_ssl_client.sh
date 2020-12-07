#!/usr/bin/env bash

# Create Self-signed CA
openssl genrsa -out ca.key
# openssl genrsa -des3 -out ca.key
openssl req -x509 -new -key ca.key -out ca.crt -nodes -sha256 -days 3650 -subj "/C=US/L=Houston/OU=DEV/O=SSL Corp/CN=SSL Corp" -addext "nsCertType = sslCA, emailCA" -addext "keyUsage = cRLSign, keyCertSign, digitalSignature"
openssl x509 -text -noout -in ca.crt > ca.txt


# Create Server Certificate
openssl genrsa -out server.key
openssl req -new -key server.key -out server.csr -nodes -sha256 -subj "/C=US/L=Houston/OU=DEV/O=SSL Corp/CN=localhost"

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -sha256 -days 3650 -extfile <( echo "
basicConstraints = CA:FALSE
nsCertType = server
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer:always
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = localhost.localdomain
DNS.3 = lvh.me
DNS.4 = *.lvh.me
DNS.5 = *.ddns.net
DNS.6 = [::1]
IP.1 = 127.0.0.1
IP.2 = fe80::1
" )
openssl x509 -text -noout -in server.crt > server.txt


# Create Client Certificate
openssl genrsa -out client.key
openssl req -new -key client.key -out client.csr -nodes -subj "/C=US/L=Houston/OU=DEV/O=SSL Corp/CN=ssl/emailAddress=ssl@skeleton.xx"

openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 3650 -extfile <( echo "
basicConstraints = CA:FALSE
nsCertType = client, email
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
" )
openssl x509 -text -noout -in client.crt > client.txt

openssl pkcs12 -export -inkey client.key -in client.crt -certfile ca.crt -out client.p12 -nodes -passout pass:
openssl pkcs12 -info -in client.p12 -nodes -passin pass: > client.p12.txt
