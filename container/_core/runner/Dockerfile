# Base Container Definition: https://github.com/nginxinc/docker-nginx/tree/master/stable/alpine

FROM nginx:stable-alpine 
WORKDIR /

RUN apk update && \
    apk add --no-cache bash jq python3 py-pip && \
    apk add --virtual azbuild gcc libffi-dev musl-dev openssl-dev python3-dev make && \
    pip3 install --upgrade pip && \
    pip3 install azure-cli && \
    apk del --purge azbuild && \
    # Reset entrypoint and extension script
    rm /docker-entrypoint.sh && \
    rm /docker-entrypoint.d/*

# Configure entrypoint and extension scripts
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-entrypoint.d/*.sh /docker-entrypoint.d/

# Enable entrypoint and extension scripts
RUN chmod +x /docker-entrypoint.sh && \
    find /docker-entrypoint.d/ -type f -iname "*.sh" -exec chmod +x {} \;

# Replace nginx configuration files
COPY config/default.conf /etc/nginx/conf.d/default.conf

CMD [ "" ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]