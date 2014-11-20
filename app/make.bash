#!/usr/bin/env bash
#

set -e

#ANDROID_APP=${1:-"github.com/codeskyblue/goandroid-helloworld"}
ANDROID_APP=$PWD
if [ -z "$ANDROID_APP" ];then
	echo "Need env-var ANDROID_APP set"
	exit
fi

MOBILE_ROOT=$GOPATH/src/golang.org/x/mobile # TODO: better use gowhich

mkdir -p libs/armeabi-v7a src/main/java/go
cp $MOBILE_ROOT/app/Go.java src/main/java/go
cp $MOBILE_ROOT/bind/java/Seq.java src/main/java/go

export GOPATH=$PWD:$GOPATH

echo "Run gobind -> java,go ..."
cp main.go_tmpl src/golib/main.go
for DIRNAME in $(ls -1 -I'*.go' src/golib)
do
	GOLIBNAME=golib/$DIRNAME/go_$DIRNAME
	mkdir -p src/main/java/go/$DIRNAME src/$GOLIBNAME
	BINDJAVA=src/main/java/go/$DIRNAME/$(python -c "print '$DIRNAME'.title()").java
	BINDGO=src/$GOLIBNAME/go_$DIRNAME.go
	gobind -lang=java golib/$DIRNAME > $BINDJAVA
	gobind -lang=go golib/$DIRNAME > $BINDGO

	sed -i "/IMPORTFLAG/a import _ \"golib/$DIRNAME/go_$DIRNAME\"" src/golib/main.go
done

echo "Building libgojni.go ..."
CGO_ENABLED=1 GOOS=android GOARCH=arm GOARM=7 \
	go build -ldflags="-shared" -o libs/armeabi-v7a/libgojni.so golib
../gradlew build
