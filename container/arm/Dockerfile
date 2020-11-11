FROM markusheiliger/tcrunner:latest
WORKDIR /

RUN apk update && \
    apk add bash jq py-pip && \
    apk add --virtual azbuild gcc libffi-dev musl-dev openssl-dev python3-dev make && \
    pip3 install --upgrade pip && \
    pip3 install azure-cli && \
    apk del --purge azbuild

COPY 50-run-deployment.sh /docker-entrypoint.d
