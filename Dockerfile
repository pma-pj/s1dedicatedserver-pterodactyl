FROM ghcr.io/ifbars/s1dedicatedservers:latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/container \
    && chmod 0755 /home /home/container

COPY patch_run.py /tmp/patch_run.py
COPY pterodactyl-entrypoint.sh /usr/local/bin/pterodactyl-entrypoint.sh
COPY pterodactyl-steamcmd.sh /usr/local/bin/pterodactyl-steamcmd.sh

ENV STEAMAPPDIR=/home/container
ENV S1DS_RUNTIME=mono
ENV STEAM_ROOT=/home/container/steam
ENV HOME=/home/container/steam
ENV WINEPREFIX=/home/container/steam/wineprefix

RUN python3 /tmp/patch_run.py \
    && install -m 0755 /home/steam/run.sh /usr/local/bin/s1ds-run.sh \
    && chmod 0755 /usr/local/bin/pterodactyl-entrypoint.sh \
    && chmod 0755 /usr/local/bin/pterodactyl-steamcmd.sh \
    && sed -i 's|/home/steam/steamcmd/steamcmd.sh|/usr/local/bin/pterodactyl-steamcmd.sh|g' /usr/local/bin/s1ds-run.sh \
    && sed -i 's|/home/container/steamcmd/steamcmd.sh|/usr/local/bin/pterodactyl-steamcmd.sh|g' /usr/local/bin/s1ds-run.sh \
    && sed -i 's|/home/container/steam/steamcmd/steamcmd.sh|/usr/local/bin/pterodactyl-steamcmd.sh|g' /usr/local/bin/s1ds-run.sh \
    && sed -i 's|/home/steam/steamworks_redist|/home/container/steam/steamworks_redist|g' /usr/local/bin/s1ds-run.sh \
    && sed -i 's|/home/container/steamworks_redist|/home/container/steam/steamworks_redist|g' /usr/local/bin/s1ds-run.sh \
    && chmod 0755 /usr/local/bin/s1ds-run.sh \
    && chmod 0755 /home \
    && chmod -R a+rX /home/steam \
    && rm /tmp/patch_run.py \
    && grep -n "steamcmd.sh\|pterodactyl-steamcmd\|steamworks_redist\|1007" /usr/local/bin/s1ds-run.sh

WORKDIR /home/container

ENTRYPOINT ["/bin/bash", "/usr/local/bin/pterodactyl-entrypoint.sh"]