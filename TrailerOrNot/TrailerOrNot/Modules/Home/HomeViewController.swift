import UIKit
import Combine

final class HomeViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: HomeViewModel
    private let homeView = HomeView()
    private let tableManager: HomeTableViewManager
    private let searchBarManager: HomeSearchBarManager
    
    init(movieService: TMDBService) {
        let viewModel = HomeViewModel(moviesAPI: movieService)
        self.tableManager = HomeTableViewManager(viewModel: viewModel)
        self.searchBarManager = HomeSearchBarManager(viewModel: viewModel)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view = homeView
        view.backgroundColor = .systemBackground
        homeView.setupWith(tableManager: tableManager, searchBarManager: searchBarManager)
        tableManager.scrollAction = paginationCheck
        homeView.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        title = MovieList.popular.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedText.sortButtonText, style: .plain, target: self, action: #selector(showOptions))
        
    }
    
    private func bindViewModel() {
        viewModel.$searchText
            .sink { [weak self] movies in
                self?.updateTable()
            }
            .store(in: &subscriptions)
        
        viewModel.$state
            .sink { [weak self] state in
                guard let page = self?.viewModel.currentPage else { return }
                self?.homeView.updateUI(state, currentPage: page)
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .sink { [weak self] errorOccurred in
                guard errorOccurred else { return }
                self?.showErrorAlert()
            }
            .store(in: &subscriptions)
        
        viewModel.$movieDetails
            .sink { [weak self] details in
                if let details { self?.openDetailView(for: details) }
            }
            .store(in: &subscriptions)
    }
    
    private func updateTable() {
        homeView.updateTable(forPage: viewModel.currentPage)
    }
    
    private func paginationCheck() {
        homeView.searchBar.resignFirstResponder()
        let visibleCells = homeView.tableView.visibleCells
        guard let lastVisibleCell = visibleCells.last else { return }
        let lastIndexPath = homeView.tableView.indexPath(for: lastVisibleCell)
        if let lastIndexPath,
           lastIndexPath.row >= viewModel.moviesToShow.count - 10 { viewModel.loadNextPage() }
    }
    
    private func openDetailView(for movieDetails: MovieDetails.WithTrailer) {
        let detailsVC = MovieViewController(details: movieDetails)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: viewModel.errorTitle ?? LocalizedText.Error.title,
                                      message: viewModel.errorMessage ?? LocalizedText.Error.unknown,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.okButtonText, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func refreshData() {
        viewModel.changeSortOption(to: viewModel.sortOption, refresh: true)
    }

    @objc private func showOptions() {
        let actionSheet = UIAlertController(title: LocalizedText.sortTitle, message: LocalizedText.sortDescription, preferredStyle: .actionSheet)
        
        for option in MovieList.allCases {
            let action = UIAlertAction(title: option.title, style: .default) { _ in
                self.viewModel.changeSortOption(to: option)
                self.title = option.title
                self.scrollUP()
            }
            if option == viewModel.sortOption {
                let image = UIImage(systemName: "checkmark")
                action.setValue(image, forKey: "image")
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: LocalizedText.cancelButtonText, style: .cancel))
        present(actionSheet, animated: true)
    }
    
    private func scrollUP() {
        if homeView.tableView.numberOfRows(inSection: 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            homeView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        homeView.searchBar.resignFirstResponder()
    }
}
