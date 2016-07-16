FROM sameersbn/ubuntu:14.04.20160710

ENV TOR_VERSION=6.0.2 \
    TOR_FINGERPRINT=0x4E2C6E8793298290

RUN wget -q -O - "https://dl-ssl.google.com/linux/linux_signing_key.pub" | sudo apt-key add - \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && mkdir ~/.gnupg \
 && gpg --keyserver hkp://hkps.pool.sks-keyservers.net:80 --recv-keys ${TOR_FINGERPRINT} \
 && gpg --fingerprint ${TOR_FINGERPRINT} | grep -q "Key fingerprint = EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290" \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y xz-utils file locales dbus-x11 pulseaudio dmz-cursor-theme curl \
      fonts-dejavu fonts-liberation hicolor-icon-theme \
      libcanberra-gtk3-0 libcanberra-gtk-module libcanberra-gtk3-module \
      libasound2 libglib2.0 libgtk2.0-0 libdbus-glib-1-2 libxt6 libexif12 \
      libgl1-mesa-glx libgl1-mesa-dri libstdc++6 nvidia-346 \
      gstreamer-1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
      gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
      google-chrome-stable chromium-browser firefox \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && mkdir -p /usr/lib/tor-browser \
 && wget -O /tmp/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz  https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz \
 && wget -O /tmp/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc \
 && gpg /tmp/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc \
 && tar -Jvxf /tmp/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz --strip=1 -C /usr/lib/tor-browser \
 && ln -sf /usr/lib/tor-browser/Browser/start-tor-browser /usr/bin/tor-browser \
 && rm -rf /tmp/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz \
 && rm -rf ~/.gnupg \
 && rm -rf /var/lib/apt/lists/*

COPY scripts/ /var/cache/browser-box/
COPY entrypoint.sh /sbin/entrypoint.sh
COPY confs/local.conf /etc/fonts/local.conf
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
