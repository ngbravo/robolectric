#!/bin/bash
#
# Install Robolectric into the local Maven repository.
# Modified to patch in new android-all jars
#
set -e

#TEST_VERSION="5.1.1_r9-robolectric-1"
TEST_VERSION="6.0.0_r1-robolectric-0"

PROJECT=$(cd $(dirname "$0")/../..; pwd)
# M2_REPO=$(cd ~/.m2/repository/org/robolectric; pwd)
AUX_DIR=$(cd $(dirname "$0") ./; pwd)
if [ -z ${INCLUDE_SOURCE+x} ]; then SOURCE_ARG=""; else SOURCE_ARG="source:jar"; fi
if [ -z ${INCLUDE_JAVADOC+x} ]; then JAVADOC_ARG=""; else JAVADOC_ARG="javadoc:jar"; fi

# echo "Removing original test android-all"
# cd $M2_REPO/android-all; rm -r -f $TEST_VERSION

echo "Building Robolectric..."
cd "$PROJECT"; mvn -T 1C -D skipTests clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 16..."
# cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-16 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 17..."
# cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-17 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 18..."
# cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-18 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 19..."
# cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-19 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 21..."
# cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-21 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 22..."
# cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-22 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Building shadows for API 23..."
cd "$PROJECT"/robolectric-shadows/shadows-core; mvn -T 1C -P android-23 clean $SOURCE_ARG $JAVADOC_ARG install

echo "Patching new android-all jars in for $TEST_VERSION..."
# Extract original jar
# cd "$AUX_DIR"
#mkdir -p temp/extracted/$TEST_VERSION-AOSP; cd temp/extracted/$TEST_VERSION-AOSP
#jar xvf $M2_REPO/android-all/$TEST_VERSION/android-all-$TEST_VERSION.jar
# Extract new jar
#cd "$AUX_DIR"
#mkdir -p temp/extracted/$TEST_VERSION; cd temp/extracted/$TEST_VERSION
#jar xvf $AUX_DIR/new-android-jars/android-all-$TEST_VERSION.jar
# Copy new jar over
# cp $AUX_DIR/new-android-jars/android-all-$TEST_VERSION.jar $AUX_DIR/temp/extracted/android-all-$TEST_VERSION.jar
# Replace relevant classes
#cd $AUX_DIR/temp/extracted
#jar uvf android-all-$TEST_VERSION.jar $TEST_VERSION-AOSP/android/view/SurfaceView.class
#jar uvf android-all-$TEST_VERSION.jar $TEST_VERSION-AOSP/android/webkit/WebView.class
#jar uvf android-all-$TEST_VERSION.jar $TEST_VERSION-AOSP/android/view/accessibility/AccessibilityManager.class
#jar uvf android-all-$TEST_VERSION.jar $TEST_VERSION-AOSP/android/os/ServiceManager.class
#jar uvf android-all-$TEST_VERSION.jar $TEST_VERSION-AOSP/android/util/LruCache.class

# Patch back in
cd "$AUX_DIR"
#mvn -q install:install-file -DgroupId='org.robolectric' -DartifactId='android-all' -Dversion=$TEST_VERSION -Dfile="new-android-jars/android-all-$TEST_VERSION.jar" -Dpackaging=jar
#mvn -q install:install-file -DgroupId='org.robolectric' -DartifactId='android-all' -Dversion=$TEST_VERSION -Dfile="new-android-jars/android-all-$TEST_VERSION-sources.jar" -Dpackaging=jar

echo "Running Tests..."
# cd "$PROJECT"; mvn -T 1C test
