SOURCES=$(shell dgt sources)

build: web itch.zip vanisher.z5

vanisher.web.aastory: $(SOURCES) platform/web.dg
	dialogc -t aa platform/web.dg $(SOURCES) -vv -o vanisher.web.aastory 2>&1 | tee build.web

web: vanisher.web.aastory hints.html
	rm -rf web
	aambundle -t web vanisher.web.aastory -o web
##	cp -r modweb/* -t web -v
	mv web/play.html web/index.html
	cp hints.html web/

play: web
	xdg-open web/index.html

itch.zip: web
	rm -f itch.zip
	( cd web && zip -r ../itch.zip . )

vanisher.c64.aastory: $(SOURCES) platform/c64.dg
	dialogc -t aa platform/c64.dg $(SOURCES) -vv -o vanisher.c64.aastory 2>&1 | tee build.c64

vanisher.z5: $(SOURCES) platform/z5.dg
	dialogc -t z5 platform/z5.dg $(SOURCES) -vv -o vanisher.z5 2>&1 | tee build.z5

PWD := $(shell pwd)
hints.html: hints.clu
	( cd ~/Projects/Invisiclues && python3 maker.py $(PWD)/hints )

.PHONY: build play
all: build
