// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "web-graphql",
  products: [
    .library(name: "web", targets: ["web-graphql"])
  ],
  dependencies: [
    .package(url: "https://github.com/GraphQLSwift/Graphiti.git", from: Version("0.4.0")),
    .package(url: "https://github.com/mutle/swift-web.git", from: Version("0.0.1"))
  ],
  targets: [
    .target(name: "web-graphql", dependencies: [
      .productItem(name: "Graphiti", package: nil),
      .productItem(name: "web", package: nil)
    ]),

    .testTarget(name: "web-graphqlTests", dependencies: ["web-graphql"])
  ]
)
