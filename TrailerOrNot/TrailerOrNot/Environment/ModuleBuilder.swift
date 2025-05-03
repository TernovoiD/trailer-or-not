import UIKit

final class ModuleBuilder {
    private let navigationController: UINavigationController
    private let movieService = TMDBService()
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func homeViewController() -> HomeViewController {
        let dependencies = generateHomeVCDependencies()
        return HomeViewController(with: dependencies)
    }
    
    private func generateHomeVCDependencies() -> HomeModuleDependencies {
        let viewModel = HomeViewModel(moviesAPI: movieService)
        let router = TopRouter(navigationController: navigationController)
        let tableManager = HomeTableViewManager(viewModel: viewModel)
        let searchBarManager = HomeSearchBarManager(viewModel: viewModel)
        
        return HomeModuleDependencies(
            viewModel: viewModel,
            router: router,
            tableManager: tableManager,
            searchBarManager: searchBarManager
        )
    }
}
