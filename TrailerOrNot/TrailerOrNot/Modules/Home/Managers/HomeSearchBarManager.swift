import UIKit

final class HomeSearchBarManager: NSObject, UISearchBarDelegate {
    private let viewModel: HomeViewModel
    private var searchTimer: Timer?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.viewModel.findMovie(withText: searchText)
        }
    }
}
