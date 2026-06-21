import Foundation

/// Resolves the on-device GGUF model path. **Configurable, not hardcoded** — an
/// override path can be supplied (e.g. a model placed in Documents, or a debug
/// env var) and otherwise we fall back to the bundled model. The specific GGUF is
/// used as-is; this type only locates it.
enum ModelLocator {
    static let bundledModelName = "Llama-3.2-1B-Instruct-Q4_K_M"
    private static let overrideDefaultsKey = "GBModelPath"

    /// Persisted override (settable from a future Settings screen).
    static var overridePath: String? {
        get { UserDefaults.standard.string(forKey: overrideDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: overrideDefaultsKey) }
    }

    /// Returns the first model that exists, searching:
    /// 1. an explicit override (debug env or UserDefaults),
    /// 2. a `<name>.gguf` dropped into the app's Documents directory,
    /// 3. the bundled model resource.
    static func resolve() -> URL? {
        let fm = FileManager.default

        #if DEBUG
        if let envPath = ProcessInfo.processInfo.environment["GB_MODEL_PATH"],
           fm.fileExists(atPath: envPath) {
            return URL(fileURLWithPath: envPath)
        }
        #endif

        if let override = overridePath, fm.fileExists(atPath: override) {
            return URL(fileURLWithPath: override)
        }

        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let candidate = docs.appendingPathComponent("\(bundledModelName).gguf")
            if fm.fileExists(atPath: candidate.path) { return candidate }
        }

        return Bundle.main.url(forResource: bundledModelName, withExtension: "gguf")
    }
}
