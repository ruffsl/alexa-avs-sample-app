FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
      curl \
      --no-install-recommends && \
    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y \
      build-essential \
      byobu \
      git \
      libcanberra-gtk3-module \
      maven \
      nodejs-legacy \
      npm \
      openjdk-8-jdk \
      openssl \
      supervisor \
      vlc && \
    rm -rf /var/lib/apt/lists/*

# Setup VLC env vars
ENV LD_LIBRARY_PATH=/usr/lib/vlc
ENV VLC_PLUGIN_PATH=/usr/lib/vlc/plugins

ENV ALEXA_HOME /opt/alexa
ENV ALEXA_HOME_ESCAPED "\/opt\/alexa"
RUN mkdir -p ${ALEXA_HOME}
WORKDIR ${ALEXA_HOME}

# Pull down the alexa files from github
RUN git clone https://github.com/amzn/alexa-avs-raspberry-pi.git ${ALEXA_HOME}

ENV ProductID=my_device
ENV ClientID=
ENV ClientSecret=
ENV ClientSerial=123456

# CERTIFICATE STUFF
RUN chmod +x samples/javaclient/generate.sh && \
    chmod +x samples/javaclient/install-java8.sh && \
    sed -i -e 's/YOUR_COUNTRY_NAME/US/g' samples/javaclient/ssl.cnf && \
    sed -i -e 's/YOUR_STATE_OR_PROVINCE/MD/g' samples/javaclient/ssl.cnf && \
    sed -i -e 's/YOUR_CITY/BALTIMORE/g' samples/javaclient/ssl.cnf && \
    sed -i -e 's/YOUR_ORGANIZATION/foo/g' samples/javaclient/ssl.cnf && \
    sed -i -e 's/YOUR_ORGANIZATIONAL_UNIT/bar/g' samples/javaclient/ssl.cnf && \
    cat samples/javaclient/ssl.cnf

RUN echo ${ProductID}'\n\
'${ClientSerial}'\n\
\n'\
> temp.txt && \
samples/javaclient/generate.sh < temp.txt && \
rm temp.txt

# modify Config.js
RUN sed -i -e "s/sslKey: \x27/sslKey: \x27${ALEXA_HOME_ESCAPED}\/samples\/javaclient\/certs\/server\/node.key/g" samples/companionService/config.js && \
    sed -i -e "s/sslCert: \x27/sslCert: \x27${ALEXA_HOME_ESCAPED}\/samples\/javaclient\/certs\/server\/node.crt/g" samples/companionService/config.js && \
    sed -i -e "s/sslCaCert: \x27/sslCaCert: \x27${ALEXA_HOME_ESCAPED}\/samples\/javaclient\/certs\/ca\/ca.crt/g" samples/companionService/config.js && \
    cat samples/companionService/config.js
# modify Config.json
RUN sed -i -e 's/"sslClientKeyStore":""/"sslClientKeyStore":"'${ALEXA_HOME_ESCAPED}'\/samples\/javaclient\/certs\/client\/client.pkcs12"/g' samples/javaclient/config.json && \
    sed -i -e 's/"sslKeyStore":""/"sslKeyStore":"'${ALEXA_HOME_ESCAPED}'\/samples\/javaclient\/certs\/server\/jetty.pkcs12"/g' samples/javaclient/config.json && \
    sed -i -e 's/"sslCaCert":""/"sslCaCert":"'${ALEXA_HOME_ESCAPED}'\/samples\/javaclient\/certs\/ca\/ca.crt"/g' samples/javaclient/config.json && \
    sed -i -e 's/"productId":""/"productId":"'${ProductID}'"/g' samples/javaclient/config.json && \
    sed -i -e 's/"dsn":""/"dsn":"'${ClientSerial}'"/g' samples/javaclient/config.json && \
    sed -i -e 's/"provisioningMethod":""/"provisioningMethod":"companionService"/g' samples/javaclient/config.json && \
    cat samples/javaclient/config.json

# modify Config.js
RUN sed -i -e "s/clientId: \x27/clientId: \x27${ClientID}/g" samples/companionService/config.js && \
    sed -i -e "s/clientSecret: \x27/clientSecret: \x27${ClientSecret}/g" samples/companionService/config.js && \
    sed -i -e 's/\x22\x22\x3A.*/\x22'${ProductID}'\x22\x3A \x5B\x22'${ClientSerial}'\x22\x5D/g' samples/companionService/config.js && \
    cat samples/companionService/config.js

WORKDIR ${ALEXA_HOME}/samples/companionService
RUN npm install

WORKDIR ${ALEXA_HOME}/samples/javaclient
RUN mvn validate
RUN mvn install

WORKDIR ${ALEXA_HOME}
RUN cd samples/companionService && \
    npm start & \
    cd samples/javaclient && \
    mvn validate

# Setup the supervisord
# COPY supervisor.cnf /etc/supervisor.cnf
# CMD ["supervisord","-c","/etc/supervisor.cnf"]
