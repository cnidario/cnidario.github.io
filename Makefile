
MDS := $(wildcard posts/*.md)
IMAGES := $(shell find static/ -type f '(' -name '*.png' -o -name '*.jpg' -o -name '*.svg' ')' )
HTMLS := $(patsubst posts%, dist/post%, $(patsubst %.md, %.html, $(MDS)))
CSS := $(wildcard static/css/*.css)

OUT_IMGS := $(patsubst static/img%, dist/img%, $(IMAGES))
OUT_CSS := $(patsubst static/css%, dist/css%, $(CSS))

.PHONY: all clean live

all: $(HTMLS) $(OUT_IMGS) $(OUT_CSS) dist/css/highlight.css static/css/water.css

dist/post/%.html : posts/%.md templates/pandoc-html5.html scripts/pygments
	@mkdir -p dist/post
	$(shell pandoc -s -f markdown+yaml_metadata_block -t html5 \
		-F scripts/pygments \
		--template templates/pandoc-html5.html \
		$< | minify --type html -o $@)

dist/img/% : static/img/%
	@mkdir -p $(@D)
	@cp $< $@

dist/css/highlight.css :
	#$(shell scripts/gen-highlight.sh 2>/dev/null > $@)
	$(shell pygmentize -S inkpot -f html -a .highlight | minify --type css -o $@)
dist/css/% : static/css/%
	@mkdir -p $(@D)
	minify $< -o $@

scripts/pygments: scripts/pygments.hs
	@ghc --make -dynamic scripts/pygments

static/css/water.css:
	$(shell wget https://cdn.jsdelivr.net/npm/water.css@2/out/water.css -P static/css)

.PHONY: clean live
live:
	caddy file-server -browse -listen 127.0.0.1:8000 --root dist/ &
	firefox -new-tab http://127.0.0.1:8000
	@echo "Kill with 'pkill caddy'"

clean:
		@rm -r dist/*
		@rm scripts/pygments
		@rm scripts/pygments.o
		@rm scripts/pygments.hi
