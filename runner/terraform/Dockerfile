FROM hashicorp/terraform:light
WORKDIR /

RUN apk update && \
    apk add bash jq py-pip && \
    apk add --virtual azbuild gcc libffi-dev musl-dev openssl-dev python3-dev make && \
    pip install --upgrade pip && \
    pip install azure-cli && \
    apk del --purge azbuild

COPY runner.sh /teamcloud/runner
RUN chmod +x /teamcloud/runner
ENV PATH="/teamcloud:${PATH}"

ENTRYPOINT [ "runner" ]

