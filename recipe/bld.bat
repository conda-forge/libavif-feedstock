mkdir build
cd build
if errorlevel 1 exit /b 1

:: Other codecs cannot be enabled because they are not on conda-forge
:: Manually set find_library suffixes to find rav1e importlib build by rust toolchain
cmake .. -GNinja                                 ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%"    ^
  -DCMAKE_INSTALL_LIBDIR=lib                     ^
  -DCMAKE_BUILD_TYPE=Release                     ^
  -DBUILD_SHARED_LIBS=ON                         ^
  -DAVIF_BUILD_TESTS=OFF                         ^
  -DAVIF_CODEC_AOM=ON                            ^
  -DAVIF_CODEC_SVT=ON                            ^
  -DAVIF_CODEC_DAV1D=ON                          ^
  -DAVIF_CODEC_LIBGAV1=OFF                       ^
  -DCMAKE_FIND_LIBRARY_SUFFIXES=".lib;.dll.lib"  ^
  -DAVIF_CODEC_RAV1E=ON

if errorlevel 1 exit /b 1

ninja
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1
