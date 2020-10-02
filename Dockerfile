FROM ubuntu:18.04

ENV VERSION_SDK_TOOLS "4333796"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

ENV VERSION_ANDROID_NDK "20.0.5594570"

ENV ANDROID_NDK_HOME "/sdk/ndk-bundle"

ENV ANDROID_CMAKE_REV="3.6.4111459"
ENV ANDROID_CMAKE_REV_3_10="3.10.2.4988404"

# Constraint Layout / [Solver for ConstraintLayout 1.0.0-alpha8, ConstraintLayout for Android 1.0.0-alpha8]
RUN mkdir -p $ANDROID_HOME/licenses/ && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      build-essential \
      file \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
    unzip /sdk.zip -d $ANDROID_HOME && \
rm -v /sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license \
&& echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt $ANDROID_HOME
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ${ANDROID_HOME}/packages.txt && \
${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

ADD https://dl.google.com/android/repository/${VERSION_ANDROID_NDK}-linux-x86_64.zip /ndk.zip
RUN unzip /ndk.zip -d $ANDROID_NDK_HOME && \
    rm -v /ndk.zip && \
    mv ${ANDROID_NDK_HOME}/${VERSION_ANDROID_NDK}/* ${ANDROID_NDK_HOME}/

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager 'cmake;'$ANDROID_CMAKE_REV \
    yes | ${ANDROID_HOME}/tools/bin/sdkmanager --channel=3 --channel=1 'cmake;'$ANDROID_CMAKE_REV_3_10 \
    && yes | ${ANDROID_HOME}/tools/bin/sdkmanager 'ndk-bundle' 
