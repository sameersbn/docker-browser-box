#!/bin/bash
set -e

case "$1" in
  install)
    echo "Installing browser-box..."
    install -m 0755 /scripts/browser-box /target/
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
    ;;
  uninstall)
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
    ;;
  google-chrome|google-chrome-stable|tor-browser|chromium-browser|firefox)
    # uid and gid of host user
    USER_UID=${USER_UID:-1000}
    USER_GID=${USER_GID:-1000}

    # create user group
    if ! getent group ${WEB_BROWSER_USER} >/dev/null; then
      groupadd -f -g ${USER_GID} ${WEB_BROWSER_USER}
    fi

    # create user with uid and gid matching that of the host user
    if ! getent passwd ${WEB_BROWSER_USER} >/dev/null; then
      adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
        --gecos 'Browser Box' ${WEB_BROWSER_USER}
    fi

    # grant access to video devices
    for device in /dev/video*
    do
      if [[ -c $device ]]; then
        VIDEO_GID=$(stat -c %g $device)
        break
      fi
    done

    if [[ -n $VIDEO_GID ]]; then
      usermod -a -G $VIDEO_GID ${WEB_BROWSER_USER}
    fi

    cd /home/${WEB_BROWSER_USER}
    exec sudo -u ${WEB_BROWSER_USER} -H PULSE_SERVER=/run/pulse/native $@ ${extra_opts}
    ;;
  bash)
    exec $@
    ;;
esac
