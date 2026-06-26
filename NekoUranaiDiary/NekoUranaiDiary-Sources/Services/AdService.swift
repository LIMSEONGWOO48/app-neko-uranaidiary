import Foundation
import CoreGraphics

enum AdService {
    /// AdMob 本番連携時に true に切り替える
    static let isAdMobIntegrated = false

    /// 標準バナー（AdMob）用の広告枠高さ
    static let bannerHeight: CGFloat = 50

    static func shouldShowAds(for profile: UserProfile?) -> Bool {
        profile?.planTypeEnum != .premium
    }

    /// AdMob 導入時に App Store Connect / AdMob で発行した ID に差し替える
    static let bannerAdUnitID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx"
}
