import UIKit
import Combine

final class HomeViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: HomeViewModel

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let emptyDataLabel = UILabel()
    private let loadingIndicator = LoadingCircle()
    
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
        view.backgroundColor = .systemBackground
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        title = MovieList.popular.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedText.sortButtonText, style: .plain, target: self, action: #selector(showOptions))
        
        setupUITable()
        setupSearchBar()
        setupEmptyLabel()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupUITable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableManager.configureTableView(tableView)
        tableManager.scrollAction = paginationCheck
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
    }
    
    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = searchBarManager
        searchBar.placeholder = LocalizedText.searchBarPlaceholder
        view.addSubview(searchBar)
    }
    
    private func setupEmptyLabel() {
        emptyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyDataLabel.text = LocalizedText.Error.emptyData
        emptyDataLabel.textAlignment = .center
        emptyDataLabel.isHidden = true
        view.addSubview(emptyDataLabel)
    }
    
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
    }
    
    private func bindViewModel() {
        viewModel.$searchText
            .sink { [weak self] movies in
                self?.updateTable()
            }
            .store(in: &subscriptions)
        
        viewModel.$state
            .sink { [weak self] state in
                self?.updateUI(state)
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 200),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    private func updateUI(_ state: HomeViewModel.State) {
        switch state {
        case .loading:
            loadingUI(true)
        case .refreshing:
            loadingUI(false)
        case .ready:
            updateTable()
            loadingUI(false)
            showTable()
            refreshControl.endRefreshing()
        case .emptyData:
            loadingUI(false)
            updateTable()
            showEmptySign(with: LocalizedText.Error.emptyData)
            refreshControl.endRefreshing()
        case .emptySearch:
            loadingUI(false)
            updateTable()
            showEmptySign(with: LocalizedText.Error.emptySearch)
            refreshControl.endRefreshing()
        }
    }
    
    private func loadingUI(_ inProgress: Bool) {
        if inProgress {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    private func showTable() {
        tableView.isHidden = false
        emptyDataLabel.isHidden = true
    }
    
    private func showEmptySign(with text: String) {
        tableView.isHidden = true
        emptyDataLabel.text = text
        emptyDataLabel.isHidden = false
    }
    
    private func paginationCheck() {
        searchBar.resignFirstResponder()
        let visibleCells = tableView.visibleCells
        guard let lastVisibleCell = visibleCells.last else { return }
        let lastIndexPath = tableView.indexPath(for: lastVisibleCell)
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
    
    private func updateTable() {
        if viewModel.currentPage >= 2 { tableView.reloadData() } else {
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
        }
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
        if self.tableView.numberOfRows(inSection: 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}
