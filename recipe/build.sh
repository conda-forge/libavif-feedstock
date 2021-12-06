mkdir build
cd build

# Other codecs cannot be enabled because they are not on conda-forge
cmake .. "${CMAKE_ARGS}" -GNinja \
-DCMAKE_INSTALL_PREFIX="$PREFIX" \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON \
-DAVIF_BUILD_TESTS=ON \
-DCMAKE_BUILD_TYPE=Release \
-DAVIF_CODEC_AOM=ON \
-DAVIF_CODEC_SVT=OFF \
-DAVIF_CODEC_DAV1D=OFF \
-DAVIF_CODEC_LIBGAV1=OFF

ninja

# 2021/12/05 hmaarrfk
# Tests are a little flaky, and are disabled upstream
# https://github.com/AOMediaCodec/libavif/issues/798
./aviftest ../tests/data/ --io-only

ninja install
