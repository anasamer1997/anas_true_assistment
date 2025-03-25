import UIKit

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
        collectionView.collectionViewLayout = createLayout(layout: layoutStyle)
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
    
    func createLayout(layout :LayoutStyle) -> UICollectionViewCompositionalLayout {
        if layout == .list{
            return createPlitesMainCVLayout()
            
        }else{
            return createProductCVLayout()
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
    private func createPlitesMainCVLayout() -> UICollectionViewCompositionalLayout {
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1),spacing: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        let Group = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(1), height: .absolute(160), item: item, count: 1)
        let section = CompositionalLayout.craeteSection(group: Group, scrollingBehavor: .none, groupSpcaing: 10, contentPaddint: NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    private func createProductCVLayout() -> UICollectionViewCompositionalLayout {
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1),spacing: NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        let Group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .absolute(200), item: item, count: 2)
        let section = CompositionalLayout.craeteSection(group: Group, scrollingBehavor: .none, groupSpcaing: 15, contentPaddint: NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc private func toggleLayout() {
        layoutStyle = layoutStyle == .list ? .grid : .list
        let buttonImage = layoutStyle == .list ? UIImage(systemName: "square.grid.2x2") : UIImage(systemName: "list.bullet")
        layoutButton.image = buttonImage
        collectionView.setCollectionViewLayout(createLayout(layout: layoutStyle), animated: true)
        
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
        if layoutStyle == .list {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductRowCell.reuseIdentifier,
                for: indexPath
            ) as? ProductRowCell else {
                return UICollectionViewCell()
            }
            
            let product = viewModel.products[indexPath.item]
            cell.configure(with: product)
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductGridCell.reuseIdentifier,
                for: indexPath
            ) as? ProductGridCell else {
                return UICollectionViewCell()
            }
            let product = viewModel.products[indexPath.item]
            cell.configure(with: product)
            return cell
        }
    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    
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
