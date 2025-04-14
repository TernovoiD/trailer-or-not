import Foundation
import Combine

@MainActor
final class HomeViewModel {
    private let moviesAPI: TMDBService
    
    @Published var error: Bool = false
    @Published var state: State = .loading
    @Published var searchText: String = ""
    @Published var movieDetails: MovieDetails.WithTrailer?
    
    private var movies: [Movie] = [ ]
    private var genres: [Genre] = [ ]
    private(set) var sortOption: MovieList = .popular
    private(set) var errorTitle: String?
    private(set) var errorMessage: String?
    private(set) var offlineMode = false
    private(set) var currentPage = 1
    private var isLastPage = false
    
    enum State { case loading, refreshing, ready, emptyData, emptySearch }
    
    init(moviesAPI: TMDBService) {
        self.moviesAPI = moviesAPI
        Task {
            await loadGenres()
            changeSortOption(to: .popular)
        }
    }
    
    var moviesToShow: [Movie] { searchText.isEmpty ? movies : searchedMovies }
    
    private var searchedMovies: [Movie] {
        movies.filter({ $0.titleContains(searchText) })
    }
    
    func loadNextPage() {
        if isLastPage { return }
        currentPage += 1
        Task {
            let newMovies = await loadMovies(for: sortOption, page: currentPage)
            if newMovies.count == 0 { isLastPage = true } else {
                movies.append(contentsOf: newMovies)
                finishLoadingState()
            }
        }
    }
    
    func changeSortOption(to option: MovieList, refresh: Bool = false) {
        verifyConnection()
        currentPage = 1
        isLastPage = false
        sortOption = option
        Task {
            startLoadingState(refresh: refresh)
            await Task.delay()
            movies = await loadMovies(for: sortOption, page: currentPage)
            finishLoadingState()
        }
    }
    
    func openMovie(withID movieID: Int) {
        verifyConnection()
        if offlineMode {
            showError(message: LocalizedText.Error.network)
            return
        }
        Task {
            startLoadingState()
            await Task.delay()
            let details = await loadDetails(for: movieID)
            finishLoadingState()
            self.movieDetails = details
        }
    }
    
    func findMovie(withText textToSearch: String) {
        searchText = textToSearch
        if state == .loading { return } else { finishLoadingState() }
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
}


//MARK: - Private methods
private extension HomeViewModel {
    func loadGenres() async {
        guard let loadedGenres = try? await moviesAPI.loadGenres() else { return }
        self.genres = loadedGenres
    }
    
    func loadMovies(for option: MovieList, page: Int) async -> [Movie] {
        do {
            return try await moviesAPI.loadMovies(type: option, page: page)
        } catch let error {
            handle(error)
            return [ ]
        }
    }
    
    func loadDetails(for movieID: Int) async -> MovieDetails.WithTrailer? {
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
    
    func verifyConnection() {
        let isConnected = moviesAPI.isInternetAvailable()
        if !isConnected && !offlineMode {
            showError(message: LocalizedText.Error.network)
        }
        offlineMode = !isConnected
    }
    
    func handle(_ error: Error) {
        finishLoadingState()
        if !offlineMode { showError(message: error.localizedDescription) }
    }

    func showError(title: String? = LocalizedText.Error.title, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.error = true
    }
    
    private func startLoadingState(refresh: Bool = false) {
        state = refresh ? .refreshing : .loading
    }
    
    private func finishLoadingState() {
        state = moviesToShow.isEmpty ? (movies.isEmpty ? .emptyData : .emptySearch) : .ready
    }
}
