import UIKit

class AppContainer {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func makeHomeViewController() -> HomeViewController {
        let movieService = TMDBService()
        let viewModel = HomeViewModel(moviesAPI: movieService)
        let router = MainRouter(navigationController: navigationController)
        return HomeViewController(viewModel: viewModel, router: router)
    }
}
