documentation:

	appledoc \
		--no-repeat-first-par \
		--print-settings \
		--project-name COSMObjectiveC \
		--project-company "COSM Ltd." \
		--company-id com.cosm \
		--output ~/help \
		--keep-undocumented-objects \
		--keep-undocumented-members \
		--search-undocumented-doc \
		COSMObjectiveC

publish-docs:

	cp -r /Volumes/MacintoshHD/ross/Library/Developer/Shared/Documentation/DocSets/com.cosm.COSMObjectiveC.docset/Contents/Resources/Documents/* ../Documentation/
	git --git-dir=../Documentation/.git --work-tree=../Documentation status
	git --git-dir=../Documentation/.git --work-tree=../Documentation add .
	git --git-dir=../Documentation/.git --work-tree=../Documentation commit -am "automated commit" 
	git --git-dir=../Documentation/.git --work-tree=../Documentation push origin gh-pages;


.PHONY: documentation publish-docs
