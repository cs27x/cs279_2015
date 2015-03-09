FROM cs279base 
WORKDIR /cs279
ADD . /cs279
RUN git clone https://github.com/cs27x/word-finder.git 
RUN cd word-finder && npm install
CMD /cs279/start.sh 
EXPOSE 3000
