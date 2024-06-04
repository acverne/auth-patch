#!/bin/bash
ROOT_DIR="/home/springboard/springboard"
VERSION="5.1.0"
PATCH_DIR="$ROOT_DIR/mods/org.entcore~auth~$VERSION/fr/goldeduc/auth/"
FILES=(
  "Canva"
  "GoogleWorkspace"
  "Microsoft365"
)

mkdir -p $ROOT_DIR/mods/org.entcore~auth~$VERSION/fr/goldeduc/auth/
echo "Directory created."

curl -so /tmp/entcore-common.jar https://maven.opendigitaleducation.com/repository/releases/org/entcore/common/5.1.0/common-5.1.0.jar
curl -so /tmp/opensaml.jar https://repo1.maven.org/maven2/org/opensaml/opensaml/2.6.4/opensaml-2.6.4.jar
curl -so /tmp/vertx-core.jar https://repo1.maven.org/maven2/io/vertx/vertx-core/3.9.5/vertx-core-3.9.5.jar
echo "Downloaded dependencies."

for file in ${FILES[@]}; do
  curl -so /tmp/$file.java https://raw.githubusercontent.com/acverne/auth-patch/main/fr/goldeduc/auth/$file.java
  /usr/lib/jvm/temurin-8-jdk-amd64/bin/javac -cp "$ROOT_DIR/mods/org.entcore~auth~$VERSION-fat.jar:/tmp/entcore-common.jar:/tmp/opensaml.jar:/tmp/vertx-core.jar" -d $ROOT_DIR/mods/org.entcore~auth~$VERSION/ /tmp/$file.java
  echo "$file enabled."
  rm /tmp/$file.java
done

rm /tmp/{entcore-common,opensaml,vertx-core}.jar
echo "Done."
