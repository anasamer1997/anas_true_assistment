//
//  NetworkService.swift
//  anas_amer_assignment
//
//  Created by anas amer on 25/03/2025.
//

import UIKit
// Services/NetworkError.swift
enum NetworkError: Error {
    case invalidURL
    case noInternet
    case requestFailed(String)
    case decodingError
    case noData
}

// Services/NetworkServiceProtocol.swift
protocol NetworkServiceProtocol {
    func fetchProducts(limit: Int, completion: @escaping (Result<[Product], NetworkError>) -> Void)
}

// Services/NetworkService.swift
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private let baseURL = "https://fakestoreapi.com"
    private let cacheManager = CacheManager.shared
    
    func fetchProducts(limit: Int, completion: @escaping (Result<[Product], NetworkError>) -> Void) {
        let cacheKey = "products_\(limit)"
        
   
        // 2. Check internet connection
        guard NetworkMonitor.shared.isConnected else {
            // Try to find ANY cached products
            if let anyCachedProducts = cacheManager.loadAnyProducts() {
                completion(.success(anyCachedProducts))
            } else {
                completion(.failure(.noInternet))
            }
            return
        }
        
        // 3. Make network request
        let urlString = "\(baseURL)/products?limit=\(limit)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.requestFailed(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    // 4. Save to cache
                    self?.cacheManager.save(products: products, forKey: cacheKey)
                    completion(.success(products))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}
