import UIKit

class MainRouter {
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showMovieDetails(for movieDetails: MovieDetails.WithTrailer) {
        let detailsVC = MovieViewController(details: movieDetails)
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func showErrorAlert(title: String, message: String) {
        guard let topVC = navigationController?.topViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedText.okButtonText, style: .default, handler: nil))
        topVC.present(alert, animated: true, completion: nil)
    }
}
