set -e

mkdir stage
mkdir build
cd build
# 2022/04/07 hmaarrfk:
# Tests have strange dependencies, which aren't required for the
# actual application
# If enabling tests again, be mindful that certain tests may be flaky
# https://github.com/conda-forge/libavif-feedstock/blob/837c50bee52e8d4132b114cda164382e5dcb0264/recipe/build.sh#L28
# https://github.com/AOMediaCodec/libavif/issues/798
AVIF_BUILD_TESTS=OFF

# Other codecs cannot be enabled because they are not on conda-forge
# libgav1 and libyuv not available on channel. Last checked July 2024.
cmake ${CMAKE_ARGS} -GNinja \
-DCMAKE_INSTALL_PREFIX="$SRC_DIR/stage" \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON \
-DAVIF_BUILD_TESTS=ON \
-DCMAKE_BUILD_TYPE=Release \
-DAVIF_CODEC_AOM=SYSTEM \
-DAVIF_CODEC_SVT=SYSTEM \
-DAVIF_CODEC_DAV1D=SYSTEM \
-DAVIF_CODEC_LIBGAV1=OFF \
-DAVIF_CODEC_RAV1E=SYSTEM \
-DAVIF_BUILD_TESTS=${AVIF_BUILD_TESTS} \
-DAVIF_LIBYUV=OFF \
${SRC_DIR}

cmake --build .

cmake --install . --strip

sed -i.bak "s,$SRC_DIR/stage,/opt/anaconda1anaconda2anaconda3,g" $SRC_DIR/stage/lib/pkgconfig/*.pc
rm $SRC_DIR/stage/lib/pkgconfig/*.bak
