#!/bin/bash
certdir=/var/www/challenges
if [ -f "${certdir}/account.key" ]
then
  echo '\033[31mkey already existed\033[0m'
else
  echo '\033[32mgenerate new key...\033[0m'
  openssl genrsa 4096 > account.key
  # secp256r1
  openssl ecparam -genkey -name secp256r1 | openssl ec -out domain.key
  openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:${DOMAIN_NAME},DNS:www.${DOMAIN_NAME}")) > domain.csr
  cp *.key ${certdir}
  cp domain.csr ${certdir}
  openssl dhparam -out server.dhparam 4096
  cp server.dhparam ${certdir}
fi
python /acme-tiny/acme_tiny.py --account-key ${certdir}/account.key --csr ${certdir}/domain.csr --acme-dir ${certdir} > ./signed.crt
curl -o intermediate.pem https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem
cat signed.crt intermediate.pem > chained.pem
rm intermediate.pem
cp chained.pem ${certdir}
echo 'successfully finished'
