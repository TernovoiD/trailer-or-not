import UIKit
import Combine
import Kingfisher

final class HomeViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = HomeViewModel()

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView()
    private let emptyDataLabel = UILabel()

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
        title = "Popular movies"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showOptions))

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        view.addSubview(searchBar)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 240
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.style = .large
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        
        emptyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyDataLabel.text = "Oops, no movies found..."
        emptyDataLabel.textAlignment = .center
        emptyDataLabel.isHidden = true
        view.addSubview(emptyDataLabel)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$allMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.updateTable()
            }
            .store(in: &subscriptions)
        
        viewModel.$searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.updateTable()
            }
            .store(in: &subscriptions)
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handle(state)
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorOccurred in
                guard errorOccurred else { return }
                self?.showErrorAlert()
            }
            .store(in: &subscriptions)
    }
}



//MARK: - Methods
private extension HomeViewController {
    func handle(_ state: HomeViewModel.State) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyDataLabel.isHidden = true
        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            emptyDataLabel.isHidden = false
        case .loaded:
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            emptyDataLabel.isHidden = true
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: viewModel.errorTitle ?? "Error",
                                      message: viewModel.errorMessage ?? "An unknown error occurred.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateTable() {
        if viewModel.currentPage >= 2 { tableView.reloadData() } else {
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
        }
    }
    
    @objc func refreshData() {
        viewModel.changeSortOption(to: viewModel.sortOption)
    }

    @objc func showOptions() {
        let actionSheet = UIAlertController(title: "Choose Sorting Preference", message: "Select your preferred option to customize how movies are displayed. Adjust your viewing experience to highlight the content you want to see.", preferredStyle: .actionSheet)
        
        for option in MovieList.allCases {
            let action = UIAlertAction(title: option.title, style: .default) { _ in
                self.viewModel.changeSortOption(to: option)
                self.title = option.title
                if self.tableView.numberOfRows(inSection: 0) > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
            if option == viewModel.sortOption {
                let image = UIImage(systemName: "checkmark")
                action.setValue(image, forKey: "image")
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}


//MARK: - UITableView Delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }
        let movie = viewModel.filteredMovies[indexPath.row]
        let genres = viewModel.findGenres(from: movie.genreIDs ?? [ ])
        cell.configure(title: movie.title ?? "", genre: genres, rating: movie.ratingString)
        if let path = movie.imageURLString,
           let url = URL(string: path) {
            let options: KingfisherOptionsInfo = viewModel.offlineMode ? [.onlyFromCache] : [ ]
            cell.movieImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: options)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = MovieDetailsViewController()
        detailsVC.movieTitle = viewModel.filteredMovies[indexPath.row].title ?? "Unknown"
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        let visibleCells = tableView.visibleCells
        guard let lastVisibleCell = visibleCells.last else { return }
        let lastIndexPath = tableView.indexPath(for: lastVisibleCell)
        if let lastIndexPath,
           lastIndexPath.row >= viewModel.filteredMovies.count - 10,
           !viewModel.allPagesLoaded,
           viewModel.state != .loading { viewModel.loadNextPage() }
    }
}


//MARK: - UISearchBar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.findMovie(withText: searchText)
    }
}
