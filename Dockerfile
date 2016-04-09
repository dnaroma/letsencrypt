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
RUN tee get_cert.sh << EOF \
    openssl genrsa 4096 > account.key \
    openssl genrsa 4096 > domain.key \
    openssl req -new -sha256 -key domain.key -subj "/CN=www.ilovelive.tk" > domain.csr \
    python /acme-tiny/acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir /var/www/challenges/ > ./signed.crt \
    curl -o intermediate.pem https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem \
    cat signed.crt intermediate.pem > chained.pem \
    openssl dhparam -out server.dhparam 4096 \
    EOF

VOLUME /acme-tiny

ENTRYPOINT ["/bin/bash"]
