FROM ghcr.io/ifbars/s1dedicatedservers:latest

USER root

# Pterodactyl persists /home/container. The upstream S1DS image persists /home/steam/game
# in normal Docker/Compose deployments, so we force the game directory to /home/container.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/container \
    && chown -R steam:steam /home/container /home/steam

COPY --chown=steam:steam patch_run.py /tmp/patch_run.py

USER steam
WORKDIR /home/container

ENV STEAMAPPDIR=/home/container
ENV S1DS_RUNTIME=mono

RUN python3 /tmp/patch_run.py && rm /tmp/patch_run.py

ENTRYPOINT ["/home/steam/run.sh"]
