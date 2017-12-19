#!/bin/bash

set -x -e

# activate the build environment
. activate "${BUILD_PREFIX}"

# remove any old builds of the python target
./b2 -q -d+2 --with-python --clean

./b2 -q -d+2 \
     python=${PY_VER} \
     -j${CPU_COUNT} \
     --with-python \
     cxxflags="${CXXFLAGS} -Wno-deprecated-declarations" \
     install | tee b2.install-py-${PY_VER}.log 2>&1

# boost.python, when driven via bjam always links to boost_python
# instead of boost_python3. It also does not add any specified
# --python-buildid; ping @stefanseefeld
if [[ ${PY_VER%.*} == 3 ]]; then
  pushd "${PREFIX}/lib"
    if [[ ${HOST} =~ .*darwin.* ]]; then
      ln -s libboost_python${PY_VER%.*}.dylib libboost_python.dylib
      ln -s libboost_numpy${PY_VER%.*}.dylib libboost_numpy.dylib
    else
      ln -s libboost_python${PY_VER%.*}.so libboost_python.so
      ln -s libboost_numpy${PY_VER%.*}.so libboost_numpy.so
    fi
  popd
fi

# debugging
echo "QQQQ"
echo "Python 2.7 should include: PyUnicodeUCS4_AsWideChar"
echo "Python 3.x should include: PyUnicode_AsUTF8"
python -V
nm $PREFIX/lib/libboost_python.so | grep Unicode
