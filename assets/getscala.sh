 #!/bin/bash

JAVA_VERSION=11.0.8

JAVA_HOME=$HOME/.local/java/jdk/$JAVA_VERSION

# Install SBT
SBT_VERSION=1.4.8
SBT_URL=https://github.com/sbt/sbt/releases/download/v1.4.8/sbt-1.4.8.tgz
SBT_HOME=$HOME/.local/java/sbt/$SBT_VERSION
mkdir -p $SBT_HOME
curl -L $SBT_URL | tar -zx -C $SBT_HOME --strip-components=1

PATH=$PATH:$SBT_HOME/bin
MVN=$MVN_HOME/bin/mvn
SBT=$SBT_HOME/bin/sbt

# Install Courier
COURSIER_VERSION=current
COURSIER_URL=https://git.io/coursier-cli
curl -Lo  $HOME/.local/bin/coursier $COURSIER_URL
chmod +x $HOME/.local/bin/coursier

PATH=$PATH:$JAVVA_HOME/bin:$HOME/.local/bin:$MVN_HOME/bin:$SBT_HOME/bin

# Install metals

$HOME/.local/bin/coursier bootstrap \
  --java-opt -XX:+UseG1GC \
  --java-opt -XX:+UseStringDeduplication  \
  --java-opt -Xss4m \
  --java-opt -Xms100m \
  --java-opt -Dmetals.verbose=on \
  --java-opt -Dmetals.http=on \
  --java-opt -Dmetals.java-home=$JAVA_HOME \
  --java-opt -Dmetals.maven-script=$MVN \
  --java-opt -Dmetals.sbt-script=$SBT \
  org.scalameta:metals_2.12:0.10.0 -o $HOME/.local/bin/metals -f


# Install scalafmt
VERSION=2.5.3
curl -L https://raw.githubusercontent.com/scalameta/scalafmt/master/bin/install-scalafmt-native.sh | bash -s -- $VERSION $HOME/.local/bin/scalafmt

