//
//  API.swift
//  mysic
//
//  Created by mac on 23/06/23.
//

import Foundation


struct MysicAPI {
    
    static var shared = MysicAPI()
    private var uri = "http://192.168.18.14:3000/api/v1";
    private init() {}
    
    private let session = URLSession.shared
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetch(from category: Category, params: QueryParams?) async throws -> Fetched {
        try await fetchDefault(from: generatedDefaultURL(from: category, params: params))
    }
    
    func search(from category: Category, params: QueryParams?) async throws -> APIResponse {
        try await fetchSearch(from: generatedDefaultURL(from: category, params: params))
    }
    
    func next(from category: Category, params: QueryParams?) async throws -> DatumContent {
        try await fetchNext(from: generatedDefaultURL(from: category, params: params))
    }
    
    func play(from category: Category, params: QueryParams?) async throws -> Player {
        try await fetchPlay(from: generatedDefaultURL(from: category, params: params))
    }
    
    private func fetchDefault(from url: URL) async throws -> Fetched {
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw generateError(description: "Bad Response")
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let apiResponse = try jsonDecoder.decode(Fetched.self, from: data)
            return apiResponse
        default:
            throw generateError(description: "A server error occured")
        }
    }
    
    private func fetchSearch(from url: URL) async throws -> APIResponse {
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw generateError(description: "Bad Response")
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let apiResponse = try jsonDecoder.decode(APIResponse.self, from: data)
            return apiResponse
        default:
            throw generateError(description: "A server error occured")
        }
    }
    
    private func fetchNext(from url: URL) async throws -> DatumContent {
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw generateError(description: "Bad Response")
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let apiResponse = try jsonDecoder.decode(DatumContent.self, from: data)
            return apiResponse
        default:
            throw generateError(description: "A server error occured")
        }
    }
    
    private func fetchPlay(from url: URL) async throws -> Player {
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw generateError(description: "Bad Response")
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let apiResponse = try jsonDecoder.decode(Player.self, from: data)
            return apiResponse
        default:
            throw generateError(description: "A server error occured")
        }
    }
    
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "NewsAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    private func generatedDefaultURL(from category: Category, params: QueryParams?) -> URL {
        var component = URLComponents(url: URL(string: "\(uri)/\(category.text)")!, resolvingAgainstBaseURL: true)
        if params != nil {
            component?.queryItems = params!.transformMap().map{k,v in URLQueryItem(name: k, value: v)}
        }
        
        return URL(string: component!.string!)!
    }
}

