.PHONY: build run clean

APP_NAME = DynamicIslandBar
BUILD_DIR = .build

build:
	swift build -c release

run: build
	swift run -c release

clean:
	rm -rf $(BUILD_DIR)

bundle: build
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp .build/release/$(APP_NAME) $(APP_NAME).app/Contents/MacOS/
	cp Resources/Info.plist $(APP_NAME).app/Contents/Info.plist
	echo "APPL????" > $(APP_NAME).app/Contents/PkgInfo
	@echo "Bundle created: $(APP_NAME).app"