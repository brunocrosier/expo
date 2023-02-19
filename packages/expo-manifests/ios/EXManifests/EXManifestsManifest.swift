//  Copyright © 2021 650 Industries. All rights reserved.

// this uses abstract class patterns
// swiftlint:disable unavailable_function

import Foundation
import UIKit

/**
 These errors are not thrown in objective-c since they are preempted by NSExceptions. This is maintain
 backwards compatibility with the previous objective-c implementation so that we don't need to do
 error handling at every callsite. When all the code is swift, we might be able to use these exceptions.
 */
@objc public enum EXUpdatesManifestError : Int, Error {
  case IncorrectFieldType
  case MissingRequiredField
}

extension Dictionary where Key == String {
  func optionalValue<T>(forKey: String) throws -> T? {
    guard let value = self[forKey] else {
      return nil
    }
    
    guard let value = value as? T else {
      let exception = NSException(name: NSExceptionName.internalInconsistencyException,
                                  reason: "Value for (key = %@) has incorrect type",
                                  userInfo: ["key": forKey])
      exception.raise()
      throw EXUpdatesManifestError.IncorrectFieldType
    }
    return value
  }

  func requiredValue<T>(forKey: String) throws -> T {
    let value = self[forKey]
    
    guard let value = value else {
      let exception = NSException(name: NSExceptionName.internalInconsistencyException,
                                  reason: "Value for (key = %@) is null",
                                  userInfo: ["key": forKey])
      exception.raise()
      throw EXUpdatesManifestError.MissingRequiredField
    }
    
    guard let value = value as? T else {
      let exception = NSException(name: NSExceptionName.internalInconsistencyException,
                                  reason: "Value for (key = %@) has incorrect type",
                                  userInfo: ["key": forKey])
      exception.raise()
      throw EXUpdatesManifestError.IncorrectFieldType
    }
    
    return value
  }
}

extension Optional {
  func `let`<U>(_ transform: (_ it: Wrapped) throws -> U?) rethrows -> U? {
    if let x = self {
      return try transform(x)
    }
    return nil
  }
}

@objcMembers
// swiftlint:disable:next type_body_length
public class EXManifestsManifest: NSObject {
  private var rawManifestJSONInternal: [String: Any]

  public required init(rawManifestJSON: [String: Any]) {
    self.rawManifestJSONInternal = rawManifestJSON
  }

  public override var debugDescription: String {
    return self.rawManifestJSONInternal.description
  }

  public func rawManifestJSON() -> [String: Any] {
    return self.rawManifestJSONInternal
  }

  // MARK: - Abstract methods

  /**
   A best-effort immutable legacy ID for this experience. Stable through project transfers.
   Should be used for calling Expo and EAS APIs during their transition to easProjectId.
   */
  @available(*, deprecated, message: "Prefer scopeKey or easProjectId depending on use case")
  public func stableLegacyId() -> String {
    preconditionFailure("Must override in concrete class")
  }

  /**
   A stable immutable scoping key for this experience. Should be used for scoping data on the
   client for this project when running in Expo Go.
   */
  public func scopeKey() -> String {
    preconditionFailure("Must override in concrete class")
  }

  /**
   A stable UUID for this EAS project. Should be used to call EAS APIs.
   */
  public func easProjectId() -> String? {
    preconditionFailure("Must override in concrete class")
  }

  public func sdkVersion() -> String? {
    preconditionFailure("Must override in concrete class")
  }

  public func bundleUrl() -> String {
    preconditionFailure("Must override in concrete class")
  }

  func expoGoConfigRootObject() -> [String: Any]? {
    preconditionFailure("Must override in concrete class")
  }

  func expoClientConfigRootObject() -> [String: Any]? {
    preconditionFailure("Must override in concrete class")
  }

  // MARK: - Field Getters
  /**
   The legacy ID of this experience.
   - For Bare manifests, formatted as a UUID.
   - For Legacy manifests, formatted as @owner/slug. Not stable through project transfers.
   - For New manifests, currently incorrect value is UUID.
   Use this in cases where an identifier of the current manifest is needed (experience loading for example).
   Use scopeKey for cases where a stable key is needed to scope data to this experience.
   Use easProjectId for cases where a stable UUID identifier of the experience is needed to identify over EAS APIs.
   Use stableLegacyId for cases where a stable legacy format identifier of the experience is needed
    (experience scoping for example).
   */
  public func legacyId() -> String {
    return try! self.rawManifestJSONInternal.requiredValue(forKey: "id")
  }

