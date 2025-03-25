//
//  Product.swift
//  anas_amer_assignment
//
//  Created by anas amer on 25/03/2025.
//

import Foundation
struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
    
    struct Rating: Codable {
        let rate: Double
        let count: Int
    }
}
