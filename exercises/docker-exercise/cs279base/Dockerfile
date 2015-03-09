FROM dockerfile/java:oracle-java8
WORKDIR /cs279
ADD . /cs279
ADD http://nodejs.org/dist/v0.12.0/node-v0.12.0-linux-x64.tar.gz node-v0.12.0-linux-x64.tar.gz
RUN tar -xvf node-v0.12.0-linux-x64.tar.gz
ENV PATH=$PATH:/cs279/node-v0.12.0-linux-x64/bin
ADD https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz /logstash.tar.gz
RUN tar -xvf /logstash.tar.gz