  public func revisionId() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "revisionId")
  }

  public func slug() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "slug")
  }

  public func appKey() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "appKey")
  }

  public func name() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "name")
  }

  public func version() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "version")
  }

  public func notificationPreferences() -> [String: Any]? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "notification")
  }

  public func updatesInfo() -> [String: Any]? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "updates")
  }

  public func iosConfig() -> [String: Any]? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "ios")
  }

  public func hostUri() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "hostUri")
  }

  public func orientation() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "orientation")
  }

  public func experiments() -> [String: Any]? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "experiments")
  }

  public func developer() -> [String: Any]? {
    return try! self.expoGoConfigRootObject()?.optionalValue(forKey: "developer")
  }

  public func logUrl() -> String? {
    return try! self.expoGoConfigRootObject()?.optionalValue(forKey: "logUrl")
  }

  public func facebookAppId() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "facebookAppId")
  }

  public func facebookApplicationName() -> String? {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "facebookDisplayName")
  }

  public func facebookAutoInitEnabled() -> Bool {
    return try! self.expoClientConfigRootObject()?.optionalValue(forKey: "facebookAutoInitEnabled") ?? false
  }

  // MARK: - Derived Methods
  public func isDevelopmentMode() -> Bool {
    guard let expoGoConfigRootObject = self.expoGoConfigRootObject(),
      let packagerOptsConfig: [String: Any]? = try! expoGoConfigRootObject.optionalValue(forKey: "packagerOpts"),
      let dev = packagerOptsConfig?["dev"] else {
      return false
    }

    if self.developer() == nil {
      return false
    }

    guard let dev = dev as? Bool else {
      return false
    }
    return dev
  }

  public func isDevelopmentSilentLaunch() -> Bool {
    guard let expoGoConfigRootObject = self.expoGoConfigRootObject(),
      let developmentClientSettings: [String: Any]? =
            try! expoGoConfigRootObject.optionalValue(forKey: "developmentClient"),
      let silentLaunch = developmentClientSettings?["silentLaunch"] else {
      return false
    }

    guard let silentLaunch = silentLaunch as? Bool else {
      return false
    }
    return silentLaunch
  }

  public func isUsingDeveloperTool() -> Bool {
    return self.developer()?["tool"] != nil
  }

  public func userInterfaceStyle() -> String? {
    return try! self.iosConfig()?.optionalValue(forKey: "userInterfaceStyle") ??
    (try! self.expoClientConfigRootObject()?.optionalValue(forKey: "userInterfaceStyle"))
  }

  public func iosOrRootBackgroundColor() -> String? {
    return try! self.iosConfig()?.optionalValue(forKey: "backgroundColor") ??
    (try! self.expoClientConfigRootObject()?.optionalValue(forKey: "backgroundColor"))
  }

  public func iosSplashBackgroundColor() -> String? {
    return self.expoClientConfigRootObject().let { it in
      EXManifestsManifest.string(fromManifest: it, atPaths: [
        ["ios", "splash", "backgroundColor"],
        ["splash", "backgroundColor"]
      ])
    }
  }

  public func iosSplashImageUrl() -> String? {
    return self.expoClientConfigRootObject().let { it in
      EXManifestsManifest.string(fromManifest: it, atPaths: [
        UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
          ? ["ios", "splash", "tabletImageUrl"] : [],
        ["ios", "splash", "imageUrl"],
        ["splash", "imageUrl"]
      ])
    }
  }

  public func iosSplashImageResizeMode() -> String? {
    return self.expoClientConfigRootObject().let { it in
      EXManifestsManifest.string(fromManifest: it, atPaths: [
        ["ios", "splash", "resizeMode"],
        ["splash", "resizeMode"]
      ])
    }
  }

  public func iosGoogleServicesFile() -> String? {
    return try! self.iosConfig()?.optionalValue(forKey: "googleServicesFile")
  }

  public func supportsRTL() -> Bool {
    guard let expoClientConfigRootObject = self.expoClientConfigRootObject(),
      let extra: [String: Any]? = try! expoClientConfigRootObject.optionalValue(forKey: "extra"),
      let supportsRTL: Bool = try! extra?.optionalValue(forKey: "supportsRTL") else {
      return false
    }

    return supportsRTL
  }

  public func jsEngine() -> String {
    let jsEngine = self.expoClientConfigRootObject().let { it in
      EXManifestsManifest.string(fromManifest: it, atPaths: [
        ["ios", "jsEngine"],
        ["jsEngine"]
      ])
    }

    guard let jsEngine = jsEngine else {
      let sdkMajorVersion = self.sdkMajorVersion()
      if sdkMajorVersion > 0 && sdkMajorVersion < 48 {
        return "jsc"
      } else {
        return "hermes"
      }
    }
    return jsEngine
  }

  private func sdkMajorVersion() -> Int {
    let sdkVersion = self.sdkVersion()
    let components = sdkVersion?.components(separatedBy: ".")
    guard let components = components else {
      return 0
    }
    if components.count == 3 {
      let ret = Int(components[0])
      guard let ret = ret else {
        return 0
      }
      return ret
    }
    return 0
  }

  private static func string(fromManifest: [String: Any], atPaths: [[String]]) -> String? {
    for path in atPaths {
      if let result = self.string(fromManifest: fromManifest, atPath: path) {
        return result
      }
    }
    return nil
  }

  private static func string(fromManifest: [String: Any], atPath: [String]) -> String? {
    var json = fromManifest
    for i in 0..<atPath.count {
      let isLastKey = i == atPath.count - 1
      let key = atPath[i]
      let value = json[key]
      if isLastKey && value is String {
        // Type check above preempts this force_cast
        // swiftlint:disable:next force_cast
        return value as! String?
      }
      guard let newJson = value else {
        return nil
      }
      // swiftlint:disable:next force_cast
      json = newJson as! [String: Any]
    }
    return nil
  }
}
