//
//  ProductsViewModel.swift
//  anas_amer_assignment
//
//  Created by anas amer on 25/03/2025.
//

import Foundation

class ProductsViewModel {
    var products: [Product] = []
    private var currentLimit = 7
    var isLoading = false
    private let networkService: NetworkServiceProtocol
    
    var onProductsUpdated: (() -> Void)?
    var onStateUpdate: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var numberOfProducts: Int {
        return products.count
    }
  

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
  
    
    func product(at index: Int) -> Product {
        return products[index]
    }
    
    func fetchProducts() {
        
        onStateUpdate?(true)
        networkService.fetchProducts(limit: currentLimit) { [weak self] result in
            guard let self = self else { return }
            onStateUpdate?(false)
            switch result {
            case .success(let newProducts):
                
                products.append(contentsOf: newProducts)
                currentLimit += 7
                self.onProductsUpdated?()
              
            case .failure(let error):
               
                let errorMessage: String
                switch error {
                case .noInternet:
                    errorMessage = "No internet connection. Showing cached data."
                default:
                    errorMessage = "Failed to load products. Please try again."
                }
                onError?(errorMessage)
            }
        }
    }
}
