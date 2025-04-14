import UIKit

class HomeSearchBarManager: NSObject, UISearchBarDelegate {
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.findMovie(withText: searchText)
    }
}
