SRC := .
POSTSDIR := posts
DST := dist
TEMPLATESDIR := templates
STATICDIR := static

POST_MDS := $(wildcard $(POSTSDIR)/*.md)
STATIC_RESOURCES := $(wildcard $(STATICDIR)/*)

POST_HTMLS := $(patsubst $(POSTSDIR)%, $(DST)%, $(patsubst %.md, %.html, $(POST_MDS)))
OUT_RESOURCES := $(patsubst $(STATICDIR)%, $(DST)%, $(STATIC_RESOURCES))


.PHONY: all clean live

all: $(POST_HTMLS) $(OUT_RESOURCES)
	@echo "Building..."

$(DST)/%.html : $(POSTSDIR)/%.md
	pandoc -s -f markdown_strict+yaml_metadata_block -t html5 \
		--template $(TEMPLATESDIR)/pandoc-html5.html \
		-o $(DST)/$(notdir $@) \
		$<

$(DST)/% : $(STATICDIR)/%
	cp -r $< $@

live:
	caddy file-server -browse -listen 127.0.0.1:8000 --root $(DST)&
	firefox -new-tab http://127.0.0.1:8000
	@echo "Kill with 'pkill caddy'"
clean:
		@rm -r $(DST)/*
