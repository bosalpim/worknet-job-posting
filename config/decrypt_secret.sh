#!/bin/sh

gpg --quiet --batch --yes --decrypt --passphrase="$FB_ADMIN_JSON_SECRET_PASSPHRASE" \
--output ./config/FB_ADMIN_JSON.json ./config/FB_ADMIN_JSON.json.gpg
