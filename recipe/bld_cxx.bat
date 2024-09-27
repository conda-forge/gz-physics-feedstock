mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DBUILD_TESTING=ON ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
    -DCMAKE_CXX_FLAGS="/permissive- /D_USE_MATH_DEFINES" ^
    -DGZ_ENABLE_RELOCATABLE_INSTALL:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release --parallel 1
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test
:: COMMON_TEST_collisions_dartsim disable as a workaround for https://github.com/conda-forge/gz-physics-feedstock/pull/7#issuecomment-1582053175
:: COMMON_TEST_collisions_bullet-featherstone is disabled as a workaround for https://github.com/conda-forge/gz-physics-feedstock/issues/42
ctest --output-on-failure -C Release -E "check_|INTEGRATION_ExamplesBuild_TEST|UNIT_Collisions_TEST|UNIT_EntityManagement_TEST|COMMON_TEST_collisions_dartsim|COMMON_TEST_collisions_bullet-featherstone"
if errorlevel 1 exit 1
