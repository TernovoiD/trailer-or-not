import Foundation

struct Movie: Codable {
	let genreIDs: [Int]?
	let id: Int?
	let posterPath: String?
	let releaseDate: String?
	let title: String?
	let rating: Double?

	enum CodingKeys: String, CodingKey {
		case genreIDs = "genre_ids"
		case id = "id"
		case posterPath = "poster_path"
		case releaseDate = "release_date"
		case title = "title"
		case rating = "vote_average"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        genreIDs = try values.decodeIfPresent([Int].self, forKey: .genreIDs)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
        posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try values.decodeIfPresent(String.self, forKey: .releaseDate)
		title = try values.decodeIfPresent(String.self, forKey: .title)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
	}
    
    var imageURLString: String? {
        let basePath = "https://image.tmdb.org/t/p/w500"
        guard let posterPath else { return nil }
        return basePath + posterPath
    }
    
    var ratingString: String {
        if let rating {
            return "\(rating)"
        } else {
            return ""
        }
    }
}
