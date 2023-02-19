//  Copyright (c) 2020 650 Industries, Inc. All rights reserved.

import XCTest

@testable import EXManifests

class EXManifestsLegacyManifestTests: XCTestCase {
  func testInstantiateManifestAndReadProperties() throws {
    let manifestJson = "{\"sdkVersion\":\"39.0.0\",\"id\":\"@esamelson/native-component-list\",\"releaseId\":\"0eef8214-4833-4089-9dff-b4138a14f196\",\"commitTime\":\"2020-11-11T00:17:54.797Z\",\"bundleUrl\":\"https://classic-assets.eascdn.net/%40esamelson%2Fnative-component-list%2F39.0.0%2F01c86fd863cfee878068eebd40f165df-39.0.0-ios.js\"}"
    let manifestData = manifestJson.data(using: .utf8)
    guard let manifestData = manifestData else {
      throw ManifestTestError.testError
    }
    let manifestJsonObject = try JSONSerialization.jsonObject(with: manifestData)
    guard let manifestJsonObject = manifestJsonObject as? [String: Any] else {
      throw ManifestTestError.testError
    }

    let manifest = EXManifestsLegacyManifest(rawManifestJSON: manifestJsonObject)

    XCTAssertEqual(manifest.releaseID(), "0eef8214-4833-4089-9dff-b4138a14f196")
    XCTAssertEqual(manifest.commitTime(), "2020-11-11T00:17:54.797Z")
    XCTAssertNil(manifest.bundledAssets())
    XCTAssertNil(manifest.runtimeVersion())
    XCTAssertNil(manifest.bundleKey())
    XCTAssertNil(manifest.assetUrlOverride())

    // from base class
    XCTAssertEqual(manifest.stableLegacyId(), "@esamelson/native-component-list")
    XCTAssertEqual(manifest.scopeKey(), "@esamelson/native-component-list")
    XCTAssertNil(manifest.easProjectId())
    XCTAssertEqual(manifest.bundleUrl(), "https://classic-assets.eascdn.net/%40esamelson%2Fnative-component-list%2F39.0.0%2F01c86fd863cfee878068eebd40f165df-39.0.0-ios.js")
    XCTAssertEqual(manifest.sdkVersion(), "39.0.0")

    // from base base class
    XCTAssertEqual(manifest.legacyId(), "@esamelson/native-component-list")
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
    XCTAssertEqual(manifest.jsEngine(), "jsc")
  }
}
