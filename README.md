# Docker Snapserver

Docker image for [Snapcast](https://github.com/badaix/snapcast)'s `snapserver`,
based on Debian 13 "trixie" (which packages Snapcast natively).

The image ships Snapcast's stock, unmodified `/etc/snapserver.conf` — by
default it listens for audio on the sample named pipe
(`pipe:///tmp/snapfifo?name=default`) and serves clients on the usual ports.
To configure your own stream(s), mount your own config over the default:

```sh
docker run -d \
  -v /path/to/your/snapserver.conf:/etc/snapserver.conf:ro \
  -v snapserver-data:/var/lib/snapserver \
  -p 1704:1704 \
  -p 1705:1705 \
  -p 1780:1780 \
  fr3nd/snapserver:${SNAPSERVER_VERSION}
```

- `1704` — stream port, what `snapclient`s connect to.
- `1705` — TCP JSON-RPC control port.
- `1780` — HTTP control/JSON-RPC and the built-in web UI.
- `/var/lib/snapserver` is where `server.json` (client/group names, volumes,
  latency) is persisted between restarts — mount a volume there if you want
  that to survive container recreation.

See the [Snapcast configuration docs](https://github.com/badaix/snapcast/blob/master/doc/configuration.md)
for the full `snapserver.conf` reference (stream source types — pipe, tcp,
process, alsa, librespot, airplay, etc.).

Runs as an unprivileged `snapserver` user (in the `audio` group, for `alsa://`
stream sources). mDNS/zeroconf publishing needs a running `avahi-daemon`
reachable over D-Bus, which the container doesn't include — mount the host's
`/var/run/dbus` (and run with `network_mode: host`) if you want clients to
auto-discover the server; otherwise point `snapclient`s at the host directly.
