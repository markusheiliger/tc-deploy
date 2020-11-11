FROM mcr.microsoft.com/azure-cli:latest
WORKDIR /

COPY watch.sh /watch
RUN chmod +x /watch

ENTRYPOINT [ "watch" ]

