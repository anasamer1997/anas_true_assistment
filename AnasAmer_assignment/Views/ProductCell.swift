//
//  ProductCell.swift
//  anas_amer_assignment
//
//  Created by anas amer on 25/03/2025.
//

import Foundation
import UIKit

class ProductGridCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductGridCell"
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var categoryLabel:UILabel!
   
    override func awakeFromNib() {
          super.awakeFromNib()
          setupViews()
      }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
      
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.borderWidth = 2
        
        layer.borderColor = UIColor.black.cgColor
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = String(format: "$%.2f", product.price)
        categoryLabel.text = product.category.capitalized
    
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.numberOfLines = 0
        
        priceLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        priceLabel.textColor = .systemGreen
        
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        categoryLabel.textColor =  .systemGray
        // Load image (in a real app, you'd want to cache this)
        if let url = URL(string: product.image) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }.resume()
        }
    }
}

class ProductRowCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductRowCell"

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
          super.awakeFromNib()
          setupViews()
      }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = String(format: "$%.2f", product.price)
        categoryLabel.text = product.category.capitalized
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        
        priceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        priceLabel.textColor = .systemGreen
        
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        categoryLabel.textColor =  .systemGray
        // Load image (in a real app, you'd want to cache this)
        if let url = URL(string: product.image) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }.resume()
        }
    }
}
