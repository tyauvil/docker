FROM openjdk:8-jdk

ENV JENKINS_URL=http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war \
    JENKINS_HOME=/var/jenkins_home \
    JENKINS_SLAVE_AGENT_PORT=50000 \
    COPY_REFERENCE_FILE_LOG=$JENKINS_HOME/copy_reference_file.log \
    USERNAME=jenkins \
    PUID=1000 \
    PGID=1000 \
    JENKINS_UC=https://updates.jenkins.io \
    DUMB_VERSION=1.1.3 \
    GOSU_VERSION=1.10

ADD https://github.com/Yelp/dumb-init/releases/download/v${DUMB_VERSION}/dumb-init_${DUMB_VERSION}_amd64 /bin/dumb-init
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /bin/gosu
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
COPY files/bin/* /usr/local/bin/

RUN apt-get update && \
    apt-get install -y git curl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/jenkins/ref/init.groovy.d && \
    curl -kLo /usr/share/jenkins/jenkins.war "${JENKINS_URL}" && \
    cd /bin && \
    curl -kL https://github.com/ncopa/su-exec/archive/v0.2.tar.gz | tar xz && \
    mv /bin/su-exec-0.2 /bin/su-exec && \
    chmod +x /bin/docker-entrypoint.sh /bin/dumb-init /bin/gosu

COPY files/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

EXPOSE 8080/tcp 50000/tcp

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
