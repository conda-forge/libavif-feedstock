mkdir stage
mkdir build
cd build
if errorlevel 1 exit /b 1

:: Other codecs cannot be enabled because they are not on conda-forge
cmake .. -GNinja                                 ^
  -DCMAKE_INSTALL_PREFIX:PATH="%SRC_DIR%\stage" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%"    ^
  -DCMAKE_INSTALL_LIBDIR=lib                     ^
  -DCMAKE_BUILD_TYPE=Release                     ^
  -DBUILD_SHARED_LIBS=ON                         ^
  -DAVIF_BUILD_TESTS=OFF                         ^
  -DAVIF_CODEC_AOM=SYSTEM                            ^
  -DAVIF_CODEC_SVT=SYSTEM                           ^
  -DAVIF_CODEC_DAV1D=SYSTEM                          ^
  -DAVIF_CODEC_LIBGAV1=OFF                       ^
  -DAVIF_CODEC_RAV1E=SYSTEM ^
  -DAVIF_LIBYUV=OFF

if errorlevel 1 exit /b 1

cmake --build .
if errorlevel 1 exit /b 1

cmake --install . --strip
if errorlevel 1 exit /b 1

setlocal EnableExtensions ENABLEDELAYEDEXPANSION
for %%f in ( "%SRC_DIR%\stage\lib\pkgconfig\*.pc" ) do (
    sed -i.bak "s,prefix=.*,prefix=/opt/anaconda1anaconda2anaconda3/Library,g" %%f
    del %%f.bak
)
endlocal
