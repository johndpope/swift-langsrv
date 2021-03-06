.PHONY: release debug clean generate-version generation-sourcekit-map publish tag

ToolchainLibPath=/Library/Developer/Toolchains/swift-3.1.1-RELEASE.xctoolchain/usr/lib
XcodeDefaultPath=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib
PlatformSdkPath=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/
Flags=-Xswiftc -framework -Xswiftc sourcekitd -Xswiftc -F -Xswiftc $(ToolchainLibPath) -Xlinker -rpath -Xlinker $(ToolchainLibPath) -Xlinker -rpath -Xlinker $(XcodeDefaultPath) -Xlinker -rpath -Xlinker $(PlatformSdkPath)

Version=v$(shell sed 's/^version: \(.*\)/\1/' ./VersionInfo)

debug: generate-version generate-sourcekit-map
	swift build -c debug $(Flags)
	swift test -c debug $(Flags)
	./Scripts/fixrpath.sh debug

release: generate-version generate-sourcekit-map
ifeq ($(shell uname -s),Darwin)
	swift build -c release -Xswiftc -static-stdlib $(Flags)
	swift test -c release $(Flags)
	./Scripts/fixrpath.sh release
else
	swift build -c release $(Flags)
	./Scripts/fixrpath.sh release
endif

clean:
	swift package clean

generate-version:
	./Scripts/genvers.sh

generate-sourcekit-map:
	./Scripts/genskmap.sh

publish: release tag
	mkdir -p .build/releases
	cp .build/release/langsrv .build/releases
	cp .build/release/libsourcekitd.dylib .build/releases
	rm -f .build/releases/langsrv-macos-$(Version).zip
	zip -ojm .build/releases/langsrv-macos-$(Version).zip .build/releases/*
	echo "Please upload .build/releases/langsrv-macos-$(Version).zip to GitHub manually."

tag:
	git tag $(Version)
