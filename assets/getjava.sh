 #!/bin/bash

JAVA_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_11.0.8_10.tar.gz
if [[ $OSTYPE == "darwin"* ]]; then
        JAVA_URL=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_mac_hotspot_11.0.8_10.tar.gz
fi

JAVA_VERSION=11.0.8

JAVA_HOME=$HOME/.local/java/jdk/$JAVA_VERSION

mkdir -p $JAVA_HOME
curl -L $JAVA_URL | tar -zx -C $JAVA_HOME --strip-components=1

PATH=$JAVA_HOME/bin:$PATH

# Install maven
MVN_VERSION=3.6.3
MVN_URL=http://apache.uvigo.es/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
MVN_HOME=$HOME/.local/java/mvn/$MVN_VERSION
mkdir -p  $MVN_HOME
curl -L $MVN_URL | tar -zx -C $MVN_HOME --strip-components=1

PATH=$PATH:$MVN_HOME

# install eclipse jdt lanague server
JDT_VERSION=0.55.0
JDT_URL=http://download.eclipse.org/jdtls/milestones/0.55.0/jdt-language-server-0.55.0-202004300028.tar.gz
JDT_HOME=$HOME/.local/java/jdt/$JDT_VERSION
mkdir -p $JDT_HOME
curl -L $JDT_URL  | tar -zx -C $JDT_HOME --strip-components=1

