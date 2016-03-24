#!/usr/bin/env bash
#
# Decompiles the patched in android jar for development purposes
#

DIR=$(cd $(dirname "$0")/; pwd)

decompile () {
  echo "Decompiling $1..."
  cd $DIR
  java -jar cfr_0_114.jar ~/.m2/repository/org/robolectric/android-all/$1/android-all-$1.jar --outputdir ./temp/cfr-output/$1
}

cd $DIR
# decompile "5.1.1_r9-robolectric-1"
decompile "6.0.0_r1-robolectric-0"
