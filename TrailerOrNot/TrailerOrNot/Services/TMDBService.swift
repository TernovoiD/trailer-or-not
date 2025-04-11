import Foundation
import Alamofire

class TMDBService {
    private let baseURL = "https://api.themoviedb.org/3"
    private let languageParameter = ["language":"en-US"]
    private let headers: HTTPHeaders = [
        "accept": "application/json",
        "Authorization": "Bearer \(Secret.readAccessTokenTMDB)"
    ]
    
    enum MovieListType: String {
        case popular = "popular"
        case upcoming = "upcoming"
        case topRated = "top_rated"
        case nowPlaying = "now_playing"
    }
    
    private enum Endpoint {
        case movieList(MovieListType)
        case movieDetails(Int)
        case genreList
        case movieVideos(Int)
    }
    
    func loadMovies(type: MovieListType, page: Int) async throws -> [Movie] {
        let path = generatePath(for: .movieList(type))
        let parameters: [String: String] = [
            "language": "en-US",
            "page": "\(page)"
        ]
        
        let response: MovieResponse = try await AF.request(path, method: .get, parameters: parameters, headers: headers)
            .serializingDecodable(MovieResponse.self)
            .value
        
        return response.results ?? [ ]
    }
    
    func loadMovieDetails(forID movieID: Int) async throws -> MovieDetails? {
        let path = generatePath(for: .movieDetails(movieID))
        let details: MovieDetails = try await AF.request(path, method: .get, parameters: languageParameter, headers: headers)
            .serializingDecodable(MovieDetails.self)
            .value
        return details
    }
    
    func loadGenres() async throws -> [Genre] {
        let path = generatePath(for: .genreList)
        let response: GenreResponse = try await AF.request(path, method: .get, parameters: languageParameter, headers: headers)
            .serializingDecodable(GenreResponse.self)
            .value
        return response.genres ?? [ ]
    }
    
    func trailerPath(forID movieID: Int) async throws -> String? {
        let path = generatePath(for: .movieVideos(movieID))
        let response: VideoResponse = try await AF.request(path, method: .get, parameters: languageParameter, headers: headers)
            .serializingDecodable(VideoResponse.self)
            .value
        guard let videos = response.results else { return nil }
        return findFirstTrailer(from: videos)
    }
    
    private func generatePath(for endpoint: Endpoint) -> String {
        switch endpoint {
        case .movieList(let type):
            return "/movie/\(type.rawValue)"
        case .movieDetails(let movieID):
            return "/movie/\(movieID)"
        case .genreList:
            return "/genre/movie/list"
        case .movieVideos(let movieID):
            return "/movie/\(movieID)/videos"
        }
    }
    
    private func findFirstTrailer(from videos: [Video]) -> String? {
        let trailerVideo = videos.first(where: { $0.type?.lowercased() == "trailer" })
        return trailerVideo?.key
    }
}


// MARK: - Response Models
private extension TMDBService {
    struct MovieResponse: Codable {
        let results: [Movie]?
    }
    
    struct GenreResponse: Codable {
        let genres: [Genre]?
    }
    
    struct VideoResponse: Codable {
        let results: [Video]?
    }
}
