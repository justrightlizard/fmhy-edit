#!/bin/sh
# Self-host add-on (not part of upstream fmhy/edit).
#
# The site is built with a placeholder hostname so the real domain never has
# to be in GitHub. The nginx image runs every executable *.sh in
# /docker-entrypoint.d/ before it starts; this one writes FMHY_HOSTNAME into
# the built files (page meta tags, sitemap, RSS feed) in place of the
# placeholder. With FMHY_HOSTNAME unset it uses https://fmhy.net, the same
# default upstream uses.
#
# It runs once per container: after the swap the placeholder is gone, so a
# changed FMHY_HOSTNAME needs the container recreated (a redeploy), not just
# restarted.
set -eu

PLACEHOLDER="https://fmhy-hostname-placeholder.invalid"
PLACEHOLDER_RE='https://fmhy-hostname-placeholder\.invalid'
SITE=/usr/share/nginx/html
ME=$(basename "$0")

host="${FMHY_HOSTNAME:-https://fmhy.net}"
host="${host%/}"
case "$host" in
  http://*|https://*) ;;
  *)
    echo "$ME: FMHY_HOSTNAME must start with http:// or https:// (got: $host)" >&2
    exit 1
    ;;
esac

count=$(grep -rlF "$PLACEHOLDER" "$SITE" | wc -l || true)
if [ "$count" -eq 0 ]; then
  echo "$ME: hostname already set in this container, nothing to do"
  exit 0
fi

# escape the characters that mean something in the sed replacement
host_sed=$(printf '%s' "$host" | sed 's/[\\|&]/\\&/g')

grep -rlF "$PLACEHOLDER" "$SITE" | while IFS= read -r f; do
  sed -i "s|$PLACEHOLDER_RE|$host_sed|g" "$f"
done
echo "$ME: set hostname to $host in $count files"
