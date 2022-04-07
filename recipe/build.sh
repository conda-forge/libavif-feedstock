mkdir -p ${PREFIX}/bin

mkdir build
cd build
AVIF_BUILD_TESTS=ON
if [[ "${target_platform}" != "${build_platform}" ]]; then
# OSX Cross compiles and can't emulate
if [[ "${target_platform}" == osx-* ]]; then
    AVIF_BUILD_TESTS=OFF
fi
fi

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
-DAVIF_CODEC_LIBGAV1=OFF \
-DAVIF_BUILD_TESTS=${AVIF_BUILD_TESTS}

ninja

# 2021/12/05 hmaarrfk
# Tests are a little flaky, and are disabled upstream
# https://github.com/AOMediaCodec/libavif/issues/798
if [[ "${AVIF_BUILD_TESTS}" == "ON" ]]; then
    ./aviftest ../tests/data/ --io-only
fi

ninja install
