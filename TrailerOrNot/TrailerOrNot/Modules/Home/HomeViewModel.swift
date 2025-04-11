import Foundation
import Combine

class HomeViewModel {
    @Published var allMovies: [Movie] = []
    @Published var searchText: String = ""
    
    @Published var isLoading: Bool = false
    
    @Published var sortOption: MovieList = .popular

    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var error: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let moviesAPI = TMDBService()
    private var currentPage: Int = 1
    
    var filteredMovies: [Movie] {
        if searchText.isEmpty { allMovies } else {
            allMovies.filter({
                guard let movieTitle = $0.title else { return false }
                return movieTitle.lowercased().contains(searchText.lowercased())
            })
        }
    }
    
    init() {
        Task { await loadMovies(for: sortOption, page: currentPage) }
    }
    
    func loadNextPage() {
        currentPage += 1
        Task { await loadMovies(for: sortOption, page: currentPage) }
    }
    
    func changeSortOption(to option: MovieList) {
        currentPage = 1
        sortOption = option
        Task { await loadMovies(for: sortOption, page: currentPage) }
    }
    
    @MainActor
    private func loadMovies(for option: MovieList, page: Int) async {
        do {
            let newMovies = try await moviesAPI.loadMovies(type: option, page: page)
            self.allMovies.append(contentsOf: newMovies)
        } catch let error {
            showError(title: "Error", message: error.localizedDescription)
        }
    }

    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.error = true
    }
}
