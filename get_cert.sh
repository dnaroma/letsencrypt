#!/bin/sh
certdir=/var/www/challenges
if [-f "${certdir}/account.key"]
then
 echo 'key already existed'
else
 echo 'generate new key...'
 openssl genrsa 4096 > account.key
 openssl genrsa 4096 > domain.key
 openssl req -new -sha256 -key domain.key -subj "/CN=www.${DOMAIN_NAME}/CN=${DOMAIN_NAME}" > domain.csr
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
