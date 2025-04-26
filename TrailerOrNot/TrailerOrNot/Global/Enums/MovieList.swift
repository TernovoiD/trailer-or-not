import Foundation

enum MovieList: String, CaseIterable {
    case popular = "popular"
    case upcoming = "upcoming"
    case topRated = "top_rated"
    case nowPlaying = "now_playing"
}

extension MovieList {
    var title: String {
        LocalizedText.movieListOption(for: self)
    }
}
