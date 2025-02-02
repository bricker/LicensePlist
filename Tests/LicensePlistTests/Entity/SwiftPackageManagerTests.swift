//
//  SwiftPackageManagerTests.swift
//  APIKit
//
//  Created by Matthias Buchetics on 20.09.19.
//

import Foundation
import XCTest
@testable import LicensePlistCore

class SwiftPackageManagerTests: XCTestCase {
    func testDecodingV1() throws {
        let jsonString = """
            {
              "package": "APIKit",
              "repositoryURL": "https://github.com/ishkawa/APIKit.git",
              "state": {
                "branch": null,
                "revision": "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
                "version": "4.1.0"
              }
            }
        """

        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let package = try JSONDecoder().decode(SwiftPackageV1.self, from: data)

        XCTAssertEqual(package.package, "APIKit")
        XCTAssertEqual(package.repositoryURL, "https://github.com/ishkawa/APIKit.git")
        XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
        XCTAssertEqual(package.state.version, "4.1.0")
    }

    func testDecodingOfURLWithDotsV1() throws {
        let jsonString = """
            {
              "package": "R.swift.Library",
              "repositoryURL": "https://github.com/mac-cain13/R.swift.Library",
              "state": {
                "branch": "master",
                "revision": "3365947d725398694d6ed49f2e6622f05ca3fc0f",
                "version": null
              }
            }
        """

        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let package = try JSONDecoder().decode(SwiftPackageV1.self, from: data)

        XCTAssertEqual(package.package, "R.swift.Library")
        XCTAssertEqual(package.repositoryURL, "https://github.com/mac-cain13/R.swift.Library")
        XCTAssertEqual(package.state.revision, "3365947d725398694d6ed49f2e6622f05ca3fc0f")
        XCTAssertNil(package.state.version)
    }

    func testDecodingOptionalVersionV1() throws {
        let jsonString = """
            {
              "package": "APIKit",
              "repositoryURL": "https://github.com/ishkawa/APIKit.git",
              "state": {
                "branch": "master",
                "revision": "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
                "version": null
              }
            }
        """

        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let package = try JSONDecoder().decode(SwiftPackageV1.self, from: data)

        XCTAssertEqual(package.package, "APIKit")
        XCTAssertEqual(package.repositoryURL, "https://github.com/ishkawa/APIKit.git")
        XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
        XCTAssertEqual(package.state.branch, "master")
        XCTAssertNil(package.state.version)
    }

    func testDecodingWithVersionV2() throws {
        let jsonString = """
            {
              "identity" : "APIKit",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/ishkawa/APIKit.git",
              "state" : {
                "revision" : "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
                "version" : "4.1.0"
              }
            }
        """

        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let package = try JSONDecoder().decode(SwiftPackageV2.self, from: data)

        XCTAssertEqual(package.identity, "APIKit")
        XCTAssertEqual(package.location, "https://github.com/ishkawa/APIKit.git")
        XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
        XCTAssertNil(package.state.branch)
        XCTAssertEqual(package.state.version, "4.1.0")
    }

    func testDecodingWithBranchV2() throws {
        let jsonString = """
            {
              "identity" : "APIKit",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/ishkawa/APIKit.git",
              "state" : {
                "branch" : "master",
                "revision" : "86d51ecee0bc0ebdb53fb69b11a24169a69097ba"
              }
            }
        """

        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let package = try JSONDecoder().decode(SwiftPackageV2.self, from: data)

        XCTAssertEqual(package.identity, "APIKit")
        XCTAssertEqual(package.location, "https://github.com/ishkawa/APIKit.git")
        XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
        XCTAssertEqual(package.state.branch, "master")
        XCTAssertNil(package.state.version)
    }

    func testConvertToGithub() {
        let package = SwiftPackage(package: "Commander",
                                   repositoryURL: "https://github.com/kylef/Commander.git",
                                   revision: "e5b50ad7b2e91eeb828393e89b03577b16be7db9",
                                   version: "0.8.0")
        let result = package.toGitHub(renames: [:])
        XCTAssertEqual(result, GitHub(name: "Commander", nameSpecified: "Commander", owner: "kylef", version: "0.8.0"))
    }

