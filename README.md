# letsencrypt
Dockerized letsencrypt with acme-tiny tools.

## How to use
use together with my repo `docker-cgssh:letsencrypt` to pass the verify of domain. Also remember to share the volume of `docker-cgssh:letsencrypt` which should be `/var/www/challenges`, or certs can't be written.

## Pay attention
Because of the slow duration of generating DH 4096, so it would take a long time to be finished.
