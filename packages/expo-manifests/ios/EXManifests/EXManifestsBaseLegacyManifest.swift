//  Copyright © 2021 650 Industries. All rights reserved.

import Foundation

@objcMembers
public class EXManifestBaseLegacyManifest: EXManifestsManifest {
  override func expoClientConfigRootObject() -> [String: Any]? {
    return self.rawManifestJSON()
  }

  override func expoGoConfigRootObject() -> [String: Any]? {
    return self.rawManifestJSON()
  }

  public override func stableLegacyId() -> String {
    return try! self.rawManifestJSON().optionalValue(forKey: "originalFullName") ?? self.legacyId()
  }

  public override func scopeKey() -> String {
    return try! self.rawManifestJSON().optionalValue(forKey: "scopeKey") ?? self.stableLegacyId()
  }

  public override func easProjectId() -> String? {
    return try! self.rawManifestJSON().optionalValue(forKey: "projectId")
  }

  public override func bundleUrl() -> String {
    return try! self.rawManifestJSON().requiredValue(forKey: "bundleUrl")
  }

  public override func sdkVersion() -> String? {
    return try! self.rawManifestJSON().optionalValue(forKey: "sdkVersion")
  }

  public func assets() -> [Any]? {
    return try! self.rawManifestJSON().optionalValue(forKey: "assets")
  }
}
