import UIKit
import Combine

class HomeViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = HomeViewModel()

    let searchBar = UISearchBar()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        self.navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        title = "Popular movies"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Options",
            style: .plain,
            target: self,
            action: #selector(showOptions)
        )

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
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    }
    
    func updateTable() {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }

    @objc func showOptions() {
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Sort by Title", style: .default))
        actionSheet.addAction(UIAlertAction(title: "Sort by Genre", style: .default))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }
        let movie = viewModel.filteredMovies[indexPath.row]
        cell.configure(title: movie.title ?? "", genre: "genres", rating: "6.8")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = MovieDetailsViewController()
        detailsVC.movieTitle = viewModel.filteredMovies[indexPath.row].title ?? "Unknown"
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
}
