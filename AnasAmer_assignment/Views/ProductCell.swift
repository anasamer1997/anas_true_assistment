//
//  ProductCell.swift
//  anas_amer_assignment
//
//  Created by anas amer on 25/03/2025.
//

import Foundation
import SwiftUI

// ProductGridCell.swift
struct ProductGridCell: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 150, height: 150)
            .cornerRadius(8)
            .clipped()
            
            Text(product.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(product.description)
                .font(.subheadline)
                .lineLimit(1)
            
            Text("price: $\(product.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// ProductListCell.swift
struct ProductListCell: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: product.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(product.description)
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text("price: $\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
              
                
             
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
