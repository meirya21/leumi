FROM jenkins/jenkins:lts

USER root

# prerequisites for docker
RUN apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        vim \
        iputils-ping \
        unzip \
        wget \
        gnupg \
        netcat \
        zip \
        python3 \
        python3-pip

# docker repos
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" >> /etc/apt/sources.list.d/additional-repositories.list \
    && echo "deb http://ftp-stud.hs-esslingen.de/ubuntu xenial main restricted universe multiverse" >> /etc/apt/sources.list.d/official-package-repositories.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 437D05B5 \
    && apt-get update

# docker
RUN apt-get install -y docker-ce

# docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-cli

# this disable setup wizard and allow me to take the config.yml as a conf file
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# coping casc.yml
COPY ./config.yml /var/jenkins_home/config.yml
ENV CASC_JENKINS_CONFIG /var/jenkins_home/config.yml

# installing plugins.txt
COPY ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --clean-download-directory --list --view-security-warnings -f /usr/share/jenkins/ref/plugins.txt

#replace docker group
RUN delgroup docker && addgroup -gid 138 docker

# give jenkins docker rights
RUN usermod -aG docker jenkins
RUN chown -R 1000:1000 /var/jenkins_home

USER jenkins