FROM mcr.microsoft.com/azure-cli:latest
WORKDIR /

RUN apk update && \
    apk add openrc bash jq nginx

COPY templates /etc/nginx/sites-enabled/templates

COPY runner.sh /teamcloud/runner
RUN chmod +x /teamcloud/runner
ENV PATH="/teamcloud:${PATH}"

ENTRYPOINT [ "runner" ]

