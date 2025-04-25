import Foundation
import Alamofire

class TMDBService {
    private let baseURL = "https://api.themoviedb.org/3"
    private let languageParameter = ["language":"en-US"]
    private let headers: HTTPHeaders = [
        "accept": "application/json",
        "Authorization": "Bearer \(Secret.readAccessTokenTMDB)"
    ]
    
    private enum Endpoint {
        case movieList(MovieList)
        case movieDetails(Int)
        case genreList
        case movieVideos(Int)
    }
    
    func loadMovies(type: MovieList, page: Int) async throws -> [Movie] {
        let parameters: [String: String] = [
            "language": "en-US",
            "page": "\(page)"
        ]
        let response: MovieResponse = try await getData(endpoint: .movieList(type), with: parameters)
        return response.results ?? [ ]
    }
    
    func loadMovieDetails(forID movieID: Int) async throws -> MovieDetails? {
        return try await getData(endpoint: .movieDetails(movieID))
    }
    
    func loadGenres() async throws -> [Genre] {
        let response: GenreResponse = try await getData(endpoint: .genreList)
        return response.genres ?? [ ]
    }
    
    func trailerPath(forID movieID: Int) async throws -> String? {
        let response: VideoResponse = try await getData(endpoint: .movieVideos(movieID))
        guard let videos = response.results else { return nil }
        return findFirstTrailer(from: videos)
    }
    
    func isInternetAvailable() -> Bool {
        let reachabilityManager = NetworkReachabilityManager()
        return reachabilityManager?.isReachable ?? false
    }
    
    private func generatePath(for endpoint: Endpoint) -> String {
        switch endpoint {
        case .movieList(let type):
            return baseURL + "/movie/\(type.rawValue)"
        case .movieDetails(let movieID):
            return baseURL + "/movie/\(movieID)"
        case .genreList:
            return baseURL + "/genre/movie/list"
        case .movieVideos(let movieID):
            return baseURL + "/movie/\(movieID)/videos"
        }
    }
    
    private func findFirstTrailer(from videos: [Video]) -> String? {
        let baseURLStringYT = "https://www.youtube.com/watch?v="
        let trailerVideo = videos.first(where: { $0.type?.lowercased() == "trailer" })
        if let key = trailerVideo?.key,
           let website = trailerVideo?.site,
           website.lowercased() == "youtube" {
            return baseURLStringYT + key
        } else { return nil }
    }
    
    private func getData<T: Decodable>(endpoint: Endpoint, with parameters: [String: String]? = nil) async throws -> T {
        let requestParameters: [String: String] = parameters ?? ["language":"en-US"]
        let urlPath = generatePath(for: endpoint)
        return try await AF.request(urlPath, method: .get, parameters: requestParameters, headers: headers)
                    .validate()
                    .serializingDecodable(T.self)
                    .value
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
