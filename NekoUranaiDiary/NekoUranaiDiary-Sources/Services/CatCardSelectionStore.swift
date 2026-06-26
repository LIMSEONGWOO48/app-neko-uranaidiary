import Foundation

enum CatCardSelectionStore {
    static func save(userId: String, index: Int) {
        UserDefaults.standard.set(index, forKey: storageKey(userId: userId))
    }

    static func load(userId: String) -> Int? {
        let key = storageKey(userId: userId)
        guard UserDefaults.standard.object(forKey: key) != nil else { return nil }
        return UserDefaults.standard.integer(forKey: key)
    }

    private static func storageKey(userId: String) -> String {
        "catCardSelection.\(userId).\(UsageLimit.currentDayKey())"
    }
}
