#!/bin/bash

# Ensure that our git wants to talk to github without prompting
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
git config --global user.email "buildkite@julialang.org"
git config --global user.name "SciML Benchmarks CI"

# Clone SciMLBenchmarksOutput to temporary directory
temp_dir=$(mktemp -d)
git -C "${temp_dir}" clone git@github.com:SciML/SciMLBenchmarksOutput .

# Copy our output artifacts into it:
for d in docs html notebook pdf script markdown; do
    cp -vRa "${d}/" "${temp_dir}"
done

# Commit the result up to output
set -e
git -C "${temp_dir}" add .
git -C "${temp_dir}" commit -m "Automatic build\nPublished by build of: ${BUILDKITE_REPO%.git}/commit/${BUILDKITE_COMMIT}"
git -C "${temp_dir}" push

rm -rf "${temp_dir}"
