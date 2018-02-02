#!/bin/bash
# Copyright 2018 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Run dep ensure, generate bazel rules and do additional pruning.
#
# Usage:
#   update-dep.sh <ARGS>
#
# The args are sent to dep ensure -v <ARGS>

set -o nounset
set -o errexit
set -o pipefail
set -o xtrace

TESTINFRA_ROOT=$(git rev-parse --show-toplevel)
cd "${TESTINFRA_ROOT}"

trap 'echo "FAILED" >&2' ERR
# dep itself has a problematic testdata directory with infinite symlinks which
# makes bazel sad: https://github.com/golang/dep/pull/1412
# dep should probably be removing it, but it doesn't:
# https://github.com/golang/dep/issues/1580
rm -rf vendor/github.com/golang/dep/internal/fs/testdata
bazel run //:dep -- ensure -v "$@"
rm -rf vendor/github.com/golang/dep/internal/fs/testdata
hack/update-bazel.sh
hack/prune-libraries.sh --fix
hack/update-bazel.sh  # Update child :all-srcs in case parent was deleted
echo SUCCESS
