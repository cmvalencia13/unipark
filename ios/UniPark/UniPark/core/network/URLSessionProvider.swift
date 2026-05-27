import Foundation

public enum HTTPMethod: String {
	case GET, POST, PATCH, DELETE
}

public final class NetworkClient {
	public static let shared = NetworkClient()

	/// Base URL leída de FeatureFlags — cambia backendBaseURL ahí para apuntar a staging/prod.
	public var baseURL: URL = URL(string: FeatureFlags.backendBaseURL)!

	private let session: URLSession
	private let decoder: JSONDecoder
	private let interceptor = NetworkInterceptor()

	private init(session: URLSession = .shared) {
		self.session = session
		self.decoder = JSONDecoder()
		self.decoder.keyDecodingStrategy = .convertFromSnakeCase
		self.decoder.dateDecodingStrategy = .iso8601
	}

	public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
		// build URL
		let rawPath = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
		guard let url = URL(string: rawPath, relativeTo: baseURL) else {
			throw NetworkError.clientError(400)
		}

		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue

		// default headers + interceptor
		interceptor.intercept(request: &request)

		// custom headers
		for (k, v) in endpoint.headers {
			request.setValue(v, forHTTPHeaderField: k)
		}

		// Authorization
		if let token = TokenStorage.shared.accessToken {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		// Body
		if let body = endpoint.body {
			do {
				let json = try JSONEncoder().encode(AnyEncodable(body))
				request.httpBody = json
			} catch {
				throw NetworkError.decodingError
			}
		}

		do {
			let (data, response) = try await session.data(for: request)

			guard let http = response as? HTTPURLResponse else {
				throw NetworkError.noConnection
			}

			switch http.statusCode {
			case 200...299:
				do {
					return try decoder.decode(T.self, from: data)
				} catch {
					throw NetworkError.decodingError
				}
			case 401:
				throw NetworkError.unauthorized
			case 429:
				throw NetworkError.rateLimited
			case 400...499:
				throw NetworkError.clientError(http.statusCode)
			case 500...599:
				throw NetworkError.serverError(http.statusCode)
			default:
				throw NetworkError.noConnection
			}
		} catch let urlError as URLError where urlError.code == .notConnectedToInternet {
			throw NetworkError.noConnection
		} catch {
			throw error
		}
	}
}

// Helper wrapper to encode Encodable existentials
fileprivate struct AnyEncodable: Encodable {
	private let _encode: (Encoder) throws -> Void

	init(_ wrapped: Encodable) {
		self._encode = { encoder in
			try wrapped.encode(to: encoder)
		}
	}

	func encode(to encoder: Encoder) throws {
		try _encode(encoder)
	}
}