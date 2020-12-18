# Base Container Definition: https://github.com/nginxinc/docker-nginx/tree/master/stable/alpine

FROM nginx:stable-alpine 
WORKDIR /

RUN apk update \
    && apk add --no-cache certbot certbot-nginx bash jq python3 py-pip util-linux \
    # Build and install Azure CLI
    && apk add --virtual azbuild gcc libffi-dev musl-dev openssl-dev python3-dev make \
    && pip3 install --upgrade pip \
    && pip3 install azure-cli \
    && apk del --purge azbuild \
    # Reset nginx log and error forwarding
    && ln -n /var/log/nginx/access.log \
    && ln -n /var/log/nginx/error.log \
    # Reset entrypoint and extension script
    && rm /docker-entrypoint.sh \
    && rm /docker-entrypoint.d/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-entrypoint.d/*.sh /docker-entrypoint.d/
COPY docker-runner.d/*.sh /docker-runner.d/

# Enable entrypoint and extension scripts (DONT try to combine multiple find operations)
RUN chmod +x /docker-entrypoint.sh
RUN find /docker-entrypoint.d/ -type f -iname "*.sh" -exec chmod +x {} \;
RUN find /docker-runner.d/ -type f -iname "*.sh" -exec chmod +x {} \;

# Replace nginx configuration files
COPY config/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD [ "" ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]