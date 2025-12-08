FROM node:22

USER root

WORKDIR /root

RUN mkdir lively4

RUN git clone -b gh-pages https://github.com/LivelyKernel/lively4-core.git /root/lively4/lively4-core
RUN git clone -b artifact https://github.com/hpi-swa-lab/sandblocks-text.git /root/lively4/sandblocks-text-artifact
RUN git clone -b v2 https://github.com/LivelyKernel/lively4-server.git /root/lively4-server

# dependencies
WORKDIR /root/lively4-server
RUN npm install

# Expose the server port
EXPOSE 9005

ENV TERM=xterm

CMD ["bash", "/root/lively4-server/bin/lively4L1.sh"]
