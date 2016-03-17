DIR=$(cd $(dirname "$0")/; pwd)
cd $DIR
java -jar cfr_0_114.jar ~/.m2/repository/org/robolectric/android-all/5.1.1_r9-robolectric-1/android-all-5.1.1_r9-robolectric-1.jar --outputdir ./cfr-output/
