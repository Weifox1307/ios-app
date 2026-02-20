import Foundation

enum AuthEndpoint {
    case login
    case getProfile
    case getStats
    case getLocations
    case register
    
    var path: String {
        switch self {
        case .login: return "api/v1/account/login"
        case .getProfile: return "api/v1/account/athlete/get"
        case .getStats: return "api/v1/website/athlete/statById"
        case .getLocations: return "api/v1/account/event/list"
        case .register: return "api/v1/account/register"
        }
    }
}

class AuthService {
    private let baseURL = "https://my.5verst.ru/"
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        return try await performPost(endpoint: .login, body: request)
    }
    
    func getAthleteProfile() async throws -> AthleteProfileResponse {
        return try await performPost(endpoint: .getProfile, body: EmptyRequest()) 
    }
    
    func getAthleteStats(request: AthleteIdRequest) async throws -> StatsResponse {
        return try await performPost(endpoint: .getStats, body: request)
    }

    func getLocations() async throws -> LocationResponse {
        return try await performPost(endpoint: .getLocations, body: EmptyRequest())
    }

    private func performPost<T: Decodable, B: Encodable>(endpoint: AuthEndpoint, body: B) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
      
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

// Заглушка для пустого тела, если API требует {}
struct EmptyRequest: Encodable {}
