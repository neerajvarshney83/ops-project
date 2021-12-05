# Check for  updates
sudo apt-get update

# ---------------------------------------------------
# Unistall the Debian Packages in uninstall_pkg file
# ---------------------------------------------------
if [ -s debian_packages/uninstall_pkg ]; then
  declare -a remove_pkg
  while IFS='\n' read -r value; do
    remove_pkg+=( "${value}" )
  done < "debian_packages/uninstall_pkg"
  for rm_pkg in "${remove_pkg[@]}"
  do
    if dpkg -l | grep -i "${rm_pkg}"; then
      sudo apt-get remove "${rm_pkg}"
      sudo apt-get autoremove
      sudo apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}')
      sudo apt-get clean
    fi
  done
fi

# ------------------------------------------------
# Install the Debian Packages in install_pkg file
# -----------------------------------------------
if [ -s debian_packages/install_pkg ]; then
  declare -a install_pkg
  while IFS='\n' read -r value; do
    install_pkg+=( "${value}" )
  done < "debian_packages/install_pkg"
  for in_pkg in "${install_pkg[@]}"
  do
    if ! dpkg -l | grep "${in_pkg}"; then
      sudo apt-get install -y "${in_pkg}"
    fi
  done
fi

# --------------------------------
# Setting Metadata and index file
# --------------------------------

if [ -s metadata.txt ]; then
  if [ -f "/var/www/html/index.html" ]; then
	  sudo rm /var/www/html/index.html
  fi
  if [ -f "/var/www/html/index.php" ]; then
	  sudo rm /var/www/html/index.php
  fi
  touch /var/www/html/index.php
  declare -A metadata
  while IFS== read -r key value; do
    metadata[$key]=$value
  done < "metadata.txt"
  sudo echo "${metadata[content]}" > "${metadata[file]}"
fi

# --------------------------
# Check for Required Restart
# --------------------------
needrestart
