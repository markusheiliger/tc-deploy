FROM markusheiliger/tcrunner:latest
WORKDIR /

RUN curl -o- 'https://raw.githubusercontent.com/nektos/act/master/install.sh' | bash  

COPY docker-runner.d/* /docker-runner.d/
RUN find /docker-runner.d/ -type f -iname "*.sh" -exec chmod +x {} \;

CMD [ "/docker-runner.d/act.sh" ]