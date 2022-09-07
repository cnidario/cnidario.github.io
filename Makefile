MDS := $(wildcard post/*.md)
IMAGES := $(shell find static/ -type f '(' -name '*.png' -o -name '*.jpg' -o -name '*.svg' ')' )
HTMLS := $(patsubst post%, dist/post%, $(patsubst %.md, %.html, $(MDS))) dist/posts.html dist/home.html dist/about.html
EXTRAS := $(wildcard static/extra/*)
CSS := $(wildcard static/css/*.css)
JS := $(wildcard static/js/*)

OUT_IMGS := $(patsubst static/img%, dist/img%, $(IMAGES))
OUT_CSS := $(patsubst static/css%, dist/css%, $(CSS))
OUT_EXTRAS := $(patsubst static/extra%, dist/extra%, $(EXTRAS))
OUT_JS := $(patsubst static/js%, dist/js%, $(JS))
.PHONY: all dist dist-clean clean live

all: $(HTMLS) $(OUT_IMGS) $(OUT_CSS) $(OUT_JS) $(OUT_EXTRAS) dist/css/highlight.css static/css/water.css

dist: all dist-clean

dist/post/%.html : post/%.md templates/pandoc-html5.html scripts/pandoc-code.lua
	@mkdir -p dist/post
	@echo "Processing" $@
	$(shell pandoc -s -f markdown+yaml_metadata_block -t html5 \
		--lua-filter scripts/pandoc-code.lua \
		--citeproc \
		--template templates/pandoc-html5.html \
		$< | minify --type html -o $@)

dist/img/% : static/img/%
	@mkdir -p $(@D)
	@cp $< $@
dist/js/% : static/js/%
	@mkdir -p $(@D)
	@cp $< $@
dist/extra/% : static/extra/%
	@mkdir -p $(@D)
	@cp $< $@

dist/css/highlight.css :
	$(shell pygmentize -S inkpot -f html -a .highlight | minify --type css -o $@)
dist/css/% : static/css/%
	@mkdir -p $(@D)
	minify $< -o $@

tmp/titles.md : post/*.md templates/pandoc-html5.html
	@echo "Generating titles..."
	@mkdir -p tmp
	$(shell awk -v delim=0 -v draft=0 -F': ' \
		'$$1=="title" { \
		  title = $$2; \
		  htmlfn=FILENAME; \
		  sub(/\.md/,".html",htmlfn); \
		} \
		$$1=="date" { \
		  datefn = $$2; \
		} \
		$$1=="draft" { \
		  if(draft == "true") { draft = 1; } \
		} \
		/---/ { \
		  if(delim) { \
		    if(draft) { } \
		    else { print("- "datefn". ["title"]("htmlfn")"); } \
			delim=0; \
			draft=0; \
			nextfile; \
		  } else delim=1; \
		}' post/*.md | sort -k 1 -r > $@)

dist/posts.html : tmp/titles.md
	$(shell pandoc -s --metadata title=posts -f markdown -t html5 --template templates/pandoc-html5.html $< | minify --type html -o $@)
dist/home.html: static/home.md
	$(shell pandoc -s -f markdown -t html5 --template templates/pandoc-html5.html $< | minify --type html -o $@)
dist/about.html: static/about.md
	$(shell pandoc -s --metadata title=about -f markdown -t html5 --template templates/pandoc-html5.html $< | minify --type html -o $@)

live:
	caddy file-server -browse -listen 127.0.0.1:8000 --root dist/ &
	firefox -new-tab http://127.0.0.1:8000
	@echo "Kill with 'pkill caddy'"

clean:
		@rm -rf dist/*
		@rm -rf tmp/*

dist-clean:
	@rm -rf tmp/*
	@rm dist/post/test.html
