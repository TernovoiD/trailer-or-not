import Foundation
import Combine

final class HomeViewModel {
    @Published var allMovies: [Movie] = [ ]
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
    private let moviesAPI = TMDBService()
    
    enum State { case loading, loaded, empty }
    
    var filteredMovies: [Movie] {
        if searchText.isEmpty { allMovies } else {
            allMovies.filter({
                guard let movieTitle = $0.title else { return false }
                return movieTitle.lowercased().contains(searchText.lowercased())
            })
        }
    }
    
    init() {
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
        var movies = [Movie]()
        do {
            movies = try await moviesAPI.loadMovies(type: option, page: page)
        } catch let error { handle(error) }
        return movies
    }
    
    private func checkConnection() {
        let isConnected = moviesAPI.isInternetAvailable()
        if !isConnected && !offlineMode {
            showError(title: "Network error", message: "You are offline. Please, enable your Wi-Fi or connect using cellular data.")
        }
        offlineMode = !isConnected
    }
    
    private func handle(_ error: Error) {
        state = filteredMovies.isEmpty ? .empty : .loaded
        if !offlineMode {
            showError(title: "Error", message: error.localizedDescription)
        }
    }

    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.error = true
    }
}
