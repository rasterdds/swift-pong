// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "pong",
    targets: [
        .systemLibrary(name: "CRaylib"),
        .executableTarget(
            name: "pong",
            dependencies: ["CRaylib"],
            cSettings: [
                .headerSearchPath("../../libs")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                
            ],
            linkerSettings: [
                .unsafeFlags(["-Llibs"]),
                .linkedLibrary("raylib"),
                .linkedLibrary("opengl32"),
                .linkedLibrary("gdi32"),
                .linkedLibrary("winmm"),
                .linkedLibrary("user32"),
                .linkedLibrary("shell32"),
            ]
        ),
    ]
)
