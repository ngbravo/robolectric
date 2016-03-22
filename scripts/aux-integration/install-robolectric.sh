#!/bin/bash
#
# Install Robolectric into the local Maven repository.
# Modified to patch in new android-all jars
#
set -e

PROJECT=$(cd $(dirname "$0")/../..; pwd)
AUX_DIR=$(cd $(dirname "$0") ./; pwd)
if [ -z ${INCLUDE_SOURCE+x} ]; then SOURCE_ARG=""; else SOURCE_ARG="source:jar"; fi
if [ -z ${INCLUDE_JAVADOC+x} ]; then JAVADOC_ARG=""; else JAVADOC_ARG="javadoc:jar"; fi

echo "Building Robolectric..."
cd "$PROJECT"; mvn -T 1C -D skipTests clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 16..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-16 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 17..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-17 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 18..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-18 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 19..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-19 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 21..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-21 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 22..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-22 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Patching new android-all jars in for API 22"
cd "$AUX_DIR"; mvn -q install:install-file -DgroupId='org.robolectric' -DartifactId='android-all' -Dversion='5.1.1_r9-robolectric-1' -Dfile='./new-android-jars/android-all-5.1.1_r9-robolectric-1.jar' -Dpackaging=jar

echo "Building shadows for API 23..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-23 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Running Tests..."
# cd "$PROJECT"; mvn -T 1C test
