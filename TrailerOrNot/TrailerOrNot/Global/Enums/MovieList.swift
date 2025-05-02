import Foundation

enum MovieList: String, CaseIterable {
    case popular = "popular"
    case upcoming = "upcoming"
    case topRated = "top_rated"
    case nowPlaying = "now_playing"
    
    // CR: чи має текст/локалізація бути присютня у моделі?
}
