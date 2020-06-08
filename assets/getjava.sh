 #!/bin/bash

JAVA_VERSION=11.0.7
JAVA_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jdk_x64_linux_11.0.7_10.tar.gz

mkdir -p ~/.java/jdk/$JAVA_VERSION
wget -c $JAVA_URL -O - | tar -zx -C ~/.java/jdk/${JAVA_VERSION}/ --strip-components=1

JAVA_HOME=~/.java/jdk/$JAVA_VERSION
PATH=~/.java/jdk/$JAVA_VERSION/bin:$PATH

# Install maven
MVN_VERSION=3.6.3
MVN_URL=http://apache.uvigo.es/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
mkdir -p ~/.java/mvn/$MVN_VERSION
wget -c $MVN_URL -O - | tar -zx -C ~/.java/mvn/$MVN_VERSION --strip-components=1

PATH=$PATH:~/.java/mvn/$MVN_VERSION/bin

# Install SBT
SBT_VERSION=1.3.10
SBT_URL=https://piccolo.link/sbt-1.3.10.tgz
mkdir -p ~/.java/sbt/$SBT_VERSION
wget -c $SBT_URL -O - | tar -zx -C ~/.java/sbt/$SBT_VERSION --strip-components=1

PATH=$PATH:~/.java/sbt/$SBT_VERSION/bin

# Install Courier
COURSIER_VERSION=current
COURSIER_URL=https://git.io/coursier-cli
mkdir -p ~/bin
curl -Lo  ~/bin/coursier $COURSIER_URL
chmod +x ~/bin/coursier

export PATH=$PATH:~/bin/

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
  org.scalameta:metals_2.12:0.9.0 -o ~/.local/bin/metals -f


# Install scalafmt
VERSION=2.5.3
curl https://raw.githubusercontent.com/scalameta/scalafmt/master/bin/install-scalafmt-native.sh | bash -s -- $VERSION ~/.local/bin/scalafmt

# install eclipse jdt lanague server
JDT_VERSION=0.55.0
JDT_URL=http://download.eclipse.org/jdtls/milestones/0.55.0/jdt-language-server-0.55.0-202004300028.tar.gz
mkdir -p ~/.java/jdt/$JDT_VERSION
wget -c $JDT_URL -O - | tar -zx -C ~/.java/jdt/$JDT_VERSION --strip-components=1

