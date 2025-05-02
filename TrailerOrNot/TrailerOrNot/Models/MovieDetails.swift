import Foundation

struct MovieDetails: Decodable {
    let id: Int?
    let title: String?
    let overview: String?
	let genres: [Genre]?
	let originCountry: [String]?
    let releaseDate: String?
	let posterPath: String?
	let rating: Double?

	enum CodingKeys: String, CodingKey {
		case genres = "genres"
		case id = "id"
		case originCountry = "origin_country"
		case overview = "overview"
		case posterPath = "poster_path"
		case releaseDate = "release_date"
		case title = "title"
		case rating = "vote_average"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		genres = try values.decodeIfPresent([Genre].self, forKey: .genres)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
        originCountry = try values.decodeIfPresent([String].self, forKey: .originCountry)
		overview = try values.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try values.decodeIfPresent(String.self, forKey: .releaseDate)
		title = try values.decodeIfPresent(String.self, forKey: .title)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
	}
    
    struct WithTrailer {
        let movieDetails: MovieDetails
        let trailerPath: String?
    }
    
    // CR: чи має модель займатись формуванням строки для view?
}
