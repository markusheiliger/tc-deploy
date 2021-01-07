FROM markusheiliger/tcrunner:latest
WORKDIR /

ADD docker-wrapper.sh /usr/local/bin/docker-wrapper.sh

RUN apk --update add \
    bash \
    iptables \
    ca-certificates \
    e2fsprogs \
    docker \
    && chmod +x /usr/local/bin/docker-wrapper.sh \
    && rm -rf /var/cache/apk/*

RUN curl -sSL https://raw.githubusercontent.com/nektos/act/master/install.sh | sh 

COPY docker-runner.d/* /docker-runner.d/
RUN find /docker-runner.d/ -type f -iname "*.sh" -exec chmod +x {} \;

CMD [ "/docker-runner.d/act.sh" ]