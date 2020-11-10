FROM mcr.microsoft.com/azure-cli:latest
WORKDIR /

RUN apk update && \
    apk add bash jq nginx

COPY templates /etc/nginx/sites-enabled/templates

COPY runner.sh /runner
RUN chmod +x /runner

ENTRYPOINT [ "runner" ]

