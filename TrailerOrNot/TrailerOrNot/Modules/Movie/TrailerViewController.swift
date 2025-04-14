import UIKit
import WebKit

class TrailerViewController: UIViewController {
    let trailerPath: String
    var webView = WKWebView()

    init(trailerPath: String) {
        self.trailerPath = trailerPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadTrailer()
    }
    
    private func setupWebView() {
        view.backgroundColor = .systemBackground
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsLinkPreview = true
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadTrailer() {
        if let url = URL(string: trailerPath) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
