all: build

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build            - build the browser-box image"
	@echo "   1. make install          - install launch wrappers"
	@echo "   2. make google-chrome    - launch google-chrome"
	@echo "   2. make tor-browser      - launch tor-browser"
	@echo "   2. make bash             - bash login"
	@echo ""

build:
	@docker build --tag=${USER}/browser-box .

install uninstall: build
	@docker run -it --rm \
		--volume=/usr/local/bin:/target \
		${USER}/browser-box:latest $@

google-chrome tor-browser chromium-browser firefox bash:
	@docker run -it --rm --cap-add=SYS_ADMIN \
		--env="USER_UID=$(shell id -u)" \
		--env="USER_GID=$(shell id -g)" \
		--env="DISPLAY" \
		--volume=/tmp/.X11-unix:/tmp/.X11-unix \
		--volume=/run/user/$(shell id -u)/pulse:/run/pulse \
		${USER}/browser-box:latest $@
