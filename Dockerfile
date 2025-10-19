FROM steamcmd/steamcmd:ubuntu-24

# Local
RUN apt update && apt install -y locales && locale-gen en_US.UTF-8 \
&& update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
&& . /etc/default/locale && locale

# Vim
RUN apt update && apt install -y vim

# Env var
ENV SERVER_NAME="server" \
    SERVER_PASSWORD="" \
    SERVER_ADMIN_PASSWORD="pzadmin" \
    SERVER_PORT="16261" \
    SERVER_UDP_PORT="16262" \
    SERVER_BRANCH="" \
    SERVER_PUBLIC="false" \
    SERVER_PUBLIC_NAME="Project Zomboid Docker Server" \
    SERVER_PUBLIC_DESC="" \
    SERVER_MAX_PLAYER="16" \
    MOD_NAMES="" \
    MOD_WORKSHOP_IDS="" \
    RCON_PORT="27015" \
    RCON_PASSWORD=""

# Expose ports
EXPOSE $SERVER_PORT/udp
EXPOSE $SERVER_UDP_PORT/udp
EXPOSE ${RCON_PORT}

VOLUME ["/data/server-file", "/data/config"]

# Add default spawn locations
COPY server_spawnregions.lua /data/server_spawnregions.lua

#清除已有的ENTRYPOINT
ENTRYPOINT []
COPY entry.sh /data/scripts/entry.sh
CMD ["bash", "/data/scripts/entry.sh"]

# install screen
RUN apt update && apt install -y --no-install-recommends \
  screen \
  && apt clean && rm -rf /var/lib/apt/lists/*
