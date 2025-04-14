import UIKit
import Kingfisher

class HomeTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: HomeViewModel
    private let CellID = "MovieCell"
    var scrollAction: (() -> ())?
    
    init(viewModel: HomeViewModel) {
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
        let genres = viewModel.findGenres(from: movie.genreIDs ?? [])
        cell.configure(title: movie.fullTitle, genre: genres, rating: movie.ratingString)

        if let path = movie.imageURLString, let url = URL(string: path) {
            let options: KingfisherOptionsInfo = viewModel.offlineMode == true ? [.onlyFromCache] : []
            cell.movieImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: options)
        }
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
