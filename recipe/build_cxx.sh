#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    GZ_PHYSICS_BUILD_TESTING="OFF"
else
    GZ_PHYSICS_BUILD_TESTING="ON"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DGZ_ENABLE_RELOCATABLE_INSTALL:BOOL=ON \
      -DBUILD_TESTING=$GZ_PHYSICS_BUILD_TESTING

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}

if [ ${target_platform} != "linux-ppc64le" ]; then
  # Remove test that fail on arm64: https://github.com/ignitionrobotics/ign-physics/issues/70
  # Remove test that fail on macOS: https://github.com/conda-forge/libignition-physics-feedstock/issues/13, https://github.com/conda-forge/gz-physics-feedstock/issues/9
  # Remove test INTEGRATION_ExamplesBuild_TEST that fails on multiple platforms: https://github.com/conda-forge/libignition-physics-feedstock/pull/14
  # Remove COMMON_TEST_simulation_features_dartsim that fails on aarch64 https://github.com/conda-forge/gz-physics-feedstock/issues/15
  # Remove COMMON_TEST_joint_mimic_features_bullet-featherstone due to https://github.com/conda-forge/gz-physics-feedstock/pull/16#issuecomment-1753235252
  # Remove COMMON_TEST_simulation_features_bullet-featherstone due to https://github.com/conda-forge/gz-physics-feedstock/issues/46
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release -E "INTEGRATION_FrameSemantics2d|INTEGRATION_JointTypes2f|UNIT_Collisions_TEST|UNIT_EntityManagement_TEST|UNIT_JointFeatures_TEST|UNIT_LinkFeatures_TEST|UNIT_SDFFeatures_TEST|UNIT_SimulationFeatures_TEST|INTEGRATION_ExamplesBuild_TEST|UNIT_WorldFeatures_TEST|UNIT_ShapeFeatures_TEST|UNIT_FreeGroupFeatures_TEST|UNIT_KinematicsFeatures_TEST|PERFORMANCE|UNIT_AddedMassFeatures_TEST|COMMON_TEST_simulation_features_dartsim|COMMON_TEST_joint_mimic_features_bullet-featherstone|COMMON_TEST_simulation_features_bullet-featherstone"
fi
fi
