import Foundation

extension Task where Success == Never, Failure == Never {
    static func delay() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}
