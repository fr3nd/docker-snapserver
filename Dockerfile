FROM debian:trixie-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      snapserver \
    && \
    apt-get clean all && \
    rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/info/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# snapserver's default datadir (server.json: volumes, groups, stream state)
# is $HOME/.config/snapserver when not daemonized, so give it a real HOME.
WORKDIR /var/lib/snapserver
ENV HOME=/var/lib/snapserver
RUN groupadd --system snapserver && \
    useradd --system --gid snapserver --groups audio \
      --home-dir /var/lib/snapserver --shell /usr/sbin/nologin snapserver && \
    mkdir -p /var/lib/snapserver/.config/snapserver && \
    chown snapserver:audio -R $HOME /entrypoint.sh && \
    chmod go+rwx -R $HOME /entrypoint.sh
USER snapserver:audio

# Persists server.json (client/group volumes, names, latency) across restarts.
VOLUME ["/var/lib/snapserver"]

EXPOSE 1704 1705 1780

#ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/snapserver"]
