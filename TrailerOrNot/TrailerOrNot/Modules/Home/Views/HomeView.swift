import UIKit

final class HomeView: UIView {
    // CR: чи мають всі ці поля бути internal?
    // CR: деякі можна прямо зараз зробити private, деякі ні, який паттерн тут порушується
    // Тепер ми можемо читати та використовувати методи, але не зможемо цілком переназначити компонент
    // Це має покращити інкапсуляцію
    public private(set) var searchBar = UISearchBar()
    public private(set) var tableView = UITableView()
    public private(set) var refreshControl = UIRefreshControl()
    private let emptyDataLabel = UILabel()
    private let loadingIndicator = LoadingCircle()
 
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
       
    func loadingUI(_ inProgress: Bool) {
        if inProgress {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    func showTable() {
        tableView.isHidden = false
        emptyDataLabel.isHidden = true
    }
    
    func showEmptySign(with text: String) {
        tableView.isHidden = true
        emptyDataLabel.text = text
        emptyDataLabel.isHidden = false
    }
}
