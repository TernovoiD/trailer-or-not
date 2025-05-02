import UIKit
import Kingfisher

final class MovieCell: UITableViewCell {
    private let movieImageView = UIImageView()
    private let cellBackground = UIView()
    private let tintView = UIView()
    private let titleLabel = UILabel()
    private let genreLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        cellBackground.translatesAutoresizingMaskIntoConstraints = false
        cellBackground.backgroundColor = .systemBackground
        cellBackground.layer.cornerRadius = 35
        cellBackground.layer.shadowColor = UIColor.black.cgColor
        cellBackground.layer.shadowOpacity = 0.5
        cellBackground.layer.shadowOffset = .zero
        cellBackground.layer.shadowRadius = 7
        contentView.addSubview(cellBackground)
        
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        movieImageView.contentMode = .scaleAspectFill
        movieImageView.image = UIImage(named: ImageAssets.placeholder)
        movieImageView.layer.cornerRadius = 35
        movieImageView.clipsToBounds = true
        cellBackground.addSubview(movieImageView)
        
        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        tintView.clipsToBounds = true
        movieImageView.addSubview(tintView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        tintView.addSubview(titleLabel)
        
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.font = UIFont.systemFont(ofSize: 18)
        genreLabel.numberOfLines = 2
        genreLabel.textColor = .white
        tintView.addSubview(genreLabel)
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.systemFont(ofSize: 18)
        ratingLabel.textColor = .white
        tintView.addSubview(ratingLabel)

        NSLayoutConstraint.activate([
            cellBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            cellBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            movieImageView.topAnchor.constraint(equalTo: cellBackground.topAnchor, constant: -2),
            movieImageView.leadingAnchor.constraint(equalTo: cellBackground.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: cellBackground.trailingAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: cellBackground.bottomAnchor, constant: 2),
            
            tintView.topAnchor.constraint(equalTo: movieImageView.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: movieImageView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: movieImageView.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: movieImageView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: tintView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: tintView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: tintView.trailingAnchor, constant: -20),
            
            genreLabel.bottomAnchor.constraint(equalTo: tintView.bottomAnchor, constant: -30),
            genreLabel.leadingAnchor.constraint(equalTo: tintView.leadingAnchor, constant: 20),
            genreLabel.trailingAnchor.constraint(equalTo: tintView.trailingAnchor, constant: -100),
            
            ratingLabel.bottomAnchor.constraint(equalTo: tintView.bottomAnchor, constant: -30),
            ratingLabel.trailingAnchor.constraint(equalTo: tintView.trailingAnchor, constant: -20),
        ])
    }
    
    // CR: як краще зробити рефакторінг сигнатури цієї функції? уявимо у нас було б 10 парамтерів
    func configure(from info: Movie.ShortInfo, onlineMode: Bool) {
        titleLabel.text = info.title
        genreLabel.text = info.genres
        ratingLabel.text = info.rating
        
        if let url = info.imageURL {
            let options: KingfisherOptionsInfo = onlineMode == true ? [] : [.onlyFromCache]
            // CR: UIImage(named: "placeholder") - які є варіанти менеджмента ресурсів, що б це не був хардкод назви
            movieImageView.kf.setImage(with: url, placeholder: UIImage(named: ImageAssets.placeholder), options: options)
        }
    }
}
