SOURCES = $(shell dgt -N sources)
COVER = --cover cover.jpg --cover-alt "A woodcut of an ancient Assyrian man fleeing a palace, with the game title overlaid onto it."
OPTIONS = -vv -H 1500
VERSION = 5

regress:
	dgt skein run

build: web itch.zip forensic.z5 c64.zip

cover.jpg: cover_large.jpg
	convert cover_large.jpg -resize 1000x1000 cover.jpg

cover_small.jpg: cover_large.jpg
	convert cover_large.jpg -resize 500x500 cover_small.jpg

vvv.log: $(SOURCES) platform/z5.dg
	dialogc -t z5 platform/z5.dg $(SOURCES) -vvv -o tmp.z5 >vvv.log 2>&1
	rm tmp.z5

forensic.web.aastory: $(SOURCES) platform/web.dg hints.html history.html
	dialogc -t aa platform/web.dg $(SOURCES) $(OPTIONS) -o forensic.web.aastory 2>&1 | tee build.web

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
	dialogc -t aa platform/c64.dg $(SOURCES) $(OPTIONS) -o forensic.c64.aastory 2>&1 | tee build.c64

c64.zip: forensic.c64.aastory
	rm -f c64.zip
	rm -rf c64
	aambundle -t c64 -o c64 forensic.c64.aastory
	cp hints.html c64/
	cp history.html c64/
	cp cover.jpg c64/
	cp README.c64 c64/
	( cd c64 && zip -r ../c64.zip . )

forensic.z5: $(SOURCES) platform/z5.dg
	dialogc -t z5 platform/z5.dg $(SOURCES) $(OPTIONS) -o forensic.z5 2>&1 | tee build.z5

zplay: forensic.z5
	gargoyle forensic.z5

z5.zip: forensic.z5 hints.html history.html
	rm -rf z5
	rm -f z5.zip
	mkdir z5
	cp forensic.z5 z5/
	cp hints.html z5/
	cp history.html z5/
	cp cover.jpg z5/
	rm -f z5.zip
	( cd z5 && zip -r ../z5.zip . )

itch: itch.zip z5.zip c64.zip
	cp itch.zip itch_$(VERSION).zip
	cp z5.zip z5_$(VERSION).zip
	cp c64.zip c64_$(VERSION).zip
	cp itch_$(VERSION).zip web_$(VERSION).zip
	butler push itch_$(VERSION).zip dercomai/forensic-necromancy:online
	butler push z5_$(VERSION).zip dercomai/forensic-necromancy:z
	butler push c64_$(VERSION).zip dercomai/forensic-necromancy:c64
	butler push web_$(VERSION).zip dercomai/forensic-necromancy:download

PWD := $(shell pwd)
hints.html: hints.clu
	( cd ~/Projects/Invisiclues && python3 maker.py $(PWD)/hints )

.PHONY: build play zplay regress itch
all: build
