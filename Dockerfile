FROM openjdk:8
MAINTAINER Eduard Mayer <eduard.mayer@camparound.com>

# Install Git and dependencies
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y file git curl zip libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists /var/cache/apt

# Set up environment variables
ENV ANDROID_HOME="/home/user/android-sdk-linux" \
    SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    GRADLE_URL="https://services.gradle.org/distributions/gradle-4.10.1-all.zip" \
    SDK_VERSION="28.0.3" \
    VERSION_TARGET_SDK="28"

ENV VERSION_SDK_TOOLS "4333796"

RUN useradd -m user
USER user
WORKDIR /home/user

# Create git config
RUN git config --global user.name "Gitlab Pipeline" &&  git config --global user.email tools@camparound.com

# Create dummy config
RUN mkdir -p .android && touch .android/repositories.cfg

# Download Android SDK
RUN mkdir -p "$ANDROID_HOME" .android \
 && cd "$ANDROID_HOME" \
 && curl -o sdk.zip $SDK_URL \
 && unzip sdk.zip \
 && rm sdk.zip \
 && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

ENV PATH="/home/user/gradle/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}"

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "tools" "platforms;android-${VERSION_TARGET_SDK}"
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"
