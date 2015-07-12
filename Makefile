all: build

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

CAPABILITIES = \
	--cap-add=SYS_ADMIN

ENV_VARS= \
	--env="USER_UID=$(shell id -u)" \
	--env="USER_GID=$(shell id -g)" \
	--env="DISPLAY" \
	--env="XAUTHORITY=${XAUTH}"

VOLUMES = \
	--volume=${XSOCK}:${XSOCK} \
	--volume=${XAUTH}:${XAUTH} \
	--volume=/run/user/$(shell id -u)/pulse:/run/pulse

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
	@touch ${XAUTH}
	@xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -
	docker run -it --rm \
		${CAPABILITIES} \
		${ENV_VARS} \
		${VOLUMES} \
		${USER}/browser-box:latest $@
