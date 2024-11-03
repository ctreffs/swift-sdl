// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SDL",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "SDL", targets: ["SDL"]),
    ],
    targets: [
        .target(name: "SDL", dependencies: ["cSDL"]),
        .target(name: "cSDL", dependencies: ["SDL2"], cSettings: [
            .headerSearchPath("Sources/cSDL/SDL2.xcframework/macos-arm64_x86_64/SDL2.framework/Versions/Current/Headers", .when(platforms: [.macOS])),
            .headerSearchPath("Sources/cSDL/SDL2.xcframework/ios-arm64/SDL2.framework/Headers", .when(platforms: [.iOS])),
            .headerSearchPath("Sources/cSDL/SDL2.xcframework/tvos-arm64/SDL2.framework/Headers", .when(platforms: [.tvOS]))
        ]),
        .binaryTarget(name: "SDL2", path: "Sources/cSDL/SDL2.xcframework.zip"),
        .executableTarget(
            name: "SDLTester",
            dependencies: ["SDL"],
            resources: [
                // .copy("Resources/Info.plist")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/SDLTester/Resources/Info.plist"
                ])
            ]
        )
    ],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx20
)
