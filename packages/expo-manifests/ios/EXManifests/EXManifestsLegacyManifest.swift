//  Copyright © 2021 650 Industries. All rights reserved.
import Foundation

@objcMembers
public class EXManifestsLegacyManifest: EXManifestBaseLegacyManifest {
  public func releaseID() -> String {
    return try! self.rawManifestJSON().requiredValue(forKey: "releaseId")
  }

  public func commitTime() -> String {
    return try! self.rawManifestJSON().requiredValue(forKey: "commitTime")
  }

  public func bundledAssets() -> [Any]? {
    return try! self.rawManifestJSON().optionalValue(forKey: "bundledAssets")
  }

  public func runtimeVersion() -> Any? {
    return self.rawManifestJSON()["runtimeVersion"]
  }

  public func bundleKey() -> String? {
    return try! self.rawManifestJSON().optionalValue(forKey: "bundleKey")
  }

  public func assetUrlOverride() -> String? {
    return try! self.rawManifestJSON().optionalValue(forKey: "assetUrlOverride")
  }
}