    func testConvertToGithubNameWithDots() {
        let package = SwiftPackage(package: "R.swift.Library",
                                   repositoryURL: "https://github.com/mac-cain13/R.swift.Library",
                                   revision: "3365947d725398694d6ed49f2e6622f05ca3fc0f",
                                   version: nil)
        let result = package.toGitHub(renames: [:])
        XCTAssertEqual(result, GitHub(name: "R.swift.Library", nameSpecified: "R.swift.Library", owner: "mac-cain13", version: nil))
    }

    func testConvertToGithubSSH() {
        let package = SwiftPackage(package: "LicensePlist",
                                   repositoryURL: "git@github.com:mono0926/LicensePlist.git",
                                   revision: "3365947d725398694d6ed49f2e6622f05ca3fc0e",
                                   version: nil)
        let result = package.toGitHub(renames: [:])
        XCTAssertEqual(result, GitHub(name: "LicensePlist", nameSpecified: "LicensePlist", owner: "mono0926", version: nil))
    }

    func testConvertToGithubPackageName() {
        let package = SwiftPackage(package: "IterableSDK",
                                   repositoryURL: "https://github.com/Iterable/swift-sdk",
                                   revision: "3365947d725398694d6ed49f2e6622f05ca3fc0e",
                                   version: nil)
        let result = package.toGitHub(renames: [:])
        XCTAssertEqual(result, GitHub(name: "swift-sdk", nameSpecified: "IterableSDK", owner: "Iterable", version: nil))
    }

    func testConvertToGithubRenames() {
        let package = SwiftPackage(package: "IterableSDK",
                                   repositoryURL: "https://github.com/Iterable/swift-sdk",
                                   revision: "3365947d725398694d6ed49f2e6622f05ca3fc0e",
                                   version: nil)
        let result = package.toGitHub(renames: ["swift-sdk": "NAME"])
        XCTAssertEqual(result, GitHub(name: "swift-sdk", nameSpecified: "NAME", owner: "Iterable", version: nil))
    }

    func testRename() {
        let package = SwiftPackage(package: "Commander",
                                   repositoryURL: "https://github.com/kylef/Commander.git",
                                   revision: "e5b50ad7b2e91eeb828393e89b03577b16be7db9",
                                   version: "0.8.0")
        let result = package.toGitHub(renames: ["Commander": "RenamedCommander"])
        XCTAssertEqual(result, GitHub(name: "Commander", nameSpecified: "RenamedCommander", owner: "kylef", version: "0.8.0"))
    }

    func testInvalidURL() {
        let package = SwiftPackage(package: "Google", repositoryURL: "http://www.google.com", revision: "", version: "0.0.0")
        let result = package.toGitHub(renames: [:])
        XCTAssertNil(result)
    }

    func testNonGithub() {
        let package = SwiftPackage(package: "Bitbucket",
                                   repositoryURL: "https://mbuchetics@bitbucket.org/mbuchetics/adventofcode2018.git",
                                   revision: "",
                                   version: "0.0.0")
        let result = package.toGitHub(renames: [:])
        XCTAssertNil(result)
    }

    func testParse() throws {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Package.resolved"
        let content = try String(contentsOf: XCTUnwrap(URL(string: path)))
        let packages = SwiftPackage.loadPackages(content)

        XCTAssertFalse(packages.isEmpty)
        XCTAssertEqual(packages.count, 7)

        let packageFirst = try XCTUnwrap(packages.first)
        XCTAssertEqual(packageFirst, SwiftPackage(package: "APIKit",
                                                  repositoryURL: "https://github.com/ishkawa/APIKit.git",
                                                  revision: "4e7f42d93afb787b0bc502171f9b5c12cf49d0ca",
                                                  version: "5.3.0"))
        let packageLast = try XCTUnwrap(packages.last)
        XCTAssertEqual(packageLast, SwiftPackage(package: "Yaml",
                                                 repositoryURL: "https://github.com/behrang/YamlSwift.git",
                                                 revision: "287f5cab7da0d92eb947b5fd8151b203ae04a9a3",
                                                 version: "3.4.4"))

    }
}
