import Foundation
import Combine

final class HomeViewModel: HomeViewModelProtocol {
    private let moviesAPI: TMDBService
    
    @Published var error: Bool = false
    @Published var state: State = .loading
    @Published var searchText: String = ""
    @Published var movieDetails: MovieDetails.WithTrailer?
    
    private var movies: [Movie] = [ ]
    private var genres: [Genre] = [ ]
    private var loadingPages = false
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
    // CR: тобто у результатах пошука ми покажемло лише локальний контент?
    // Тепер, при наявності інтернету, ми робимо мережевий запит на пошук фільмів
    var moviesToShow: [Movie] {
        if offlineMode && !searchText.isEmpty { searchedMovies } else { movies }
    }
    
    private var searchedMovies: [Movie] {
        movies.filter({ $0.titleContains(searchText) })
    }
    
    func loadNextPage() {
        if isLastPage || loadingPages { return }
        currentPage += 1
        loadingPages = true
        Task {
            var newMovies = [Movie]()
            if searchText.isEmpty {
                newMovies = await loadMovies(for: sortOption, page: currentPage)
            } else {
                newMovies = await findMovies(for: searchText, page: currentPage)
            }
            if newMovies.count == 0 { isLastPage = true } else {
                movies.append(contentsOf: newMovies)
                finishLoadingState()
            }
            loadingPages = false
        }
    }
    
    func changeSortOption(to option: MovieList, refresh: Bool = false) {
        verifyConnection()
        currentPage = 1
        isLastPage = false
        sortOption = option
        if !searchText.isEmpty { return }
        Task {
            startLoadingState(refresh: refresh)
            // CR: навіщо потрібен цей delay?
            // API завантаєує дані миттєво, тому користувач ніколи не побачить анімації підвантаження (що було умовою в ТЗ). Можливо правильніше зробити невелику зупинку перед тим як змінювати State, або на рівні ViewController, коли він бачить зміну State. Але це може ускладнити сам Controller і його читабельність.
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
        verifyConnection()
        searchText = textToSearch
        currentPage = 1
        if textToSearch.isEmpty {
            changeSortOption(to: sortOption)
            return
        }
        if offlineMode {
            if state == .loading { return } else { finishLoadingState() }
        } else {
            Task {
                startLoadingState()
                await Task.delay()
                movies = await findMovies(for: textToSearch, page: 1)
                finishLoadingState()
            }
        }
    }
    
    func shortInfo(for movie: Movie) -> Movie.ShortInfo {
        var title = movie.title ?? ""
        var rating = ""
        let imagePath = TMDBImageURL.buildImageURL(for: movie.posterPath, withSize: Screen.size)
        var imageURL: URL?
        let genres = findGenres(from: movie.genreIDs ?? [ ])
        
        if let releaseDate = movie.releaseDate, !title.isEmpty {
            let year = String(releaseDate.prefix(4))
            title = [title, year].joined(separator: ", ")
        }
        
        if let ratingNumber = movie.rating { rating = String(ratingNumber) }
        
        if let imagePath { imageURL = URL(string: imagePath) }
        
        return Movie.ShortInfo(title: title, genres: genres, rating: rating, imageURL: imageURL)
    }
    
    private func findGenres(from genreIDs: [Int]) -> String {
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
    
    func findMovies(for text: String, page: Int) async -> [Movie] {
        do {
            return try await moviesAPI.searchMovies(query: text, page: page)
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
        // CR: виглядає дивно, враховуючи що у нас `offlineMode = !isConnected`
        // Це запобіжник, щоб error був показаний лише один раз, коли ми переходимо з online -> offline. Інакше він буде кожен раз при пагінації (при тому що дані все одно надходять з кеша)
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
        // CR: виглядає трохи заплутано, чому б не розділити встановлення стейту окремо при пощуку?
        // Мається на увазі рефакторинг метода для читабельності, чи інший підхід в визначенні State?
        // Наш HomeView починає мати багато станів: пошук(онлайн/оффлайн, пустий/повний), сортування (пусте/повне). Прорахувати кінцевий State післе методів стає дедалі важче і стають можливі неочікувані комбінації. Тому я вирішив тримати логіку вирішення кінцевого State централізовано. Потенційно, вона має вирости в цілий окремий механізм.
        state = moviesToShow.isEmpty ? (movies.isEmpty ? .emptyData : .emptySearch) : .ready
    }
}
