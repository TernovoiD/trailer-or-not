import Foundation
import Combine

final class HomeViewModel {
    private let moviesAPI: TMDBService
    
    @Published var allMovies: [Movie] = [ ]
    @Published var movieDetails: MovieDetails.WithTrailer?
    @Published var searchText: String = ""
    @Published var error: Bool = false
    @Published var state: State = .loading
    
    var genres: [Genre] = [ ]
    var sortOption: MovieList = .popular
    var errorTitle: String?
    var errorMessage: String?
    var currentPage: Int = 1
    var allPagesLoaded: Bool = false
    var offlineMode = false

    private var cancellables = Set<AnyCancellable>()
    
    enum State { case loading, loaded, empty }
    
    var filteredMovies: [Movie] {
        if searchText.isEmpty { allMovies } else {
            allMovies.filter({
                guard let movieTitle = $0.title else { return false }
                return movieTitle.lowercased().contains(searchText.lowercased())
            })
        }
    }
    
    init(moviesAPI: TMDBService) {
        self.moviesAPI = moviesAPI
        Task {
            await loadGenres()
            changeSortOption(to: .popular)
        }
    }
    
    func loadNextPage() {
        currentPage += 1
        Task {
            let newMovies = await loadMovies(for: sortOption, page: currentPage)
            if newMovies.count == 0 { allPagesLoaded = true } else {
                allMovies.append(contentsOf: newMovies)
            }
        }
    }
    
    func changeSortOption(to option: MovieList) {
        checkConnection()
        currentPage = 1
        allPagesLoaded = false
        sortOption = option
        Task {
            state = .loading
            allMovies = await loadMovies(for: sortOption, page: currentPage)
            state = filteredMovies.isEmpty ? .empty : .loaded
        }
    }
    
    func openMovie(withID movieID: Int) {
        checkConnection()
        if offlineMode {
            showError(message: LocalizedText.Error.network)
            return
        }
        Task {
            state = .loading
            movieDetails = await loadDetails(for: movieID)
            state = filteredMovies.isEmpty ? .empty : .loaded
        }
    }
    
    func findMovie(withText textToSearch: String) {
        searchText = textToSearch
        if state == .loading { return }
        state = filteredMovies.isEmpty ? .empty : .loaded
    }
    
    func findGenres(from genreIDs: [Int]) -> String {
        var genreString = [String]()
        for genreId in genreIDs {
            if let genre = genres.first(where: { $0.id == genreId }) {
                if let genreName = genre.name { genreString.append(genreName) }
            }
        }
        return genreString.joined(separator: ", ")
    }
    
    private func loadGenres() async {
        do {
            let allGenres = try await moviesAPI.loadGenres()
            self.genres = allGenres
        } catch let error { handle(error) }
    }
    
    private func loadMovies(for option: MovieList, page: Int) async -> [Movie] {
        do {
            return try await moviesAPI.loadMovies(type: option, page: page)
        } catch let error {
            handle(error)
            return [ ]
        }
    }
    
    private func loadDetails(for movieID: Int) async -> MovieDetails.WithTrailer? {
        do {
            let details = try await moviesAPI.loadMovieDetails(forID: movieID)
            let trailerPath = try await moviesAPI.trailerPath(forID: movieID)
            if let details {
                return MovieDetails.WithTrailer(movieDetails: details, trailerPath: trailerPath)
            } else { return nil }
        } catch let error {
            handle(error)
            return nil
        }
    }
    
    private func checkConnection() {
        let isConnected = moviesAPI.isInternetAvailable()
        if !isConnected && !offlineMode {
            showError(message: LocalizedText.Error.network)
        }
        offlineMode = !isConnected
    }
    
    private func handle(_ error: Error) {
        state = filteredMovies.isEmpty ? .empty : .loaded
        if !offlineMode {
            showError(message: error.localizedDescription)
        }
    }

    private func showError(title: String? = LocalizedText.Error.title, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.error = true
    }
}
