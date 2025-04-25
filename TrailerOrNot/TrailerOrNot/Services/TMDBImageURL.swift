import Foundation

struct TMDBImageURL {
    private static let basePath = "https://image.tmdb.org/t/p/"

    static func buildImageURL(for posterPath: String?, withSize screen: ScreenSize) -> String? {
        guard let posterPath = posterPath else { return nil }
        return basePath + sizeParameter(for: screen) + posterPath
    }
    
    private static func sizeParameter(for screen: ScreenSize) -> String {
        switch screen {
        case .large:
            return ImageSize.original.rawValue
        case .big:
            return ImageSize.w780.rawValue
        case .medium:
            return ImageSize.w500.rawValue
        case .small:
            return ImageSize.w300.rawValue
        case .tiny:
            return ImageSize.w200.rawValue
        }
    }
    
    private enum ImageSize: String {
        case original = "original"
        case w780 = "w780"
        case w500 = "w500"
        case w300 = "w300"
        case w200 = "w200"
    }
}
