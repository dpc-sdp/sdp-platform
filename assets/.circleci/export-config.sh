#!/usr/bin/env bash
##
# Build site in CI.
#
set -e

echo "==> Validate composer configuration"
composer validate --ansi --strict --no-check-all --no-check-lock

# Process Docker Compose configuration. This is used to avoid multiple
# docker-compose.yml files. Remove all lines that have ### and uncomment
# lines with ##.
sed -i -e "/###/d" docker-compose.yml
sed -i -e "s/##//" docker-compose.yml

ahoy pull
ahoy export-config

# Copy modified config back to host.
# This is correct for CircleCI environments but when testing locally the
# correct path for the destination is `./config`.
# @TODO Set the destination directory to a variable.
docker cp $(docker-compose ps -q cli):/app/config/sync /app/config

git status
CURRENT_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
RELEASE_GIT_BRANCH=$(echo $CURRENT_GIT_BRANCH | sed 's/automation/release/')
git checkout -b $RELEASE_GIT_BRANCH
git add config/sync
git commit -m "Automated config export"
git push origin --set-upstream $RELEASE_GIT_BRANCH
