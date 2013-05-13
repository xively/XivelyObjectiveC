documentation:

	appledoc \
		--no-repeat-first-par \
		--print-settings \
		--project-name XivelyObjectiveC \
		--project-company "Xively Ltd." \
		--company-id com.xively \
		--output ~/help \
 		--no-keep-undocumented-objects \
		--no-keep-undocumented-members \
		--no-warn-missing-output-path \
		--no-warn-missing-company-id \
		--no-warn-undocumented-object \
		--no-warn-undocumented-member \
		--no-warn-empty-description \
		--no-warn-unknown-directive \
		--no-warn-invalid-crossref \
		--no-warn-missing-arg \
		XivelyObjectiveC

publish-docs:

	cp -r ~/Library/Developer/Shared/Documentation/DocSets/com.xively.XivelyObjectiveC.docset/Contents/Resources/Documents/* ../Documentation/
	git --git-dir=../Documentation/.git --work-tree=../Documentation status
	git --git-dir=../Documentation/.git --work-tree=../Documentation add .
	git --git-dir=../Documentation/.git --work-tree=../Documentation commit -am "automated commit" 
	git --git-dir=../Documentation/.git --work-tree=../Documentation push origin gh-pages;

open:

	open ~/Library/Developer/Shared/Documentation/DocSets/com.xively.XivelyObjectiveC.docset/Contents/Resources/Documents/index.html

.PHONY: documentation publish-docs
