#!/bin/bash
ROOT_DIR="/home/springboard/springboard"
VERSION="5.1.0"
PATCH_DIR="$ROOT_DIR/mods/org.entcore~auth~$VERSION/fr/goldeduc/auth/"
FILES=(
  "Canva"
  "GoogleWorkspace"
  "Microsoft365"
)

mkdir -p $PATCH_DIR
echo "Directory created."

for file in FILES; do
  curl -O /tmp/$file.java https://raw.githubusercontent.com/acverne/auth-patch/main/fr/goldeduc/auth/$file.java
  /usr/lib/jvm/temurin-8-jdk-amd64/bin/javac -cp "$ROOT_DIR/mods/org.entcore~auth~$VERSION-fat.jar" -d $PATCH_DIR /tmp/$file.java
  echo "$file enabled."
  rm /tmp/$file.java
done

echo "Done."
