import UIKit
import Kingfisher

protocol HomeViewModelProtocol {
    var moviesToShow: [Movie] { get }
    func shortInfo(for movie: Movie) -> Movie.ShortInfo
    var offlineMode: Bool { get }
    func openMovie(withID id: Int)
}

class HomeTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: HomeViewModelProtocol
    private let CellID = String(describing: MovieCell.self)
    var scrollAction: (() -> ())?
    
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func configureTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: CellID)
        tableView.separatorStyle = .none
        tableView.rowHeight = 240
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.moviesToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }

        let movie = viewModel.moviesToShow[indexPath.row]
        cell.configure(from: viewModel.shortInfo(for: movie), onlineMode: !viewModel.offlineMode)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let movieID = viewModel.moviesToShow[indexPath.row].id {
            viewModel.openMovie(withID: movieID)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let scrollAction { scrollAction() }
    }
}
