#!/usr/bin/env bash

# Copyright (c) 2021-2024 community-scripts ORG
# Author: Storm Van Soldt (stormvansoldt)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

# Import Functions and Setup
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Installing Dependencies with the 3 core dependencies (curl;sudo;mc;wget)
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc \
  wget \
  ffmpeg
msg_ok "Installed Dependencies"

# Setup App
msg_info "Installing Stash"
RELEASE=$(curl -fsSL https://api.github.com/repos/stashapp/stash/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
wget -q "https://github.com/stashapp/stash/releases/download/v${RELEASE}/stash-linux"
mv stash-linux /opt/stash && chmod +x /opt/stash
msg_info "Creating version file"
echo "${RELEASE}" >"/opt/stash_version.txt"
msg_ok "Stash has been installed in /opt"

# Creating Service (if needed)
msg_info "Creating Service"
cat <<EOF >"/etc/systemd/system/stash.service"
[Unit]
Description=Stash App Service
After=network.target

[Service]
ExecStart=/opt/stash
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now stash.service
msg_ok "Created and enabled service"

# Cleanup
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

motd_ssh
customize
