import UIKit

class TopologyViewController: UIViewController {
    
    private let tableView  = UITableView()
    private let searchBar  = UISearchBar()
    private let headerCard = HeaderCardView()
    private let refreshControl = UIRefreshControl()
    private let viewModel  = TopologyViewModel()
    private var segments:     [SegmentUiModel] = []
    private var allSegments:  [SegmentUiModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = .black
        view.insertSubview(backgroundView, at: 0)
        setupUI()
        bindViewModel()
        
        LoadingOverlay.shared.show(over: view)
        viewModel.fetchData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAlarms(_:)),
            name: .alarmsUpdated,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderLayout()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        refreshControl.tintColor = UIColor(named: "UnitrackGreen") ?? .systemGreen
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        tableView.backgroundColor = .black
        tableView.separatorStyle  = .none
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.refreshControl  = refreshControl
        tableView.register(SegmentCell.self, forCellReuseIdentifier: "SegmentCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        searchBar.placeholder = "Buscar segmento, host o IP"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Buscar segmento, host o IP",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        searchBar.delegate = self
        
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [headerCard, searchBar])
        stack.axis = .vertical
        stack.spacing = 16
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 20, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(stack)
        container.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        tableView.tableHeaderView = container
        updateHeaderLayout()
    }
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] all in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            LoadingOverlay.shared.hide()
            
            self.allSegments = all
            self.applyCurrentFilter(self.searchBar.text ?? "")
            
            let poleo = """
            Último poleo BGP: \(self.viewModel.bgpTimestamp ?? "--")
            Último poleo OSPF: \(self.viewModel.ospfTimestamp ?? "--")
            """
            
            let healthy = self.segments.allSatisfy { $0.estado.lowercased() == "ok" }
            self.headerCard.configure(
                title: healthy ? "Red Estable" : "Problemas Detectados",
                poleoText: poleo,
                isHealthy: healthy
            )
            
            let errorCount = self.segments.filter { $0.estado.lowercased() != "ok" }.count
            NotificationCenter.default.post(
                name: .alarmsUpdated,
                object: nil,
                userInfo: ["count": errorCount]
            )
        }
        
        viewModel.onError = { [weak self] msg in
            self?.refreshControl.endRefreshing()
            LoadingOverlay.shared.hide()
            self?.showAlert("Error: \(msg)")
        }
    }
    
    @objc private func handleRefresh() {
        viewModel.fetchData()
        LoadingOverlay.shared.show(over: view)
        AlarmCenter.shared.refresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func applyCurrentFilter(_ search: String) {
        let filtered = allSegments.filter {
            search.isEmpty ||
            $0.segmento.localizedCaseInsensitiveContains(search) ||
            $0.origen.localizedCaseInsensitiveContains(search)   ||
            $0.destino.localizedCaseInsensitiveContains(search)  ||
            $0.origenIP.contains(search) ||
            $0.destinoIP.contains(search)
        }
        
        segments = filtered.sorted {
            let aErr = $0.estado.lowercased() != "ok"
            let bErr = $1.estado.lowercased() != "ok"
            if aErr != bErr { return aErr }
            return $0.segmento < $1.segmento
        }
        tableView.reloadData()
    }
    
    private func updateHeaderLayout() {
        guard let header = tableView.tableHeaderView else { return }
        header.layoutIfNeeded()
        let size = header.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width,
                   height: UIView.layoutFittingCompressedSize.height)
        )
        if header.frame.height != size.height {
            header.frame.size.height = size.height
            tableView.tableHeaderView = header
        }
    }
    
    @objc private func handleAlarms(_ n: Notification) {
        guard let segs = n.userInfo?["segments"] as? [SegmentUiModel] else { return }
        allSegments = segs
        applyCurrentFilter(searchBar.text ?? "")
    }
    
    private func presentTelnetConsole(for seg: SegmentUiModel) {
        let vc = TelnetConsoleViewController()
        vc.origen  = RouterInfo(nombre: seg.origen,  ip: seg.origenIP)
        vc.destino = RouterInfo(nombre: seg.destino, ip: seg.destinoIP)
        vc.tipo    = seg.tipo
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPingGraph(for seg: SegmentUiModel) {
        
        let origen  = RouterInfoPing(nombre: seg.origen,  ip: seg.origenIP)
        let destino = RouterInfoPing(nombre: seg.destino, ip: seg.destinoIP)
        
        let graphVC = PingGraphViewController(origen:  origen,
                                              destino: destino)
        graphVC.modalPresentationStyle = .formSheet   // ó .overFullScreen si lo prefieres
        present(graphVC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension TopologyViewController: UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { segments.count }
    
    func tableView(_ tv: UITableView, cellForRowAt idx: IndexPath) -> UITableViewCell {
        let seg = segments[idx.row]
        let cell = tv.dequeueReusableCell(withIdentifier: "SegmentCell", for: idx) as! SegmentCell
        cell.configure(with: seg)
        return cell
    }
}

extension TopologyViewController: UITableViewDelegate {
    
    func tableView(_ tv: UITableView,
                   trailingSwipeActionsConfigurationForRowAt idx: IndexPath)-> UISwipeActionsConfiguration? {
        
        let seg = segments[idx.row]
        let telnet = UIContextualAction(style: .normal, title: "Telnet") { _, _, done in
            self.presentTelnetConsole(for: seg)
            done(true)
        }
        telnet.backgroundColor = .systemTeal
        telnet.image = UIImage(systemName: "waveform.path.ecg")
        
        return UISwipeActionsConfiguration(actions: [telnet])
        
    }
    
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let seg = segments[indexPath.row]
        let vc  = TopologyMapFullscreenViewController(segment: seg)
        present(vc, animated: true)
    }
    
    func tableView(_ tv: UITableView,
                   leadingSwipeActionsConfigurationForRowAt idx: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let seg = segments[idx.row]
        
        let ping = UIContextualAction(style: .normal, title: "Ping") { _, _, done in
            self.presentPingGraph(for: seg)
            done(true)
        }
        ping.backgroundColor = .systemGreen
        ping.image = UIImage(systemName: "waveform.path.ecg")
        
        return UISwipeActionsConfiguration(actions: [ping])
    }
}

extension TopologyViewController: UISearchBarDelegate {
    func searchBar(_ sb: UISearchBar, textDidChange txt: String) {
        applyCurrentFilter(txt)
    }
}
