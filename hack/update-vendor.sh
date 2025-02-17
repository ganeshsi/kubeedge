#!/usr/bin/env bash

###
#Copyright 2019 The KubeEdge Authors.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
###

set -o errexit
set -o nounset
set -o pipefail

# The root of the build/dist directory
KUBEEDGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

# list_staging_repos outputs a sorted list of repos in staging/src/kubeedge
# each entry will just be the $repo portion of staging/src/kubeedge/$repo/...
# $KUBEEDGE_ROOT must be set.
function kubeedge::util::list_staging_repos() {
  (
    cd "${KUBEEDGE_ROOT}/staging/src/github.com/kubeedge/" && \
    find . -mindepth 1 -maxdepth 1 -type d | cut -c 3- | sort
  )
}


echo "running 'go mod tidy'"
go mod tidy

echo "running 'go mod vendor'"
go mod vendor

# create a symlink in vendor directory pointing to the staging components.
# This lets other packages and tools use the local staging components as if they were vendored.
for repo in $(kubeedge::util::list_staging_repos); do
  rm -fr "${KUBEEDGE_ROOT}/vendor/github.com/kubeedge/${repo}"
  ln -s "../../../staging/src/github.com/kubeedge/${repo}/" "${KUBEEDGE_ROOT}/vendor/github.com/kubeedge/${repo}"
done
