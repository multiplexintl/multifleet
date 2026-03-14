# Makefile for deploying Flutter web app to GitHub Pages

# Update These Variables
BASE_HREF = '/multifleet-web/'
GITHUB_REPO = https://github.com/multiplexintl/multifleet-web.git
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}')

deploy-web:
	@echo "Clean existing repository..."
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Building for web..."
	flutter build web --base-href $(BASE_HREF) --release

	@echo "Deploying to git repository"
	cd build/web && \
	git init && \
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" && \
	git branch -M main && \
	git remote add origin $(GITHUB_REPO) && \
	git push -u --force origin main

	cd ../..
	@echo "🟢 Finished Deploy"

deploy-test:
	@echo "Building for test.multifleet.ae..."
	flutter clean
	flutter pub get
	flutter build web --base-href / --release
	@echo "Uploading via FTP..."
	lftp -e "mirror -R --delete build/web/ /test.multifleet.ae/; quit" \
	     -u $(FTP_USER),$(FTP_PASS) ftp://185.243.77.85
	@echo "🟢 Deployed to test.multifleet.ae"

.PHONY: deploy-web deploy-test