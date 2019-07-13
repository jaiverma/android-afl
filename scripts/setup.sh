#!/bin/bash
set -e

CORES=$(cat /proc/cpuinfo | grep processor | wc -l)

usage() {
  echo "USAGE: $(basename $0) <Android Source Top directory>"
  echo
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

git clone https://github.com/JoeyJiao/android-afl

source build/envsetup.sh
lunch

cd build/soong
git apply android-afl/script/afl-for-soong-on-android-q.patch
cd -

cd android-afl
AFL_TRACE_PC=true mm -j${CORES}

cd android-test
TEST_CLANG_FAST_AARCH64=true mm
cd ../..
mv android-afl/android-test-bp/Android.bp.bak android-afl/android-test-bp/Android.bp
AFL_TRACE_PC=true make afl-crash-bp
