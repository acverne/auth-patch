#!/bin/bash
ROOT_DIR="/home/springboard/springboard"
VERSION="5.3.2"
SERVICES=(
  "Canva"
  "GoogleWorkspace"
  "Microsoft365"
)

curl -so /tmp/entcore-common.jar https://maven.opendigitaleducation.com/repository/releases/org/entcore/common/$VERSION/common-$VERSION.jar
curl -so /tmp/opensaml.jar https://repo1.maven.org/maven2/org/opensaml/opensaml/2.6.4/opensaml-2.6.4.jar
curl -so /tmp/vertx-core.jar https://repo1.maven.org/maven2/io/vertx/vertx-core/3.9.5/vertx-core-3.9.5.jar
echo "Downloaded 3 dependencies."

curl -so /tmp/SamlValidator.java https://raw.githubusercontent.com/acverne/auth-patch/main/security/SamlValidator.java?token=$(date +s)
/usr/lib/jvm/temurin-8-jdk-amd64/bin/javac -Xlint:none -cp "$ROOT_DIR/mods/org.entcore~auth~$VERSION-fat.jar:/tmp/entcore-common.jar:/tmp/opensaml.jar:/tmp/vertx-core.jar" -d $ROOT_DIR/mods/org.entcore~auth~$VERSION/ /tmp/SamlValidator.java
echo "Patched SamlValidator."
rm /tmp/SamlValidator.java

for service in ${SERVICES[@]}; do
  curl -so /tmp/$service.java https://raw.githubusercontent.com/acverne/auth-patch/main/services/$service.java?token=$(date +%s)
  /usr/lib/jvm/temurin-8-jdk-amd64/bin/javac -Xlint:none -cp "$ROOT_DIR/mods/org.entcore~auth~$VERSION-fat.jar:/tmp/entcore-common.jar:/tmp/opensaml.jar:/tmp/vertx-core.jar" -d $ROOT_DIR/mods/org.entcore~auth~$VERSION/ /tmp/$service.java
  echo "$service service added."
  rm /tmp/$service.java
done

rm /tmp/{entcore-common,opensaml,vertx-core}.jar
echo "Done, you can restart Springboard via 'systemctl restart springboard'."
