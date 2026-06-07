FROM ghcr.io/ifbars/s1dedicatedservers:latest

USER root

# Pterodactyl/Wings starts game containers as a random unprivileged UID/GID
# and usually mounts the root filesystem read-only. Only /home/container is
# writable/persistent. Therefore SteamCMD, Wine and game files must live there.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/container \
    && chmod 0755 /home /home/container

COPY patch_run.py /tmp/patch_run.py
COPY pterodactyl-entrypoint.sh /usr/local/bin/pterodactyl-entrypoint.sh

ENV HOME=/home/container
ENV STEAMAPPDIR=/home/container
ENV WINEPREFIX=/home/container/.wine
ENV S1DS_RUNTIME=mono

RUN python3 /tmp/patch_run.py \
    && install -m 0755 /home/steam/run.sh /usr/local/bin/s1ds-run.sh \
    && sed -i 's|/home/steam/steamcmd/steamcmd.sh|/home/container/steamcmd/steamcmd.sh|g' /usr/local/bin/s1ds-run.sh \
    && sed -i 's|/home/steam/steamworks_redist|/home/container/steamworks_redist|g' /usr/local/bin/s1ds-run.sh \
    && chmod 0755 /usr/local/bin/s1ds-run.sh \
    && chmod 0755 /usr/local/bin/pterodactyl-entrypoint.sh \
    && chmod 0755 /home \
    && chmod -R a+rX /home/steam \
    && rm /tmp/patch_run.py \
    && grep -n "steamcmd.sh\|steamworks_redist\|1007" /usr/local/bin/s1ds-run.sh

WORKDIR /home/container

ENTRYPOINT ["/bin/bash", "/usr/local/bin/pterodactyl-entrypoint.sh"]
