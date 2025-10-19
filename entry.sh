#!/bin/sh

# Update config in the configuration file
function updateConfigValue() {
  sed -i "s/\(^$1 *= *\).*/\1${2//&/\\&}/" $server_ini
}

# Symlink
echo "Creating symlink for config folder..."
if [ ! -d /data/config ]
then
  mkdir -p /data/config
fi
ln -s /data/config /root/Zomboid

# Update pzserver
echo "Updating Project Zomboid..."
if [ "$SERVER_BRANCH" == "" ]
then
  steamcmd +force_install_dir /data/server-file +login anonymous +app_update 380870 +quit
else
  steamcmd +force_install_dir /data/server-file +login anonymous +app_update 380870 -beta ${SERVER_BRANCH} +quit
fi

if [ -n "${FORCESTEAMCLIENTSOUPDATE}" ]; then
  echo "FORCESTEAMCLIENTSOUPDATE variable is set, updating steamclient.so in Zomboid's server"
  cp "/root/.steam/sdk64/steamclient.so" "/data/server-file/linux64/steamclient.so"
  cp "/root/.steam/sdk32/steamclient.so" "/data/server-file/steamclient.so"
fi



# Apply server connfiguration
server_ini="/data/config/Server/${SERVER_NAME}.ini"

if [ ! -f $server_ini ]
then
  echo "Updating ${SERVER_NAME}.ini..."
  mkdir -p /data/config/Server
  touch ${server_ini}

  echo "DefaultPort=${SERVER_PORT}" >> ${server_ini}
  echo "UDPPort=${SERVER_UDP_PORT}" >> ${server_ini}
  echo "Password=${SERVER_PASSWORD}" >> ${server_ini}
  echo "Public=${SERVER_PUBLIC}" >> ${server_ini}
  echo "PublicName=${SERVER_PUBLIC_NAME}" >> ${server_ini}
  echo "PublicDescription=${SERVER_PUBLIC_DESC}" >> ${server_ini}
  echo "RCONPort=${RCON_PORT}" >> ${server_ini}
  echo "RCONPassword=${RCON_PASSWORD}" >> ${server_ini}
  echo "MaxPlayers=${SERVER_MAX_PLAYER}" >> ${server_ini}
  echo "Mods=${MOD_NAMES}" >> ${server_ini}
  echo "WorkshopItems=${MOD_WORKSHOP_IDS}" >> ${server_ini}
else
  updateConfigValue "DefaultPort" ${SERVER_PORT}
  updateConfigValue "UDPPort" ${SERVER_UDP_PORT}
  updateConfigValue "Password" ${SERVER_PASSWORD}
  updateConfigValue "Public" ${SERVER_PUBLIC}
  updateConfigValue "PublicName" "${SERVER_PUBLIC_NAME}"
  updateConfigValue "PublicDescription" "${SERVER_PUBLIC_DESC}"
  updateConfigValue "RCONPort" ${RCON_PORT}
  updateConfigValue "RCONPassword" ${RCON_PASSWORD}
  updateConfigValue "MaxPlayers" ${SERVER_MAX_PLAYER}
  updateConfigValue "Mods" "${MOD_NAMES}"
  updateConfigValue "WorkshopItems" "${MOD_WORKSHOP_IDS}"
fi

# Copy default spawn locations file to server config folder
mkdir -p /data/config/${SERVER_NAME^}
if [ ! -f /data/config/${SERVER_NAME^}/server_spawnregions.lua ]
then
  cp /data/server_spawnregions.lua /data/config/${SERVER_NAME^}/server_spawnregions.lua
fi

# Start server
echo "Launching server..."
cd /data/server-file
./start-server.sh -servername ${SERVER_NAME} -adminpassword ${SERVER_ADMIN_PASSWORD} -Ddebug -debug
