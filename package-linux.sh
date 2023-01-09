#!/usr/bin/env bash

# SMM_WE GMS2 Linux package script
# 2022 YidaozhanYa

SOURCE_FILE="SMM-WE-3.3.0.exe"
RUNNER_URL="https://github.com/YidaozhanYa/yoyogames-runner-bin/raw/main/runner_x64.1.3"
DISCORD_RPC_URL="https://github.com/discord/discord-rpc/releases/download/v3.4.0/discord-rpc-linux.zip"

function msg() {
    echo -e "\033[1;34m::\033[1;0m ${1}\033[0m"
}

msg "Start packaging for Linux..."
DEST_DIR="${SOURCE_FILE//-/_}"
DEST_DIR="${DEST_DIR//.exe/}"
mkdir -p "$DEST_DIR"

msg "Extracting game..."
7z x "$SOURCE_FILE" -o"${DEST_DIR}/assets"

msg "Adjusting file structure..."
pushd "${DEST_DIR}/assets"
rm -rf "\$PLUGINSDIR"
rm -rf "\$TEMP"
rm "\${SMM_WE}.exe"
rm "Uninstall.exe"
rm "D3DX9_43.dll"
mv "data.win" "game.unx"
popd

msg "Installing YoYo Games Linux Runner..."
pushd "${DEST_DIR}"
curl -L "$RUNNER_URL" -oSMM_WE
chmod 755 SMM_WE
popd

msg "Installing Discord RPC for Linux..."
pushd "${DEST_DIR}/assets"
curl -L "$DISCORD_RPC_URL" -odiscord-rpc-linux.zip
7z x discord-rpc-linux.zip discord-rpc/linux-dynamic/lib/libdiscord-rpc.so -o.
mv discord-rpc/linux-dynamic/lib/libdiscord-rpc.so ./libdiscord-rpc.so
rm discord-rpc{,-main}.dll
rm -r discord-rpc{,-linux.zip}
popd

msg "Renaming resources to lower case..."
pushd "${DEST_DIR}/assets"
for SRC in *.ogg; do
    DST="$(printf "${SRC}" | tr '[A-Z]' '[a-z]')"
    if [ "${SRC}" != "${DST}" ]; then
        [ ! -e "${DST}" ] && mv -T "${SRC}" "${DST}"
    fi
done
popd

msg "Creating final package..."
cp _README.txt "$DEST_DIR/README.txt"
tar -czvf "${DEST_DIR}.tar.gz" "$DEST_DIR"

msg "Cleaning up..."
rm -rf "$DEST_DIR"

msg "Done!"
