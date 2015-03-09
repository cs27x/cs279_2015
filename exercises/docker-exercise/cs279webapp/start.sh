logstash-1.4.2/bin/logstash -f logstash.distributed.conf &
cd word-finder && /cs279/node-v0.12.0-linux-x64/bin/node server.js > word.log
