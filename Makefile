SDL_REPO_URL="https://github.com/libsdl-org/SDL.git"
SDL_REF=release-2.30.9
SDL_DIR=Vendor/SDL
SDL_XCPROJ=${SDL_DIR}/Xcode/SDL/SDL.xcodeproj
SDL_BUILD_DIR=${SDL_DIR}/Xcode/SDL/build/Release
SDL_PKG_SRC_DIR=Sources/cSDL

.PHONY: clone-sdl
clone-sdl:
	-rm -rdf ${SDL_DIR}
	-mkdir -p ${SDL_DIR}
	git clone ${SDL_REPO_URL} ${SDL_DIR} --recursive --depth=1 --branch ${SDL_REF}

.PHONY: build-sdl-static-macOS
build-sdl-static-macOS:
	xcodebuild -project ${SDL_XCPROJ} -target "Static Library" -configuration Release

.PHONY: build-sdl-archives
build-sdl-archives: clone-sdl
	# macosx
	xcodebuild archive \
		ONLY_ACTIVE_ARCH=NO \
		-scheme "Framework" \
		-project "${SDL_XCPROJ}" \
		-archivePath "${SDL_BUILD_DIR}/SDL2-macosx.xcarchive" \
		-destination 'generic/platform=macOS,name=Any Mac' \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		SKIP_INSTALL=NO \
		-quiet || exit $?

	# iOS simulator
	xcodebuild archive \
		ONLY_ACTIVE_ARCH=NO \
		-scheme "Framework-iOS" \
		-project "${SDL_XCPROJ}" \
		-archivePath "${SDL_BUILD_DIR}/SDL2-iphonesimulator.xcarchive" \
		-destination 'generic/platform=iOS Simulator' \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		SKIP_INSTALL=NO \
		-quiet || exit $?

	# iOS device
	xcodebuild archive \
		ONLY_ACTIVE_ARCH=NO \
		-scheme "Framework-iOS" \
		-project "${SDL_XCPROJ}" \
		-archivePath "${SDL_BUILD_DIR}/SDL2-iphoneos.xcarchive" \
		-destination 'generic/platform=iOS' \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		SKIP_INSTALL=NO \
		-quiet || exit $?
	
	# tvOS simulator
	xcodebuild archive \
		ONLY_ACTIVE_ARCH=NO \
		-scheme "Framework-tvOS" \
		-project "${SDL_XCPROJ}" \
		-archivePath "${SDL_BUILD_DIR}/SDL2-tvossimulator.xcarchive" \
		-destination 'generic/platform=tvOS Simulator' \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		SKIP_INSTALL=NO \
		-quiet || exit $?
	
	# tvOS device
	xcodebuild archive \
		ONLY_ACTIVE_ARCH=NO \
		-scheme "Framework-tvOS" \
		-project "${SDL_XCPROJ}" \
		-archivePath "${SDL_BUILD_DIR}/SDL2-tvos.xcarchive" \
		-destination 'generic/platform=tvOS' \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
		SKIP_INSTALL=NO \
		-quiet || exit $?

.PHONY: build-sdl-xcframework
build-sdl-xcframework: build-sdl-archives
	-rm -rdf "${SDL_BUILD_DIR}/SDL2.xcframework"

	xcodebuild -create-xcframework \
		-framework "${SDL_BUILD_DIR}/SDL2-macosx.xcarchive/Products/Library/Frameworks/SDL2.framework" \
		-framework "${SDL_BUILD_DIR}/SDL2-iphoneos.xcarchive/Products/Library/Frameworks/SDL2.framework" \
		-framework "${SDL_BUILD_DIR}/SDL2-iphonesimulator.xcarchive/Products/Library/Frameworks/SDL2.framework" \
		-framework "${SDL_BUILD_DIR}/SDL2-tvossimulator.xcarchive/Products/Library/Frameworks/SDL2.framework" \
		-framework "${SDL_BUILD_DIR}/SDL2-tvos.xcarchive/Products/Library/Frameworks/SDL2.framework" \
		-output ${SDL_BUILD_DIR}/SDL2.xcframework

		zip -rq ${SDL_BUILD_DIR}/SDL2.xcframework.zip ${SDL_BUILD_DIR}/SDL2.xcframework

.PHONY: update-sdl
update-sdl: build-sdl-xcframework
	-rm -rdf ${SDL_PKG_SRC_DIR}/SDL2.xcframework.zip
	cp -r ${SDL_BUILD_DIR}/SDL2.xcframework.zip ${SDL_PKG_SRC_DIR}/SDL2.xcframework.zip