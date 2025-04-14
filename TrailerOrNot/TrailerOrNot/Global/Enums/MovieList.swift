import Foundation

enum MovieList: String, CaseIterable {
    case popular = "popular"
    case upcoming = "upcoming"
    case topRated = "top_rated"
    case nowPlaying = "now_playing"
    
    var title: String {
        switch self {
        case .popular:
            return NSLocalizedString("Popular", comment: "Title: Popular")
        case .upcoming:
            return NSLocalizedString("Upcoming", comment: "Title: Upcoming")
        case .topRated:
            return NSLocalizedString("Top rated", comment: "Title: Top rated")
        case .nowPlaying:
            return NSLocalizedString("Now playing", comment: "Title: Now playing")
        }
    }
}
