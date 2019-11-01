 #!/bin/bash

JAVA_VERSION=11.0.2
JAVA_URL=https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz

mkdir -p ~/.java/jdk/$JAVA_VERSION
wget -c $JAVA_URL -O - | tar -zx -C ~/.java/jdk/${JAVA_VERSION}/ --strip-components=1

JAVA_HOME=~/.java/jdk/$JAVA_VERSION
PATH=~/.java/jdk/$JAVA_VERSION/bin:$PATH

# Install maven
MVN_VERSION=3.6.2
MVN_URL=http://apache.uvigo.es/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz
mkdir -p ~/.java/mvn/$MVN_VERSION
wget -c $MVN_URL -O - | tar -zx -C ~/.java/mvn/$MVN_VERSION --strip-components=1

PATH=$PATH:~/.java/mvn/$MVN_VERSION/bin

# Install SBT
SBT_VERSION=1.3.3
SBT_URL=https://piccolo.link/sbt-1.3.3.tgz
mkdir -p ~/.java/sbt/$SBT_VERSION
wget -c $SBT_URL -O - | tar -zx -C ~/.java/sbt/$SBT_VERSION --strip-components=1

PATH=$PATH:~/.java/sbt/$SBT_VERSION/bin

# Install Courier
COURSIER_VERSION=current
COURSIER_URL=https://git.io/coursier-cli
mkdir -p ~/bin
curl -Lo  ~/bin/coursier $COURSIER_URL
chmod +x ~/bin/coursier


export PATH

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
  org.scalameta:metals_2.12:0.7.6 -o metals -f
mv metals ~/bin

