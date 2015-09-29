#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}
BROWSER_BOX_USER=${BROWSER_BOX_USER:-browser}

install_browser_box() {
  echo "Installing browser-box..."
  install -m 0755 /var/cache/browser-box/browser-box /target/
  echo "Installing google-chrome..."
  ln -sf browser-box /target/google-chrome
  echo "Installing google-chrome-stable..."
  ln -sf browser-box /target/google-chrome-stable
  echo "Installing tor-browser..."
  ln -sf browser-box /target/tor-browser
  echo "Installing chromium-browser..."
  ln -sf browser-box /target/chromium-browser
  echo "Installing firefox..."
  ln -sf browser-box /target/firefox
  echo "Installing url luancher..."
  ln -sf browser-box /target/browser-exec
  if [ "${BROWSER_BOX_USER}" != "browser" ] && [ -n "${BROWSER_BOX_USER}" ]; then
    echo "Updating user to ${BROWSER_BOX_USER}..."
    sed -i -e s%"BROWSER_BOX_USER:-browser"%"BROWSER_BOX_USER:-${BROWSER_BOX_USER}"%1 /target/browser-box
  fi
  if [[ -n "${CHROME_USERDATA}" ]]; then
    echo "Updating Chrome user volume..."
    sed -i -e s%"CHROME_USERDATA=.*$"%"CHROME_USERDATA\=${CHROME_USERDATA}"%1 /target/browser-box
  fi
  if [[ -n "${FIREFOX_USERDATA}" ]]; then
    echo "Updating FireFox user volume..."
    sed -i -e s%"FIREFOX_USERDATA=.*$"%"FIREFOX_USERDATA\=${FIREFOX_USERDATA}"%1 /target/browser-box
  fi

}

uninstall_browser_box() {
  echo "Uninstalling browser-box..."
  rm -rf /target/browser-box
  echo "Uninstalling google-chrome..."
  rm -rf /target/google-chrome
  echo "Uninstalling google-chrome-stable..."
  rm -rf /target/google-chrome-stable
  echo "Uninstalling tor-browser..."
  rm -rf /target/tor-browser
  echo "Uninstalling chromium-browser..."
  rm -rf /target/chromium-browser
  echo "Uninstalling firefox..."
  rm -rf /target/firefox
  echo "Uninstalling url launcher..."
  rm -rf /target/browser-exec
}

create_user() {
  # ensure home directory is owned by browser
  # and that profile files exist
  if [[ -d /home/${BROWSER_BOX_USER} ]]; then
    chown ${USER_UID}:${USER_GID} /home/${BROWSER_BOX_USER}
    # copy user files from /etc/skel
    cp /etc/skel/.bashrc /home/${BROWSER_BOX_USER}
    cp /etc/skel/.bash_logout /home/${BROWSER_BOX_USER}
    cp /etc/skel/.profile /home/${BROWSER_BOX_USER}
    chown ${USER_UID}:${USER_GID} \
		/home/${BROWSER_BOX_USER}/.bashrc \
		/home/${BROWSER_BOX_USER}/.profile \
		/home/${BROWSER_BOX_USER}/.bash_logout
  fi
  # create group with USER_GID
  if ! getent group ${BROWSER_BOX_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${BROWSER_BOX_USER} 2> /dev/null
  fi

  # create user with USER_UID
  if ! getent passwd ${BROWSER_BOX_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'Browser Box' ${BROWSER_BOX_USER}
  fi
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      break
    fi
  done

  if [[ -n $VIDEO_GID ]]; then
    usermod -a -G $VIDEO_GID ${BROWSER_BOX_USER}
  fi
}

launch_browser() {
  cd /home/${BROWSER_BOX_USER}
  exec sudo -u ${BROWSER_BOX_USER} -H LD_PRELOAD='/usr/$LIB/libstdc++.so.6' PULSE_SERVER=/run/pulse/native $@ ${extra_opts}
}

case "$1" in
  install)
    install_browser_box
    ;;
  uninstall)
    uninstall_browser_box
    ;;
  google-chrome|google-chrome-stable|tor-browser|chromium-browser|firefox)
    create_user
    grant_access_to_video_devices
    launch_browser $@
    ;;
  *)
    exec $@
    ;;
esac
