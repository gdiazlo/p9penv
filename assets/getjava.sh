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

# Install SBT
SBT_VERSION=1.3.10
SBT_URL=https://piccolo.link/sbt-1.3.10.tgz
SBT_HOME=$HOME/.local/java/sbt/$SBT_VERSION
mkdir -p $SBT_HOME
curl -L $SBT_URL | tar -zx -C $SBT_HOME --strip-components=1

PATH=$PATH:$SBT_HOME/bin

# Install Courier
COURSIER_VERSION=current
COURSIER_URL=https://git.io/coursier-cli
curl -Lo  $HOME/.local/bin/coursier $COURSIER_URL
chmod +x $HOME/.local/bin/coursier

# Install metals

coursier bootstrap \
  --java-opt -XX:+UseG1GC \
  --java-opt -XX:+UseStringDeduplication  \
  --java-opt -Xss4m \
  --java-opt -Xms100m \
  --java-opt -Dmetals.verbose=on \
  --java-opt -Dmetals.http=on \
  --java-opt -Dmetals.java-home=~/.java/jdk/11.0.2 \
  --java-opt -Dmetals.maven-script=~/.java/mvn/3.6.2/bin/mvn \
  --java-opt -Dmetals.sbt-script=~/.java/sbt/1.3.3/bin/sbt \
  org.scalameta:metals_2.12:0.9.0 -o $HOME/.local/bin/metals -f


# Install scalafmt
VERSION=2.5.3
curl -L https://raw.githubusercontent.com/scalameta/scalafmt/master/bin/install-scalafmt-native.sh | bash -s -- $VERSION $HOME/.local/bin/scalafmt

# install eclipse jdt lanague server
JDT_VERSION=0.55.0
JDT_URL=http://download.eclipse.org/jdtls/milestones/0.55.0/jdt-language-server-0.55.0-202004300028.tar.gz
JDT_HOME=$HOME/.local/java/jdt/$JDT_VERSION
mkdir -p $JDT_HOME
curl -L $JDT_URL  | tar -zx -C $JDT_HOME --strip-components=1

