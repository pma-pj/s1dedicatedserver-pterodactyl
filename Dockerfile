FROM ghcr.io/ifbars/s1dedicatedservers:latest

USER root

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

RUN python3 /tmp/patch_run.py \
    && chmod +x /home/steam/run.sh \
    && rm /tmp/patch_run.py

ENTRYPOINT ["/bin/bash", "/home/steam/run.sh"]
