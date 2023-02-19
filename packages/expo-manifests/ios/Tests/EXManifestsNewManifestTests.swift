//  Copyright (c) 2020 650 Industries, Inc. All rights reserved.

import XCTest

@testable import EXManifests

class EXManifestsNewManifestTests: XCTestCase {
  func testInstantiateManifestAndReadProperties() throws {
    let manifestJson = "{\"runtimeVersion\":\"1\",\"id\":\"0eef8214-4833-4089-9dff-b4138a14f196\",\"createdAt\":\"2020-11-11T00:17:54.797Z\",\"launchAsset\":{\"url\":\"https://classic-assets.eascdn.net/%40esamelson%2Fnative-component-list%2F39.0.0%2F01c86fd863cfee878068eebd40f165df-39.0.0-ios.js\",\"contentType\":\"application/javascript\"}}"
    let manifestData = manifestJson.data(using: .utf8)
    guard let manifestData = manifestData else {
      throw ManifestTestError.testError
    }
    let manifestJsonObject = try JSONSerialization.jsonObject(with: manifestData)
    guard let manifestJsonObject = manifestJsonObject as? [String: Any] else {
      throw ManifestTestError.testError
    }
    
    let manifest = EXManifestsNewManifest(rawManifestJSON: manifestJsonObject)
    
    XCTAssertEqual(manifest.rawId(), "0eef8214-4833-4089-9dff-b4138a14f196")
    XCTAssertEqual(manifest.createdAt(), "2020-11-11T00:17:54.797Z")
    XCTAssertEqual(manifest.runtimeVersion(), "1")
    XCTAssertTrue(NSDictionary(dictionary: [
      "url": "https://classic-assets.eascdn.net/%40esamelson%2Fnative-component-list%2F39.0.0%2F01c86fd863cfee878068eebd40f165df-39.0.0-ios.js",
      "contentType": "application/javascript"
    ]).isEqual(to: manifest.launchAsset()))
    XCTAssertNil(manifest.assets())
    
    // from base class
    XCTAssertEqual(manifest.legacyId(), "0eef8214-4833-4089-9dff-b4138a14f196")
    XCTAssertNil(manifest.revisionId())
    XCTAssertNil(manifest.slug())
    XCTAssertNil(manifest.appKey())
    XCTAssertNil(manifest.name())
    XCTAssertNil(manifest.version())
    XCTAssertNil(manifest.notificationPreferences())
    XCTAssertNil(manifest.updatesInfo())
    XCTAssertNil(manifest.iosConfig())
    XCTAssertNil(manifest.hostUri())
    XCTAssertNil(manifest.orientation())
    XCTAssertNil(manifest.experiments())
    XCTAssertNil(manifest.developer())
    XCTAssertNil(manifest.logUrl())
    XCTAssertNil(manifest.facebookAppId())
    XCTAssertNil(manifest.facebookApplicationName())
    XCTAssertFalse(manifest.facebookAutoInitEnabled())
    XCTAssertFalse(manifest.isDevelopmentMode())
    XCTAssertFalse(manifest.isDevelopmentSilentLaunch())
    XCTAssertFalse(manifest.isUsingDeveloperTool())
    XCTAssertNil(manifest.userInterfaceStyle())
    XCTAssertNil(manifest.iosOrRootBackgroundColor())
    XCTAssertNil(manifest.iosSplashBackgroundColor())
    XCTAssertNil(manifest.iosSplashImageUrl())
    XCTAssertNil(manifest.iosSplashImageResizeMode())
    XCTAssertNil(manifest.iosGoogleServicesFile())
    XCTAssertFalse(manifest.supportsRTL())
    XCTAssertEqual(manifest.jsEngine(), "hermes")
  }
  
  func testSDKVersion_ValidCaseNumeric() {
    let runtimeVersion = "exposdk:39.0.0"
    let manifestJson = ["runtimeVersion": runtimeVersion]
    let manifest = EXManifestsNewManifest(rawManifestJSON: manifestJson)
    XCTAssertEqual(manifest.sdkVersion(), "39.0.0")
  }

  func testSDKVersion_ValidCaseUnversioned() {
    let runtimeVersion = "exposdk:UNVERSIONED"
    let manifestJson = ["runtimeVersion": runtimeVersion]
    let manifest = EXManifestsNewManifest(rawManifestJSON: manifestJson)
    XCTAssertEqual(manifest.sdkVersion(), "UNVERSIONED")
  }

  func testSDKVersion_NotSDKRuntimeVersionCases() {
    let runtimeVersions = [
      "exposdk:123",
      "exposdkd:39.0.0",
      "exposdk:hello",
      "bexposdk:39.0.0",
      "exposdk:39.0.0-beta.0",
      "exposdk:39.0.0-alpha.256"
    ]

    for runtimeVersion in runtimeVersions {
      let manifestJson = ["runtimeVersion": runtimeVersion]
      let manifest = EXManifestsNewManifest(rawManifestJSON: manifestJson)
      XCTAssertNil(manifest.sdkVersion())
    }
  }
}
