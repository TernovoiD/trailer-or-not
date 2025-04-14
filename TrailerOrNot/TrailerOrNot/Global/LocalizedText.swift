import Foundation

struct LocalizedText {
    static let sortButtonText = NSLocalizedString("Sort", comment: "Sort movies button")
    static let cancelButtonText = NSLocalizedString("Cancel", comment: "Cancel button")
    static let okButtonText = NSLocalizedString("OK", comment: "OK button")
    static let searchBarPlaceholder = NSLocalizedString("Search", comment: "Search movies")
    static let emptySearchLable = NSLocalizedString("Oops, no movies found...", comment: "Empty search lable")
    static let sortTitle = NSLocalizedString("Choose Sorting Preference", comment: "Sort title")
    static let sortDescription = NSLocalizedString("Select your preferred option to customize how movies are displayed. Adjust your viewing experience to highlight the content you want to see.", comment: "Sort description")
    
    struct Error {
        static let title = NSLocalizedString("Error", comment: "Error title")
        static let unknown = NSLocalizedString("An unknown error occurred.", comment: "Unknown error")
        static let network = NSLocalizedString("You are offline. Please, enable your Wi-Fi or connect using cellular data.", comment: "Network error")
    }
}
