#!/bin/sh

gpg --quiet --batch --yes --decrypt --passphrase="bosalpim" \
--output ./config/FB_ADMIN_JSON.json ./config/FB_ADMIN_JSON.json.gpg
