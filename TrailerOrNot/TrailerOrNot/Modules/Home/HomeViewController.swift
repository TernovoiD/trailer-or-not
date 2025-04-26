import UIKit
import Combine

final class HomeViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: HomeViewModel
    private let homeView = HomeView()
    private let tableManager: HomeTableViewManager
    private let searchBarManager: HomeSearchBarManager
    private let router: MainRouter
    
    init(viewModel: HomeViewModel, router: MainRouter) {
        self.viewModel = viewModel
        self.router = router
        self.tableManager = HomeTableViewManager(viewModel: viewModel)
        self.searchBarManager = HomeSearchBarManager(viewModel: viewModel)
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
        homeView.refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        title = MovieList.popular.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedText.sortButtonText, style: .plain, target: self, action: #selector(showOptions))
        
    }
    
    private func bindViewModel() {
        viewModel.$searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.homeView.table.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(state)
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorOccurred in
                guard errorOccurred else { return }
                self?.showErrorAlert()
            }
            .store(in: &subscriptions)
        
        viewModel.$movieDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] details in
                if let details { self?.openDetailView(for: details) }
            }
            .store(in: &subscriptions)
    }
    
    private func updateUI(_ state: HomeViewModel.State) {
        switch state {
        case .loading:
            homeView.loadingUI(true)
        case .refreshing:
            homeView.loadingUI(false)
        case .ready:
            updateTable()
            homeView.loadingUI(false)
            homeView.showTable()
            homeView.refresh.endRefreshing()
        case .emptyData:
            homeView.loadingUI(false)
            updateTable()
            homeView.showEmptySign(with: LocalizedText.Error.emptyData)
            homeView.refresh.endRefreshing()
        case .emptySearch:
            homeView.loadingUI(false)
            updateTable()
            homeView.showEmptySign(with: LocalizedText.Error.emptySearch)
            homeView.refresh.endRefreshing()
        }
    }
    
    private func updateTable() {
        let page = viewModel.currentPage
        if page >= 2 { homeView.table.reloadData() } else {
            UIView.transition(with: homeView.table, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.homeView.table.reloadData()
            }, completion: nil)
        }
    }
    
    private func paginationCheck() {
        dismissKeyboard()
        let visibleCells = homeView.table.visibleCells
        guard let lastVisibleCell = visibleCells.last else { return }
        let lastIndexPath = homeView.table.indexPath(for: lastVisibleCell)
        if let lastIndexPath,
           lastIndexPath.row >= viewModel.moviesToShow.count - 10 { viewModel.loadNextPage() }
    }
    
    private func openDetailView(for movieDetails: MovieDetails.WithTrailer) {
        router.showMovieDetails(for: movieDetails)
    }
    
    private func showErrorAlert() {
        let title = viewModel.errorTitle ?? LocalizedText.Error.title
        let message = viewModel.errorMessage ?? LocalizedText.Error.unknown
        router.showErrorAlert(title: title, message: message)
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
                let image = UIImage(systemName: ImageAssets.checkMark)
                action.setValue(image, forKey: "image")
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: LocalizedText.cancelButtonText, style: .cancel))
        present(actionSheet, animated: true)
    }
    
    private func scrollUP() {
        if homeView.table.numberOfRows(inSection: 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            homeView.table.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        homeView.search.resignFirstResponder()
    }
}
