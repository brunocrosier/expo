//  Copyright (c) 2020 650 Industries, Inc. All rights reserved.

import XCTest

@testable import EXManifests

enum ManifestTestError: Error {
    case testError
}

class EXManifestsBareManifestTests: XCTestCase {
  func testInstantiateManifestAndReadProperties() throws {
    let manifestJson = "{\"id\":\"0eef8214-4833-4089-9dff-b4138a14f196\",\"commitTime\":1609975977832}"
    let manifestData = manifestJson.data(using: .utf8)
    guard let manifestData = manifestData else {
      throw ManifestTestError.testError
    }
    let manifestJsonObject = try JSONSerialization.jsonObject(with: manifestData)
    guard let manifestJsonObject = manifestJsonObject as? [String: Any] else {
      throw ManifestTestError.testError
    }
    
    let manifest = EXManifestsBareManifest(rawManifestJSON: manifestJsonObject)
    
    XCTAssertEqual(manifest.rawId(), "0eef8214-4833-4089-9dff-b4138a14f196")
    XCTAssertEqual(manifest.commitTimeNumber(), 1609975977832)
    XCTAssertNil(manifest.metadata())
    
    // from base class
    XCTAssertEqual(manifest.stableLegacyId(), "0eef8214-4833-4089-9dff-b4138a14f196")
    XCTAssertEqual(manifest.scopeKey(), "0eef8214-4833-4089-9dff-b4138a14f196")
    XCTAssertNil(manifest.easProjectId())
    XCTAssertNil(manifest.sdkVersion())

    // from base base class
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
}
