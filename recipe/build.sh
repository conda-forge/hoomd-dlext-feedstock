#!/bin/bash

set -euxo pipefail

rm -rf build || true

export HOOMDv2=$( $PYTHON -c 'import hoomd; print(getattr(hoomd, "__version__", "").startswith("2."), end="")' )

CMAKE_FLAGS="  -DCMAKE_INSTALL_PREFIX=${PREFIX}"
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

if [[ ${HOOMDv2} == "True" ]]; then
    CMAKE_FLAGS+=" -DCMAKE_MODULE_PATH=cmake/Modules"
fi

# if CUDA_HOME is defined and not empty, we enable CUDA
if [[ -n ${CUDA_HOME-} ]]; then
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
fi

if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DPython_ROOT_DIR=${PREFIX}"
fi

# Build and install
BUILD_PATH=build/hoomd-dlext
cmake ${CMAKE_ARGS} -S . -B $BUILD_PATH $CMAKE_FLAGS -Wno-dev
cmake --build $BUILD_PATH --target install
