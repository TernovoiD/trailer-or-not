import Foundation
final class MovieViewModel {
    let details: MovieDetails.WithTrailer
    
    init(details: MovieDetails.WithTrailer) {
        self.details = details
    }
    // CR: чи має ця логіка бути на рівні view? наприклад уявимо що нам цей контроллер треба переробити на SwiftUI
    private var movie: MovieDetails { details.movieDetails }
    
    var trailerURLPath: String? { details.trailerPath }
    
    var hasTrailer: Bool {
        trailerURLPath != "" && trailerURLPath != nil
    }
    
    var title: String {
        details.movieDetails.title ?? ""
    }
    
    var countryAndYear: String {
        "\(movie.originCountry?.first ?? "Unknown Country"), \(movie.releaseDate?.prefix(4) ?? "Unknown Year")"
    }
    
    var rating: String {
        "Rating: \(String(format: "%.1f", movie.rating ?? 0))"
    }
    
    var overview: String { movie.overview ?? "" }
    
    var genres: String {
        if let genres = movie.genres?.compactMap({ $0.name }) {
            return genres.joined(separator: ", ")
        } else {
            return "No genres available"
        }
    }
    
    var imageURL: URL? {
        if let path = TMDBImageURL.buildImageURL(for: movie.posterPath, withSize: .large) {
            return URL(string: path)
        } else { return nil }
    }
}
