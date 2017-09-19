.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

all: run

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container
	@echo ""   2. make build     - build docker container
	@echo ""   3. make clean     - kill and remove docker container
	@echo ""   4. make enter     - execute an interactive bash in docker container
	@echo ""   3. make logs      - follow the logs of docker container

build: NAME TAG builddocker

# run a plain container
run: TZ build rm rundocker

temp: build temprm tempdocker

rundocker: TAG NAME HOMEDIR NICENESS
	$(eval TMP := $(shell mktemp -d --suffix=chromeTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval HOMEDIR := $(shell cat HOMEDIR))
	$(eval TAG := $(shell cat TAG))
	$(eval TZ := $(shell cat TZ))
	$(eval NICENESS := $(shell cat NICENESS))
	$(eval PROXY := $(shell cat PROXY))
	mkdir -p $(HOMEDIR)/chrome-sandbox/Downloads
	mkdir -p $(HOMEDIR)/chrome-sandbox/Pictures
	mkdir -p $(HOMEDIR)/chrome-sandbox/Torrents
	mkdir -p $(HOMEDIR)/chrome-sandbox/.chrome
	mkdir -p $(HOMEDIR)/tmp
	sudo chown -R 999:999 $(HOMEDIR)
	sudo chown -R 999:999 $(TMP)
	sudo chmod -R 770 $(HOMEDIR)
	sudo chmod -R 770 $(TMP)
	@docker run -d --name=$(NAME) \
	--cidfile="chromeCID" \
	--memory 3gb \
	--cpus 1 \
	--net host \
	-v /etc/localtime:/etc/localtime:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=unix$(DISPLAY) \
	-e NICENESS=$(NICENESS) \
	-e TZ=$(TZ) \
	-v /dev/shm:/dev/shm \
	-v /etc/hosts:/etc/hosts \
	-v $(TMP):/tmp \
	-v `pwd`/LINK:/LINK \
	-v $(HOMEDIR)/chrome-sandbox/Downloads:/home/chrome/Downloads \
	-v $(HOMEDIR)/chrome-sandbox/Pictures:/home/chrome/Pictures \
	-v $(HOMEDIR)/chrome-sandbox/Torrents:/home/chrome/Torrents \
	-v $(HOMEDIR)/chrome-sandbox/.chrome:/data \
	--security-opt seccomp=$(HOME)/chrome.json \
	--device /dev/snd \
	--device /dev/dri \
	--device /dev/bus/usb \
	--group-add audio \
	--group-add video \
	-t $(TAG)

tempdocker: TAG NAME
	$(eval TMP := $(shell mktemp -d --suffix=tempchromeTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TZ := $(shell cat TZ))
	$(eval TAG := $(shell cat TAG))
	$(eval PROXY := $(shell cat PROXY))
	$(eval NICENESS := $(shell cat NICENESS))
	mkdir -p $(TMP)/chrome-sandbox/Downloads
	mkdir -p $(TMP)/chrome-sandbox/Pictures
	mkdir -p $(TMP)/chrome-sandbox/Torrents
	mkdir -p $(TMP)/chrome-sandbox/.chrome
	mkdir -p $(TMP)/tmp
	sudo chmod -R 770 $(TMP)
	sudo chown -R 999:999 $(TMP)
	@docker run -d --name=$(NAME)-temp \
	--cidfile="tempCID" \
	-v $(TMP)/tmp:/tmp \
	--memory 3gb \
	--cpus 1 \
	--net host \
	-v /etc/localtime:/etc/localtime:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=unix$(DISPLAY) \
	-e NICENESS=$(NICENESS) \
	-e TZ=$(TZ) \
	-v /dev/shm:/dev/shm \
	-v /etc/hosts:/etc/hosts \
	-v $(TMP)/chrome-sandbox/Downloads:/root/Downloads \
	-v $(TMP)/chrome-sandbox/Pictures:/root/Pictures \
	-v $(TMP)/chrome-sandbox/Torrents:/root/Torrents \
	-v $(TMP)/chrome-sandbox/.chrome:/data \
	--security-opt seccomp=$(HOME)/chrome.json \
	--device /dev/snd \
	--device /dev/dri \
	--device /dev/bus/usb \
	--group-add audio \
	--group-add video \
	-t $(TAG)

builddocker:
	/usr/bin/time -v docker build -t `cat TAG` .

kill:
	-@docker kill `cat chromeCID`

rm-image:
	-@docker rm `cat chromeCID`
	-@rm chromeCID

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat chromeCID` /bin/bash

logs:
	docker logs -f `cat chromeCID`

# temp stuff
tempkill:
	-@docker kill `cat tempCID`

temp-rm-image:
	-@docker rm `cat tempCID`
	-@rm tempCID

temprm: tempkill temp-rm-image

tempclean: temprm

tempenter:
	docker exec -i -t `cat tempCID` /bin/bash

templogs:
	docker logs -f `cat tempCID`

proxy: PROXY

PROXY:
	@while [ -z "$$PROXY" ]; do \
		read -r -p "Enter the proxy you wish to associate with this container [PROXY]: " PROXY; echo "$$PROXY">>PROXY; cat PROXY; \
	done ;

HOMEDIR:
	@while [ -z "$$HOMEDIR" ]; do \
		read -r -p "Enter the destination of the home directory you wish to associate with this container [HOMEDIR]: " HOMEDIR; echo "$$HOMEDIR">>HOMEDIR; cat HOMEDIR; \
	done ;

LINK:
	@while [ -z "$$LINK" ]; do \
		read -r -p "Enter the links you wish to associate with this container [LINK]: " LINK; echo "$$LINK">>LINK; cat LINK; \
	done ;

NICENESS:
	@while [ -z "$$NICENESS" ]; do \
		read -r -p "Enter the niceness you wish to associate with this container [NICENESS]: " NICENESS; echo "$$NICENESS">>NICENESS; cat NICENESS; \
	done ;

TZ:
	@while [ -z "$$TZ" ]; do \
		read -r -p "Enter the timezone you wish to associate with this container [America/Denver]: " TZ; echo "$$TZ">>TZ; cat TZ; \
	done ;
