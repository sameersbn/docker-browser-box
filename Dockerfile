FROM sameersbn/ubuntu:14.04.20150805

ENV TOR_BROWSER_VERSION=4.5.3 \
    WEB_BROWSER_USER=browser

RUN wget -q -O - "https://dl-ssl.google.com/linux/linux_signing_key.pub" | sudo apt-key add - \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y xz-utils file locales dbus-x11 pulseaudio dmz-cursor-theme \
      fonts-dejavu fonts-liberation hicolor-icon-theme \
      libcanberra-gtk3-0 libcanberra-gtk-module libcanberra-gtk3-module \
      libasound2 libgtk2.0-0 libdbus-glib-1-2 libxt6 libexif12 \
      libgl1-mesa-glx libgl1-mesa-dri \
      google-chrome-stable chromium-browser firefox \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && mkdir -p /usr/lib/tor-browser \
 && wget -O /tmp/tor-browser-linux64-${TOR_BROWSER_VERSION}_en-US.tar.xz \
      https://www.torproject.org/dist/torbrowser/${TOR_BROWSER_VERSION}/tor-browser-linux64-${TOR_BROWSER_VERSION}_en-US.tar.xz \
 && tar -Jvxf /tmp/tor-browser-linux64-${TOR_BROWSER_VERSION}_en-US.tar.xz --strip=1 -C /usr/lib/tor-browser \
 && ln -sf /usr/lib/tor-browser/Browser/start-tor-browser /usr/bin/tor-browser \
 && rm -rf /tmp/tor-browser-linux64-${TOR_BROWSER_VERSION}_en-US.tar.xz \
 && rm -rf /var/lib/apt/lists/*

COPY scripts /scripts
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
