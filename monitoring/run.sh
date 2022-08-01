#!/bin/bash
set -eu
docker compose up --abort-on-container-exit --force-recreate --remove-orphans --renew-anon-volumes
