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
cmake .. "${CMAKE_ARGS}" -GNinja \
-DCMAKE_INSTALL_PREFIX="$PREFIX" \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON \
-DAVIF_BUILD_TESTS=ON \
-DCMAKE_BUILD_TYPE=Release \
-DAVIF_CODEC_AOM=ON \
-DAVIF_CODEC_SVT=OFF \
-DAVIF_CODEC_DAV1D=ON \
-DAVIF_CODEC_LIBGAV1=OFF \
-DAVIF_BUILD_TESTS=${AVIF_BUILD_TESTS}

ninja

ninja install
