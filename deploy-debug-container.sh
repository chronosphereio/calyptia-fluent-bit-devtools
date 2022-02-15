#!/bin/bash
# Copyright 2021 Calyptia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file  except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the  License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -eu
# Simple script to use ephemeral containers to debug a Fluent Bit pod

# Override with a different name if you want
CLUSTER_NAME=${CLUSTER_NAME:-kind}
FLUENT_BIT_NAMESPACE=${FLUENT_BIT_NAMESPACE:-fluentbit}

# The fluent bit image under test
DEBUG_IMAGE=${FLUENT_BIT_IMAGE:-fluent/fluent-bit:1.8.12-debug}

docker pull "$DEBUG_IMAGE"
kind load docker-image "$DEBUG_IMAGE" --name="$CLUSTER_NAME"

POD=$(kubectl -n "$FLUENT_BIT_NAMESPACE" get pod -l app.kubernetes.io/name=fluent-bit  -o jsonpath="{.items[0].metadata.name}")
kubectl -n "$FLUENT_BIT_NAMESPACE" debug -it "$POD" --image="$DEBUG_IMAGE" -- /bin/bash
