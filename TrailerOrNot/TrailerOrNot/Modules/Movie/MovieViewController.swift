import UIKit
import Kingfisher

final class MovieViewController: UIViewController {
    
    let details: MovieDetails.WithTrailer
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let countryYearLabel = UILabel()
    private let genreLabel = UILabel()
    private let playButton = UIButton()
    private let ratingLabel = UILabel()
    private let overviewLabel = UILabel()
    
    init(details: MovieDetails.WithTrailer) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImage))
        tapGesture.cancelsTouchesInView = false
        title = details.movieDetails.title
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        view.addSubview(imageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 24)
        view.addSubview(nameLabel)
        
        countryYearLabel.translatesAutoresizingMaskIntoConstraints = false
        countryYearLabel.font = .systemFont(ofSize: 16)
        view.addSubview(countryYearLabel)
        
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.font = .systemFont(ofSize: 14)
        genreLabel.numberOfLines = 2
        view.addSubview(genreLabel)
        
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.numberOfLines = 0
        overviewLabel.font = .systemFont(ofSize: 16)
        view.addSubview(overviewLabel)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.tintColor = .systemRed
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        if let _ = details.trailerPath { view.addSubview(playButton) }
        
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            countryYearLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            countryYearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            countryYearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genreLabel.topAnchor.constraint(equalTo: countryYearLabel.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            playButton.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 16),
            playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            
            ratingLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc func showImage() {
        let imageVC = PosterViewController(image: imageView.image)
        imageVC.modalPresentationStyle = .fullScreen
        present(imageVC, animated: true, completion: nil)
    }
    
    private func populateData() {
        let movie = details.movieDetails
        nameLabel.text = movie.title
        countryYearLabel.text = "\(movie.originCountry?.first ?? "Unknown Country"), \(movie.releaseDate?.prefix(4) ?? "Unknown Year")"
        ratingLabel.text = "Rating: \(String(format: "%.1f", movie.rating ?? 0))"
        overviewLabel.text = movie.overview ?? ""
        
        if let genres = movie.genres?.compactMap({ $0.name }) {
            genreLabel.text = genres.joined(separator: ", ")
        } else {
            genreLabel.text = "No genres available"
        }
        
        if let path = movie.imageURLString, let url = URL(string: path) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
    }
    
    @objc private func playButtonTapped() {
        guard let movieID = details.trailerPath else { return }
        let trailerVC = TrailerViewController(trailerPath: movieID)
        navigationController?.pushViewController(trailerVC, animated: true)
    }
}
