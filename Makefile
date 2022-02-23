
MDS := $(wildcard post/*.md)
IMAGES := $(shell find static/ -type f '(' -name '*.png' -o -name '*.jpg' -o -name '*.svg' ')' )
HTMLS := $(patsubst post%, dist/post%, $(patsubst %.md, %.html, $(MDS))) dist/posts.html dist/home.html dist/about.html
CSS := $(wildcard static/css/*.css)

OUT_IMGS := $(patsubst static/img%, dist/img%, $(IMAGES))
OUT_CSS := $(patsubst static/css%, dist/css%, $(CSS))

.PHONY: all clean live

all: $(HTMLS) $(OUT_IMGS) $(OUT_CSS) dist/css/highlight.css static/css/water.css

dist/post/%.html : post/%.md templates/pandoc-html5.html scripts/pandoc-code.lua
	@mkdir -p dist/post
	$(shell pandoc -s -f markdown+yaml_metadata_block -t html5 \
		--lua-filter scripts/pandoc-code.lua \
		--citeproc \
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

tmp/titles.md : post/*.md templates/pandoc-html5.html
	@mkdir -p tmp
	$(shell awk -v delim=0 -F': ' '$$1=="title" {htmlfn=FILENAME;sub(/\.md/,".html",htmlfn);print("- ["$$2"]("htmlfn")")} /---/ {if(delim) {delim=0;nextfile} else delim=1;}' post/*.md > $@)

dist/posts.html : tmp/titles.md
	$(shell pandoc -s --metadata title=posts -f markdown -t html5 --template templates/pandoc-html5.html $< | minify --type html -o $@)
dist/home.html: static/home.md
	$(shell pandoc -s -f markdown -t html5 --template templates/pandoc-html5.html $< | minify --type html -o $@)
dist/about.html: static/about.md
	$(shell pandoc -s --metadata title=about -f markdown -t html5 --template templates/pandoc-html5.html $< | minify --type html -o $@)


.PHONY: clean live
live:
	caddy file-server -browse -listen 127.0.0.1:8000 --root dist/ &
	firefox -new-tab http://127.0.0.1:8000
	@echo "Kill with 'pkill caddy'"

clean:
		@rm -rf dist/*
		@rm -rf tmp/*
