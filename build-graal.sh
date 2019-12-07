#! /bin/bash

JDK_VERSION=$1

jdk8() {
    echo "Building GraalVM for JDK 8"
    wget -q https://github.com/graalvm/openjdk8-jvmci-builder/releases/download/jvmci-19.3-b04/openjdk-8u232-jvmci-19.3-b04-linux-amd64.tar.gz
    tar zxf openjdk-8u232-jvmci-19.3-b04-linux-amd64.tar.gz
    export JAVA_HOME=${CI_PROJECT_DIR}/openjdk1.8.0_232-jvmci-19.3-b04
}

jdk11() {
    echo "Building GraalVM for JDK 11"
    wget -q https://github.com/graalvm/labs-openjdk-11/releases/download/jvmci-19.3-b05/labsjdk-ce-11.0.5+10-jvmci-19.3-b05-linux-amd64.tar.gz
    tar zxf labsjdk-ce-11.0.5+10-jvmci-19.3-b05-linux-amd64.tar.gz
    export JAVA_HOME=${CI_PROJECT_DIR}/labsjdk-ce-11.0.5-jvmci-19.3-b05
}

if [ "${JDK_VERSION}" == "jdk8" ]; then
    jdk8
elif [ "$JDK_VERSION" == "jdk11" ]; then
    jdk11
else
    echo "Need to provide a valid JDK version: jdk8, jdk11"
    exit 1
fi

mkdir graal
cd graal
export PATH=$PWD/mx:$PATH

git clone --depth=1 https://github.com/graalvm/mx
git clone --depth=1 https://github.com/oracle/graal

cd graal/vm
echo "Git commit: `git rev-parse HEAD`"
$commit=`git rev-parse --short HEAD`
mx clean
mx build

# Copy Graal SDK to new directory defined as artifact/cache
echo "Copying Graal SDK to ${CI_PROJECT_DIR}/graal_dist..."
tar cvfz ${CI_PROJECT_DIR}/graal/graalvm/latest_graalvm_home graal_$1_$commit
#cp -R $CI_PROJECT_DIR/graal/graal/vm/latest_graalvm_home/ $CI_PROJECT_DIR/graal_dist_$1
mkdir -p  $CI_PROJECT_DIR/graal_dist_$1
cp graal_$1_$commit $CI_PROJECT_DIR/graal_dist_$1

