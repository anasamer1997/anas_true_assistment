import UIKit
import SwiftUI

enum LayoutStyle {
    case grid
    case list
}

class ProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var layoutStyle: LayoutStyle = .list
    private var layoutButton: UIBarButtonItem!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    private var viewModel = ProductsViewModel()
    private let networkMonitor = NetworkMonitor.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkMonitoring()
        setupUI()
        initProductList()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Products"
        
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Setup layout toggle button
        layoutButton = UIBarButtonItem(
            image: UIImage(systemName: "square.grid.2x2"),
            style: .plain,
            target: self,
            action: #selector(toggleLayout)
        )
        navigationItem.rightBarButtonItem = layoutButton
        
        
    }
    private func setupNetworkMonitoring() {
        // Start monitoring network changes
        networkMonitor.startMonitoring()
        
        // Observe network status changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .networkStatusChanged,
            object: nil
        )
    }
    @objc private func networkStatusChanged(_ notification: Notification) {
        guard let isConnected = notification.userInfo?["isConnected"] as? Bool else { return }
        
        if isConnected {
            // Network came back online - refresh data
            viewModel.fetchProducts()
        } else {
            viewModel.fetchProducts()
//            // Network went offline - show cached data with alert
//            let alert = UIAlertController(
//                title: "Offline Mode",
//                message: "You're offline.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
        }
    }
    
    
    private func initProductList() {
        viewModel.onStateUpdate = {[weak self] value in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if value {
                    self.loadingIndicator.isHidden = false
                    self.loadingIndicator.startAnimating()
                } else{
                    self.loadingIndicator.isHidden = true
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.onProductsUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        
    }

    @objc private func toggleLayout() {
        layoutStyle = layoutStyle == .list ? .grid : .list
        let buttonImage = layoutStyle == .list ? UIImage(systemName: "square.grid.2x2") : UIImage(systemName: "list.bullet")
        layoutButton.image = buttonImage
        
        UIView.transition(with: collectionView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        },
                          completion: nil)
    }
    deinit {
        // Clean up observers
        NotificationCenter.default.removeObserver(self)
        networkMonitor.stopMonitoring()
    }
}

extension ProductsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCollectionViewCell
        
        let product = viewModel.product(at: indexPath.item)
        cell.configure(with: product, style: layoutStyle)
        
        return cell

    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewSize = collectionView.frame.size.width - padding * 2
        
        switch layoutStyle {
        case .grid:
            let itemWidth = (collectionViewSize - padding) / 2
            return CGSize(width: itemWidth, height: itemWidth + 80) // Adjust height as needed
        case .list:
            return CGSize(width: collectionViewSize, height: 100) // Adjust height as needed
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 16
     }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfProducts - 1 {
            loadingIndicator.startAnimating()
            viewModel.fetchProducts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.product(at: indexPath.item)
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


class ProductCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCollectionViewCell"
    
    private var hostingController: UIHostingController<AnyView>?
    
    func configure(with product: Product, style: LayoutStyle) {
        // Remove any existing hosting controller
        hostingController?.view.removeFromSuperview()
        
        // Create the appropriate SwiftUI view based on style
        let rootView: AnyView
        switch style {
        case .grid:
            rootView = AnyView(ProductGridCell(product: product))
        case .list:
            rootView = AnyView(ProductListCell(product: product))
        }
        
        // Create and configure the hosting controller
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        
        // Add the hosting controller's view to the cell
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        self.hostingController = hostingController
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
}
