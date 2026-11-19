# Self-host add-on (not part of upstream fmhy/edit).
#
# Layered on top of the image built from the repo's own Dockerfile (see
# .github/workflows/selfhost-image.yml). It adds only the startup script that
# sets the hostname from FMHY_HOSTNAME at runtime.
ARG BASE_IMAGE=fmhy-edit-base:ci
FROM ${BASE_IMAGE}
COPY --chmod=755 40-fmhy-hostname.sh /docker-entrypoint.d/40-fmhy-hostname.sh
