FROM markusheiliger/tcrunner:latest
WORKDIR /

RUN apk add terraform

COPY docker-runner.d/*.sh /docker-runner.d/
RUN find /docker-runner.d/ -type f -iname "*.sh" -exec chmod +x {} \;