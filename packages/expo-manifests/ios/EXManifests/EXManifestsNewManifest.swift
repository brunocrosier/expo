//  Copyright © 2021 650 Industries. All rights reserved.

import Foundation

@objcMembers
public class EXManifestsNewManifest: EXManifestsManifest {
  public func rawId() -> String {
    return try! self.rawManifestJSON().requiredValue(forKey: "id")
  }

  public override func stableLegacyId() -> String {
    return self.rawId()
  }

  public override func scopeKey() -> String {
    let extra: [String: Any] = try! self.rawManifestJSON().requiredValue(forKey: "extra")
    return try! extra.requiredValue(forKey: "scopeKey")
  }

  private func extra() -> [String: Any]? {
    return try! self.rawManifestJSON().optionalValue(forKey: "extra")
  }

  public override func easProjectId() -> String? {
    guard let easConfig: [String: Any] = try! self.extra()?.optionalValue(forKey: "eas") else {
      return nil
    }
    return try! easConfig.optionalValue(forKey: "projectId")
  }

  public func createdAt() -> String {
    return try! self.rawManifestJSON().requiredValue(forKey: "createdAt")
  }

  public func runtimeVersion() -> String {
    return try! self.rawManifestJSON().requiredValue(forKey: "runtimeVersion")
  }

  public override func sdkVersion() -> String? {
    let runtimeVersion = self.runtimeVersion()
    if runtimeVersion == "exposdk:UNVERSIONED" {
      return "UNVERSIONED"
    }

    // The pattern is valid, so it'll never throw
    // swiftlint:disable:next force_try
    let regex = try! NSRegularExpression(pattern: "^exposdk:(\\d+\\.\\d+\\.\\d+)$", options: [])
    guard let match = regex.firstMatch(
      in: runtimeVersion,
      options: [],
      range: NSRange(runtimeVersion.startIndex..<runtimeVersion.endIndex, in: runtimeVersion)
    ),
    let range = Range(match.range(at: 1), in: runtimeVersion) else {
      return nil
    }
    return String(runtimeVersion[range])
  }

  public func launchAsset() -> [String: Any] {
    return try! self.rawManifestJSON().requiredValue(forKey: "launchAsset")
  }

  public func assets() -> [[String: Any]]? {
    return try! self.rawManifestJSON().optionalValue(forKey: "assets")
  }

  public override func bundleUrl() -> String {
    return try! self.launchAsset().requiredValue(forKey: "url")
  }

  override func expoClientConfigRootObject() -> [String: Any]? {
    return try! self.extra()?.optionalValue(forKey: "expoClient")
  }

  override func expoGoConfigRootObject() -> [String: Any]? {
    return try! self.extra()?.optionalValue(forKey: "expoGo")
  }
}
