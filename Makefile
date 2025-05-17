PUB_DIR := publish/
MEDIA_DIR := media/
IMG_DIR := $(MEDIA_DIR)images/
CSS_DIR := css/

all: publish

publish: $(PUB_DIR)$(CSS_DIR)*.css $(PUB_DIR)$(IMG_DIR)*.webp $(PUB_DIR)$(MEDIA_DIR)*.svg $(PUB_DIR)*.ico
	emacs --batch --no-init --load publish.el --funcall org-publish-all

$(PUB_DIR)$(IMG_DIR)%.webp: $(IMG_DIR)%.jpg | $(PUB_DIR)$(IMG_DIR)
	mogrify -strip -auto-orient -resize '1920x1080' -format 'webp' -path $| $^

$(PUB_DIR)$(CSS_DIR)%.css: $(CSS_DIR)%.css | $(PUB_DIR)$(CSS_DIR)
	cp $^ $|

$(PUB_DIR)$(MEDIA_DIR)%.svg: $(MEDIA_DIR)%.svg | $(PUB_DIR)$(MEDIA_DIR)
	cp $^ $|

$(PUB_DIR)%.ico: %.ico | $(PUB_DIR)
	cp $^ $|

$(PUB_DIR)$(IMG_DIR): | $(PUB_DIR)
	mkdir -p $@

$(PUB_DIR)$(MEDIA_DIR): | $(PUB_DIR)
	mkdir -p $@

$(PUB_DIR)$(CSS_DIR): | $(PUB_DIR)
	mkdir -p $@

$(PUB_DIR):
	mkdir -p $@

mostlyclean:
	emacs --batch --no-init --eval "(require 'ox-publish)" --eval "(org-publish-remove-all-timestamps)"

clean: mostlyclean
	rm -rf publish/
	rm org/sitemap.org
	rm org/posts/rss.org

.PHONY: all publish mostlyclean clean
