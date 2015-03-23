FROM sameersbn/ubuntu:14.04.20150323

RUN wget -q -O - "https://dl-ssl.google.com/linux/linux_signing_key.pub" | sudo apt-key add - \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y xz-utils file locales dbus-x11 pulseaudio dmz-cursor-theme \
      fonts-dejavu fonts-liberation hicolor-icon-theme google-chrome-stable \
      libcanberra-gtk3-0 libcanberra-gtk-module libcanberra-gtk3-module \
      libasound2 libgtk2.0-0 libdbus-glib-1-2 libxt6 libexif12 \
      libgl1-mesa-glx libgl1-mesa-dri \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && mkdir -p /usr/lib/tor-browser \
 && wget -nv https://www.torproject.org/dist/torbrowser/4.0.4/tor-browser-linux64-4.0.4_en-US.tar.xz -O - \
      | tar -Jvxf - --strip=1 -C /usr/lib/tor-browser \
 && ln -sf /usr/lib/tor-browser/start-tor-browser /usr/bin/tor-browser \
 && rm -rf /var/lib/apt/lists/* # 20150323

ADD scripts /scripts
ADD start /start
RUN chmod 755 /start

ENTRYPOINT ["/start"]
