// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "TPKeyboardAvoiding",
    products: [
        .library(name: "TPKeyboardAvoiding", targets: ["TPKeyboardAvoiding"])
    ],
    targets: [
        .target(
            name: "TPKeyboardAvoiding",
            path: "TPKeyboardAvoiding"
        )
    ]
)
