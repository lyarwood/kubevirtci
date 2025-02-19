#!/usr/bin/env bash
#
# This file is part of the KubeVirt project
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
#
# Copyright 2021 Red Hat, Inc.

set -e

WHEREABOUTS_BASE="https://github.com/k8snetworkplumbingwg/whereabouts/archive"
WHEREABOUTS_RELEASES="${WHEREABOUTS_BASE}/refs/tags/"

# syntax:
# ./hack/bump-whereabouts.sh <PROVIDER> <WHEREABOUTS_VERSION>

# usage example
# ./hack/bump-whereabouts.sh 1.19 v0.4.2
# ./hack/bump-whereabouts.sh 1.19 master

provider="${1:?provider not set or empty}"
whereabouts_version="${2:?whereabouts version not set or empty}"

url=
if [[ $whereabouts_version = v* ]]; then
    url="${WHEREABOUTS_RELEASES}/${whereabouts_version}.tar.gz"
else
    url="${WHEREABOUTS_BASE}/${whereabouts_version}.tar.gz"
fi

tmp_dir=$(mktemp -d)
cd $tmp_dir
wget -O ${tmp_dir}/whereabouts.tar.gz "$url"
tar xzf whereabouts.tar.gz
rm whereabouts.tar.gz
mv whereabouts-* whereabouts
cd -

manifests_dir=doc
[[ -d ${tmp_dir}/whereabouts/doc/crds ]] && manifests_dir=doc/crds
cp hack/kustomization/whereabouts/*.yaml ${tmp_dir}/whereabouts/${manifests_dir}/

target_dir="cluster-provision/k8s/${provider}/manifests/whereabouts"
mkdir -p ${target_dir}
rm -rf ${target_dir:?}/*
kubectl kustomize ${tmp_dir}/whereabouts/${manifests_dir}/ >${target_dir}/whereabouts-${whereabouts_version}.yaml

rm -rf $tmp_dir

echo "whereabouts, provision, Bump k8s-${provider} whereabouts to ${whereabouts_version}"
