import AppKit

extension UserDefaults {
    private static let customIconKey = "CustomOpenFrontierIcon"

    var appIcon: AppIcon? {
        get {
            guard let data = data(forKey: Self.customIconKey) else {
                return nil
            }
            return try? JSONDecoder().decode(AppIcon.self, from: data)
        }

        set {
            guard let newData = try? JSONEncoder().encode(newValue) else {
                return
            }

            set(newData, forKey: Self.customIconKey)
        }
    }
}
