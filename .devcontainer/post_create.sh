#!/usr/bin/env sh

## This script's purpose is to install and setup a devevelopment environment.
## It is meant to be invoked inside a devcontainer, after it is created anew.
## Here we simply install the `ool_rules_engine` wheel in editable mode.

# Set script running options
# -e: Exit on error.
# -u: Error on unbound var.
# -x: Debug mode, echoes commands before they're executed.
set -eux

# Pull Daryl's custom fork of gym-unrealcv.
git submodule update --init --recursive

python -m pip install --user -U pip setuptools

# Install dependencies from requirements.txt
python -m pip install --user -r requirements.txt

## Install PyCuda from source, to remove curand from install.
workdir=$(pwd)
cd ~
# Download the `pycuda-2017.1.1.tar.gz` archive.
wget https://files.pythonhosted.org/packages/b3/30/9e1c0a4c10e90b4c59ca7aa3c518e96f37aabcac73ffe6b5d9658f6ef843/pycuda-2017.1.1.tar.gz

# Extract downloaded tar archive into pycuda-2017.1.1
sudo tar xvf pycuda-2017.1.1.tar.gz >/dev/null
cd pycuda-2017.1.1

# Remove siteconf.py w/o failing if it exists.
sudo rm siteconf.py || true

# Configure with custom options to remove `curand` issue.
sudo python configure.py \
    --cudadrv-lib-dir=/usr/lib64 \
    --cudart-lib-dir=/usr/local/cuda/lib64 \
    --cudart-libname=cudart \
    --cuda-root=/usr/local/cuda \
    --no-cuda-enable-curand

# Install PyCuda
sudo make install

# Return to repo
cd $workdir

# Install fork of gym-unrealcv in editable mode.
python -m pip install --user -e gym-unrealcv/

# Install `opencv` as required by `gym-unrealcv`.
pip install "opencv-python==3.4.18.65"

# Unset script options.
set +eux
