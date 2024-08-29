#!/bin/bash

# Check if NDK path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_android_ndk>"
    exit 1
fi

NDK_PATH=$1
BUILD_DIR="build_android"
OUTPUT_DIR="output"

# Number of cores to use for the build (adjust as needed)
NUM_CORES=4

# List of ABIs you want to support
ABIS=("armeabi-v7a" "arm64-v8a")


# Create a build and output directory if it doesn't exist
mkdir -p $BUILD_DIR
mkdir -p $OUTPUT_DIR

# Loop through each ABI and build
for ABI in "${ABIS[@]}"; do
    echo "Building for ABI: $ABI"

    # Create a subdirectory for each ABI
    ABI_BUILD_DIR="${BUILD_DIR}/${ABI}"
    mkdir -p $ABI_BUILD_DIR

    # Configure the build for the current ABI
    cmake -B$ABI_BUILD_DIR \
          -DCMAKE_SYSTEM_NAME=Android \
          -DCMAKE_SYSTEM_VERSION=21 \
          -DCMAKE_ANDROID_NDK=$NDK_PATH \
          -DCMAKE_ANDROID_ARCH_ABI=$ABI \
          -DBUILD_SHARED_LIBS=ON \
          # -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake"

    # Build the project for the current ABI using multiple cores
    cmake --build $ABI_BUILD_DIR --parallel $NUM_CORES

    # Copy the built .so files to the output directory
    mkdir -p $OUTPUT_DIR/$ABI
    find $ABI_BUILD_DIR -name "*.so" -exec cp {} $OUTPUT_DIR/$ABI/ \;
done

# Copy the include files (headers) to the include directory
INCLUDE_DIR="${OUTPUT_DIR}/include"
mkdir -p $INCLUDE_DIR

# Find and copy all header files (.h) from the build directory to the include directory while preserving the directory structure
rsync -avm --include='*/' --include='*.h' --exclude='*' $BUILD_DIR/ $INCLUDE_DIR/

echo "Build and file arrangement completed successfully."

