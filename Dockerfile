FROM alpine:3.3

# Install letsencrypt, code forked from https://github.com/xataz/dockerfiles/blob/master/letsencrypt/Dockerfile
# replace letsencrypt-auto with acme-tiny

WORKDIR /acme-tiny
ENV PATH /acme-tiny/venv/bin:$PATH

RUN export BUILD_DEPS="git \
                build-base \
                libffi-dev \
                linux-headers \
                openssl-dev \
                py-pip \
                python-dev" \
    && apk add -U dialog \
                python \
                augeas-libs \
                openssl \
                ${BUILD_DEPS} \
    && pip --no-cache-dir install virtualenv \
    && git clone https://github.com/tangpei506/acme-tiny.git /acme-tiny \
    && git checkout patch-1 \
    && virtualenv --no-site-packages -p python2 /acme-tiny/venv \
    && /acme-tiny/venv/bin/pip install -r /acme-tiny/tests/requirements.txt \
    && apk del ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/*
    
# Set certificate, see https://github.com/diafygi/acme-tiny
RUN echo '#!/bin/sh' > get_cert.sh \
    && echo 'openssl genrsa 4096 > account.key' >> get_cert.sh \
    && echo 'openssl genrsa 4096 > domain.key' >> get_cert.sh \
    && echo 'openssl req -new -sha256 -key domain.key -subj "/CN=www.ilovelive.tk" > domain.csr' >> get_cert.sh \
    && echo 'python /acme-tiny/acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir /var/www/challenges/ > ./signed.crt' >> get_cert.sh \
    && echo 'curl -o intermediate.pem https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem' >> get_cert.sh \
    && echo 'cat signed.crt intermediate.pem > chained.pem' >> get_cert.sh \
    && echo 'openssl dhparam -out server.dhparam 4096' >> get_cert.sh \
    && echo 'cp *.* /var/www/challenges/' >> get_cert.sh \
    && chmod +x get_cert.sh

ENTRYPOINT ["/acme-tiny/get_cert.sh"]
