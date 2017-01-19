#
# dnn-basic-root: Basic Dockerfile for deep learning with scikit-image, Lasagne,
# Keras, and ml-pyxis with Jupyter.
#
# This Dockerfile ensures that the container starts as root.
#

# Base image is python-theano-tf
FROM aleksaro/python3-theano-tf:latest


MAINTAINER Aleksander Rognhaugen


# Run the following as `root`
USER root


# Install scikit-image, Lasagne, Keras, and ml-pyxis
RUN pip3 install --upgrade \
    scikit-image \
    git+git://github.com/Lasagne/Lasagne.git@$master \
    git+git://github.com/fchollet/keras.git@$master \
    git+git://github.com/vicolab/ml-pyxis.git@$master


# Set correct locale for locale-aware programs or libraries
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# Set up directories in /root
RUN mkdir /root/shared && \
    mkdir /root/data && \
    mkdir /root/.jupyter && \
    mkdir /root/.misc && \
    mkdir -p -m 700 /root/.local/share/jupyter


# Copy over configuration and run file for Jupyter
# The run file is because of: https://github.com/ipython/ipython/issues/7062
COPY jupyter_notebook_config.py /root/.jupyter/
COPY run_jupyter.sh /root/.jupyter/

# Make sure that the run file for jupyter is runnable + add shortcut
RUN chmod +x /root/.jupyter/run_jupyter.sh && \
    echo "alias run_jupyter=/root/.jupyter/run_jupyter.sh" \
    >> /root/.bash_aliases


# Add a script that makes it easier to update some packages
COPY upgrade_packages.sh /root/.misc/
RUN chmod +x /root/.misc/upgrade_packages.sh && \
    echo "alias upgrade_packages=/root/.misc/upgrade_packages.sh" \
    >> /root/.bash_aliases


# Expose port for IPython (8888)
EXPOSE 8888

# Expose port for TensorBoard (6006)
EXPOSE 6006


# Set default working directory and image startup command
#WORKDIR "/root"
#CMD ["/bin/bash"]

####################################################################################
####################################################################################
# 2) SETUP JENKINS

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

VOLUME /var/jenkins_home # TODO: make persistant on outside?

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_VERSION 0.13.2
ENV TINI_SHA afbf8de8a63ce8e4f18cb3f34dfdbbd354af68a1
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha1sum -c -

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.32.1}

ARG JENKINS_SHA=1b65dc498ba7ab1f5cce64200b920a8716d90834
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

EXPOSE 8080
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

####################################################################################
####################################################################################
# 3) SETUP DOCKER IN DOCKER SUPPORT

USER root
RUN apt-get update \
  && apt-get install -y apt-transport-https ca-certificates \
  && echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list \
  && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
  && apt-get update -y \
  && apt-get install -y docker-engine
RUN gpasswd -a jenkins docker
USER jenkins

####################################################################################
####################################################################################
# 4) START APPLICATION, either bash shell or jenkins

WORKDIR "/root"
CMD ["/bin/bash"]