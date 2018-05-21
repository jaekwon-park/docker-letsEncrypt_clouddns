FROM certbot/dns-google
MAINTAINER jaekwon park <jaekwon.park@code-post.com>

VOLUME /etc/letsencrypt/archive/

ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache bash && \
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
