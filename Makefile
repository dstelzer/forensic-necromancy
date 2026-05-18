SOURCES = $(shell dgt sources)
COVER = --cover cover.jpg --cover-alt "A woodcut of an ancient Assyrian man fleeing a palace, with the game title overlaid onto it."

build: web itch.zip forensic.z5

cover.jpg: cover_large.jpg
	convert cover_large.jpg -resize 1000x1000 cover.jpg

cover_small.jpg: cover_large.jpg
	convert cover_large.jpg -resize 500x500 cover_small.jpg

vvv.log: $(SOURCES) platform/z5.dg
	dialogc -t z5 platform/z5.dg $(SOURCES) -vvv -o tmp.z5 >vvv.log 2>&1
	rm tmp.z5

forensic.web.aastory: $(SOURCES) platform/web.dg hints.html history.html
	dialogc -t aa platform/web.dg $(SOURCES) -vv -o forensic.web.aastory -H 1500 2>&1 | tee build.web

web: forensic.web.aastory hints.html cover.jpg
	rm -rf web
	aambundle -t web forensic.web.aastory -o web
##	cp -r modweb/* -t web -v
	mv web/play.html web/index.html
	cp cover.jpg web/

play: web
	xdg-open web/index.html

itch.zip: web
	rm -f itch.zip
	( cd web && zip -r ../itch.zip . )

forensic.c64.aastory: $(SOURCES) platform/c64.dg
	dialogc -t aa platform/c64.dg $(SOURCES) -vv -o forensic.c64.aastory -H 1500 2>&1 | tee build.c64

forensic.z5: $(SOURCES) platform/z5.dg
	dialogc -t z5 platform/z5.dg $(SOURCES) -vv -o forensic.z5 -H 1500 2>&1 | tee build.z5

z5.zip: forensic.z5 hints.html history.html
	rm -rf z5
	mkdir z5
	cp forensic.z5 z5/
	cp hints.html z5/
	cp history.html z5/
	cp cover.jpg z5/
	rm -f z5.zip
	( cd z5 && zip -r ../z5.zip . )

# Uploaded as non-playable to Itch for download people
web.zip: itch.zip
	rm -rf web.zip
	cp itch.zip web.zip

PWD := $(shell pwd)
hints.html: hints.clu
	( cd ~/Projects/Invisiclues && python3 maker.py $(PWD)/hints )

.PHONY: build play
all: build
