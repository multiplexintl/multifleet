# Makefile for MultiFleet Flutter Web Deployment
# Usage:
#   make deploy-test   FTP_USER=xxx FTP_PASS=xxx   → test.multifleet.ae  (testapi)
#   make deploy-prod   FTP_USER=xxx FTP_PASS=xxx   → multifleet.ae       (live api)

FTP_SERVER = 185.243.77.85

deploy-test:
	@echo "Building for test.multifleet.ae..."
	flutter clean
	flutter pub get
	cp "assets/cfg/config test.json" assets/cfg/config.json
	flutter build web --base-href / --release
	@echo "Uploading via FTP..."
	lftp -e "mirror -R --delete build/web/ /test.multifleet.ae/; quit" \
	     -u $(FTP_USER),$(FTP_PASS) ftp://$(FTP_SERVER)
	@echo "Done. https://test.multifleet.ae"

deploy-prod:
	@echo "Building for multifleet.ae (PRODUCTION)..."
	flutter clean
	flutter pub get
	cp "assets/cfg/config live.json" assets/cfg/config.json
	flutter build web --base-href / --release
	@echo "Uploading via FTP..."
	lftp -e "mirror -R --delete build/web/ /multifleet.ae/; quit" \
	     -u $(FTP_USER),$(FTP_PASS) ftp://$(FTP_SERVER)
	@echo "Done. https://multifleet.ae"

.PHONY: deploy-test deploy-prod
