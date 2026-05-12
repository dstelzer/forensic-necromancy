SOURCES = $(shell dgt sources)
COVER = --cover cover.jpg --cover-alt "A woodcut of an ancient Assyrian man fleeing a palace, with the game title overlaid onto it."

build: web itch.zip vanisher.z5

cover.jpg: cover_large.jpg
	convert cover_large.jpg -resize 1000x1000 cover.jpg

cover_small.jpg: cover_large.jpg
	convert cover_large.jpg -resize 500x500 cover_small.jpg

vvv.log: $(SOURCES) platform/z5.dg
	dialogc -t z5 platform/z5.dg $(SOURCES) -vvv -o tmp.z5 >vvv.log 2>&1
	rm tmp.z5

vanisher.web.aastory: $(SOURCES) platform/web.dg
	dialogc -t aa platform/web.dg $(SOURCES) -vv -o vanisher.web.aastory 2>&1 | tee build.web

web: vanisher.web.aastory hints.html cover.jpg
	rm -rf web
	aambundle -t web vanisher.web.aastory -o web
##	cp -r modweb/* -t web -v
	mv web/play.html web/index.html
	cp hints.html web/
	cp cover.jpg web/

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
