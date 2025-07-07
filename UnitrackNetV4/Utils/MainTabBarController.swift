import UIKit
import BackgroundTasks

class MainTabBarController: UITabBarController {
    
    private let refreshTaskId   = "mx.reduno.UnitrackNetV4.refresh"
    private let alarmTabIndex   = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupTabs()
        configureTabBarAppearance()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBadge(_:)),
            name: .alarmsUpdated,
            object: nil)
        
        AlarmCenter.shared.refresh()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTabs() {
        
        let map = UINavigationController(rootViewController: TopologyMapViewController())
        map.tabBarItem = UITabBarItem(title: "Mapa",
                                      image: UIImage(systemName: "map"),
                                      selectedImage: UIImage(systemName: "map.fill"))
        
        let alarms = UINavigationController(rootViewController: TopologyViewController())
        alarms.tabBarItem = UITabBarItem(title: "Alarmas",
                                         image: UIImage(systemName: "bell"),
                                         selectedImage: UIImage(systemName: "bell.fill"))
        
        let about = UINavigationController(rootViewController: ProfileViewController())
        about.tabBarItem = UITabBarItem(title: "Perfil",
                                        image: UIImage(systemName: "person"),
                                        selectedImage: UIImage(systemName: "person.fill"))
        
        viewControllers = [map, alarms, about]
        selectedIndex   = 0
    }
    
    // MARK: – Apariencia
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor  = .black
        appearance.backgroundEffect = nil
        
        let green = UIColor(named: "UnitrackGreen") ?? .systemGreen
        appearance.stackedLayoutAppearance.selected.iconColor  = green
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor : green
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBadge(_:)),
                                               name: .alarmsUpdated,
                                               object: nil)
    }
    
    @objc private func updateBadge(_ note: Notification) {
        guard let count = note.userInfo?["count"] as? Int,
              let alarmTab = viewControllers?[safe: alarmTabIndex] else { return }
        
        if let alarmNav = viewControllers?[1] as? UINavigationController,
           let alarmVC = alarmNav.viewControllers.first as? TopologyViewController {
            _ = alarmVC.view
        }
        
        alarmTab.tabBarItem.badgeValue = count == 0 ? nil : "\(count)"
        
        let baseName = count == 0 ? "bell" : "bell.badge"
        alarmTab.tabBarItem.image         = UIImage(systemName: baseName)
        alarmTab.tabBarItem.selectedImage = UIImage(systemName: "\(baseName).fill")
    }
}

private extension Array {
    subscript(safe idx: Index) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}


