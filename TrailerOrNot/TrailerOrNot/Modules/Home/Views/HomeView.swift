import UIKit

class HomeView: UIView {
    // CR: чи мають всі ці поля бути internal?
    // CR: деякі можна прямо зараз зробити private, деякі ні, який паттерн тут порушується?
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    let emptyDataLabel = UILabel()
    let loadingIndicator = LoadingCircle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        setupSearchBar()
        setupTableView()
        setupEmptyLabel()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = LocalizedText.searchBarPlaceholder
        addSubview(searchBar)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        addSubview(tableView)
    }
    
    private func setupEmptyLabel() {
        emptyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyDataLabel.text = LocalizedText.Error.emptyData
        emptyDataLabel.textAlignment = .center
        emptyDataLabel.isHidden = true
        addSubview(emptyDataLabel)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emptyDataLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyDataLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyDataLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyDataLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 200),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    func setupWith(tableManager: HomeTableViewManager, searchBarManager: HomeSearchBarManager) {
        tableManager.configureTableView(tableView)
        searchBar.delegate = searchBarManager
    }
    
    func updateUI(_ state: HomeViewModel.State, currentPage: Int) {
        switch state {
        case .loading:
            loadingUI(true)
        case .refreshing:
            loadingUI(false)
        case .ready:
            updateTable(forPage: currentPage)
            loadingUI(false)
            showTable()
            refreshControl.endRefreshing()
        case .emptyData:
            loadingUI(false)
            updateTable(forPage: currentPage)
            showEmptySign(with: LocalizedText.Error.emptyData)
            refreshControl.endRefreshing()
        case .emptySearch:
            loadingUI(false)
            updateTable(forPage: currentPage)
            showEmptySign(with: LocalizedText.Error.emptySearch)
            refreshControl.endRefreshing()
        }
    }
    
    func updateTable(forPage page: Int) {
        // CR: чи має ця логіка бути на рівні view?
        if page >= 2 { tableView.reloadData() } else {
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
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
}
