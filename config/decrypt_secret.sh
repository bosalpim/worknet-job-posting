#!/bin/sh

gpg --quiet --batch --yes --decrypt --passphrase="bosalpim" \
--output FB_ADMIN_JSON.json fb_admin.json.gpg
