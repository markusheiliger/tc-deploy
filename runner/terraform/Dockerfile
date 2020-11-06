FROM hashicorp/terraform:light
WORKDIR /

RUN apk update && \
    apk add bash jq py-pip && \
    apk add --virtual azbuild gcc libffi-dev musl-dev openssl-dev python3-dev make && \
    pip install --upgrade pip && \
    pip install azure-cli && \
    apk del --purge azbuild

COPY runner.sh /terraform/runner
RUN chmod +x /terraform/runner
ENV PATH="/terraform:${PATH}"

ENTRYPOINT [ "runner" ]

