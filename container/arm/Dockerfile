FROM markusheiliger/tcrunner:latest
WORKDIR /

COPY docker-runner.d/*.sh /docker-runner.d/
RUN find /docker-runner.d/ -type f -iname "*.sh" -exec chmod +x {} \;