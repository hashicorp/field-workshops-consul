FROM mariadb:latest

RUN echo "Installing Consul onto database server."
RUN PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin apt -y update
RUN PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin apt -y install unzip wget
RUN wget https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip -O /tmp/consul.zip
RUN unzip /tmp/consul.zip -d /usr/local/bin
RUN chmod +x /usr/local/bin/consul
RUN mkdir -p /consul/config
RUN mkdir -p /consul/data