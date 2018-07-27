FROM jenkinsci/ssh-slave
# in initial image ARG user=jenkins ARG group=jenkins ARG uid=1000 ARG gid=1000 ARG JENKINS_AGENT_HOME=/home/${user}
# workdir = JENKINS_AGENT_HOME=/home/${user}
# VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"

MAINTAINER DG

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8' \
    ANDROID_SDK_URL="https://dl.google.com/android/repository/tools_r25.2.5-linux.zip" \
    ANDROID_BUILD_TOOLS_VERSION=27.0.3 \
    ANDROID_APIS="android-19,android-21,android-25,android-26" \
    ANT_HOME="/opt/ant" \
    MAVEN_HOME="/opt/maven" \
    GRADLE_HOME="/opt/gradle" \
    ANDROID_HOME="/opt/android"
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin
#:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /opt

RUN dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get install --no-install-recommends -y build-essential git ruby2.3-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev imagemagick mc vim && \
    gem install fastlane && \
    gem install bundler && \
    gem install curb && \
    gem install fastlane-plugin-badge && \
    apt-get -qq install -y wget curl maven ant gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386 && \
   
    # Android SDK
    mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip && \
    echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

    # addon
#RUN locale-gen en_US.UTF-8 && \
#RUN mkdir /jenkins/.ssh && echo "StrictHostKeyChecking no " > /jenkins/.ssh/config
#RUN sed -i /etc/ssh/sshd_config \
#        -e 's/#StrictHostKeyChecking.*/StrictHostKeyChecking no/'
        
RUN cd /opt && mkdir src
        
#COPY gradle-wrapper.properties /opt/android/tools/templates/gradle/wrapper/gradle/wrapper/
RUN /opt/android/tools/templates/gradle/wrapper/gradlew && \    
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && apt-get clean

#RUN cd /home/jenkins && mkdir app && cd ~
