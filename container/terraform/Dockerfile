FROM markusheiliger/tcrunner:latest
WORKDIR /

RUN apk add terraform

COPY docker-deployment.sh /docker-deployment.sh
RUN chmod +x /docker-deployment.sh

CMD [ "/docker-deployment.sh" ]