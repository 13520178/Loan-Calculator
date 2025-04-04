
import Foundation
import StoreKit

enum AppStoreReviewManager {
  
  static let minimumReviewWorthyActionCount = 6
  
  
  static func requestReviewIfAppropriate() {
    
    let defaults = UserDefaults.standard
    let bundle = Bundle.main
    
    var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
    
    actionCount += 1
    
    defaults.set(actionCount, forKey: .reviewWorthyActionCount)
    
    guard actionCount >= minimumReviewWorthyActionCount else {
      return
    }
    
    // 6.
    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)
    
    // 7.
     guard lastVersion == nil || lastVersion != currentVersion else {
       return
     }
    
    SKStoreReviewController.requestReview()
    
    // 9.
    defaults.set(0, forKey: .reviewWorthyActionCount)
    defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
    
  }
}
