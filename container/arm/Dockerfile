FROM markusheiliger/tcrunner:latest
WORKDIR /

COPY docker-deployment.sh /docker-deployment.sh
RUN chmod +x /docker-deployment.sh

CMD [ "/docker-deployment.sh" ]