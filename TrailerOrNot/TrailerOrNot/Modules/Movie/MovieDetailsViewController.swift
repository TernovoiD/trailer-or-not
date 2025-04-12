import UIKit

final class MovieDetailsViewController: UIViewController {
    
    var movieTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = movieTitle ?? "Details"
    }
}
