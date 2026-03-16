# Makefile for MultiFleet Flutter Web Deployment
# Credentials are read from macOS Keychain — never stored in plain text.
#
# One-time setup (run once in Terminal):
#   security add-generic-password -a "FTP_USER" -s "multifleet_ftp" -w "your_ftp_username"
#   security add-generic-password -a "FTP_PASS" -s "multifleet_ftp" -w "your_ftp_password"
#
# Usage:
#   make deploy-test   → test.multifleet.ae  (test API)
#   make deploy-prod   → multifleet.ae       (live API)

FTP_SERVER = 185.243.77.85
FTP_USER  := $(shell security find-generic-password -a "FTP_USER" -s "multifleet_ftp" -w)
FTP_PASS  := $(shell security find-generic-password -a "FTP_PASS" -s "multifleet_ftp" -w)

deploy-test:
	@echo "Building for test.multifleet.ae..."
	flutter clean
	flutter pub get
	cp "assets/cfg/config test.json" assets/cfg/config.json
	flutter build web --base-href / --release
	@echo "Uploading via FTP..."
	@lftp -e "mirror -R --delete build/web/ /test.multifleet.ae/; quit" \
	     -u $(FTP_USER),$(FTP_PASS) ftp://$(FTP_SERVER)
	@echo "Done. https://test.multifleet.ae"

deploy-prod:
	@echo "Building for multifleet.ae (PRODUCTION)..."
	flutter clean
	flutter pub get
	cp "assets/cfg/config live.json" assets/cfg/config.json
	flutter build web --base-href / --release
	@echo "Uploading via FTP..."
	@lftp -e "mirror -R --delete build/web/ /multifleet.ae/; quit" \
	     -u $(FTP_USER),$(FTP_PASS) ftp://$(FTP_SERVER)
	@echo "Done. https://multifleet.ae"

.PHONY: deploy-test deploy-prod
