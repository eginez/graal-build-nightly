#! /bin/bash
set -x

JDK_VERSION=$1

jdk8() {
    echo "Building GraalVM for JDK 8"
    wget -q https://github.com/graalvm/openjdk8-jvmci-builder/releases/download/jvmci-19.3-b04/openjdk-8u232-jvmci-19.3-b04-linux-amd64.tar.gz
    tar zxf openjdk-8u232-jvmci-19.3-b04-linux-amd64.tar.gz
    export JAVA_HOME=`pwd`/openjdk1.8.0_232-jvmci-19.3-b04
}

jdk11() {
    echo "Building GraalVM for JDK 11"
    wget -q https://github.com/graalvm/labs-openjdk-11/releases/download/jvmci-19.3-b05/labsjdk-ce-11.0.5+10-jvmci-19.3-b05-linux-amd64.tar.gz
    tar zxf labsjdk-ce-11.0.5+10-jvmci-19.3-b05-linux-amd64.tar.gz
    export JAVA_HOME=`pwd`/labsjdk-ce-11.0.5-jvmci-19.3-b05
}

if [ "${JDK_VERSION}" == "jdk8" ]; then
    jdk8
elif [ "$JDK_VERSION" == "jdk11" ]; then
    jdk11
else
    echo "Need to provide a valid JDK version: jdk8, jdk11"
    exit 1
fi

mkdir dist
distpath=`pwd`/dist
mkdir graal
cd graal
export PATH=$PWD/mx:$PATH

git clone --depth=1 https://github.com/graalvm/mx
git clone --depth=1 https://github.com/oracle/graal

cd graal/vm
echo "Git commit: `git rev-parse HEAD`"
commit=`git rev-parse --short HEAD`
os=linux
mx clean
mx build

# Copy Graal SDK to new directory defined as artifact/cache
echo "Copying Graal SDK to $distpath"
cp -R latest_graalvm_home/ $distpath/graal-ce-$os-$1-$commit

