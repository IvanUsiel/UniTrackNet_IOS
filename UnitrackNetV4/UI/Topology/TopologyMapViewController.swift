import UIKit
import MapKit

class CustomAnnotation: MKPointAnnotation {
    var ip:     String = ""
    var tipo:   String = ""
    var status: String = ""
}

class TopologyMapViewController: UIViewController {
    
    private let mapView     = MKMapView()
    private let ospfButton  = UIButton(type: .system)
    private let bgpButton   = UIButton(type: .system)
    
    private let summaryCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .vertical
        layout.minimumLineSpacing      = 12
        layout.minimumInteritemSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let headerView      = UIView()
    private let welcomeLabel    = UILabel()
    private let nameLabel       = UILabel()
    private let statusLabel     = UILabel()
    private let onlineDot       = UIView()
    private let teamIcon        = UIImageView()
    private let roleLabel       = UILabel()
    private let ospfDateLabel   = UILabel()
    private let bgpDateLabel    = UILabel()
    private let refreshButton   = UIButton(type: .system)
    private let viewModel = TopologyViewModel()
    private var allSegments: [SegmentUiModel]   = []
    private var segmentSummaries: [SegmentSummary] = []
    var selectedSegment: String? = nil
    private var showOSPF = true
    private var showBGP  = true
    private var isReloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //title = "Red Mapa"
        view.backgroundColor = .black
        
        setupHeader()
        setupMapAndGrid()
        setupFilterButtons()
        bindViewModel()
        
        LoadingOverlay.shared.show(over: view)
        viewModel.fetchData()
        populateStaticHeaderInfo()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .black
        headerView.layer.cornerRadius = 28
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView.clipsToBounds = true
        view.addSubview(headerView)
        
        [welcomeLabel, nameLabel, statusLabel, roleLabel,
         ospfDateLabel, bgpDateLabel].forEach { lbl in
            lbl.textColor = .white
            lbl.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(lbl)
        }
        
        welcomeLabel.font = .systemFont(ofSize: 14)
        welcomeLabel.text = "Bienvenido"
        
        nameLabel.font = .boldSystemFont(ofSize: 20)
        
        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.text = "Online"
        
        roleLabel.font = .systemFont(ofSize: 13)
        
        ospfDateLabel.font = .systemFont(ofSize: 13)
        bgpDateLabel.font  = .systemFont(ofSize: 13)
        
        onlineDot.backgroundColor = .systemGreen
        onlineDot.layer.cornerRadius = 4
        onlineDot.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(onlineDot)
        
        teamIcon.image = UIImage(systemName: "person.3.fill")
        teamIcon.tintColor = .white
        teamIcon.contentMode = .scaleAspectFit
        teamIcon.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(teamIcon)
        
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        refreshButton.tintColor = UIColor(named: "UnitrackGreen") ?? .systemGreen
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.contentHorizontalAlignment = .fill
        refreshButton.contentVerticalAlignment   = .fill
        refreshButton.addTarget(self,action: #selector(refreshMapData),for: .touchUpInside)
        headerView.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),
            
            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            
            nameLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            
            onlineDot.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            onlineDot.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            onlineDot.widthAnchor.constraint(equalToConstant: 8),
            onlineDot.heightAnchor.constraint(equalToConstant: 8),
            
            statusLabel.centerYAnchor.constraint(equalTo: onlineDot.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: onlineDot.trailingAnchor, constant: 6),
            
            teamIcon.topAnchor.constraint(equalTo: onlineDot.bottomAnchor, constant: 8),
            teamIcon.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            teamIcon.widthAnchor.constraint(equalToConstant: 18),
            teamIcon.heightAnchor.constraint(equalToConstant: 18),
            
            roleLabel.centerYAnchor.constraint(equalTo: teamIcon.centerYAnchor),
            roleLabel.leadingAnchor.constraint(equalTo: teamIcon.trailingAnchor, constant: 6),
            
            ospfDateLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            ospfDateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            
            bgpDateLabel.topAnchor.constraint(equalTo: ospfDateLabel.bottomAnchor, constant: 4),
            bgpDateLabel.trailingAnchor.constraint(equalTo: ospfDateLabel.trailingAnchor),
            
            refreshButton.topAnchor.constraint(equalTo: bgpDateLabel.bottomAnchor, constant: 8),
            refreshButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -6),
            refreshButton.widthAnchor.constraint(equalToConstant: 35),
            refreshButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func setupMapAndGrid() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.mapType  = .mutedStandard
        mapView.overrideUserInterfaceStyle = .dark
        view.addSubview(mapView)
        
        summaryCollection.translatesAutoresizingMaskIntoConstraints = false
        summaryCollection.backgroundColor = .clear
        summaryCollection.dataSource = self
        summaryCollection.delegate   = self
        summaryCollection.register(SegmentCardCell.self,
                                   forCellWithReuseIdentifier: SegmentCardCell.reuseID)
        view.addSubview(summaryCollection)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            summaryCollection.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            summaryCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            summaryCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            summaryCollection.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupFilterButtons() {
        configureFilter(button: ospfButton,
                        title: "OSPF",
                        border: .systemGreen,
                        selector: #selector(toggleOSPF))
        configureFilter(button: bgpButton,
                        title: "BGP",
                        border: .systemBlue,
                        selector: #selector(toggleBGP))
        
        NSLayoutConstraint.activate([
            ospfButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            ospfButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ospfButton.widthAnchor.constraint(equalToConstant: 70),
            ospfButton.heightAnchor.constraint(equalToConstant: 36),
            
            bgpButton.bottomAnchor.constraint(equalTo: ospfButton.bottomAnchor),
            bgpButton.leadingAnchor.constraint(equalTo: ospfButton.trailingAnchor, constant: 10),
            bgpButton.widthAnchor.constraint(equalTo: ospfButton.widthAnchor),
            bgpButton.heightAnchor.constraint(equalTo: ospfButton.heightAnchor)
        ])
    }
    
    private func configureFilter(button: UIButton,
                                 title: String,
                                 border: UIColor,
                                 selector: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        button.layer.borderWidth  = 2
        button.layer.borderColor  = border.cgColor
        button.titleLabel?.font   = .systemFont(ofSize: 14, weight: .bold)
        button.alpha = 1
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
    }
    
    @objc private func refreshMapData() {
        guard !isReloading else { return }
        isReloading = true
        refreshButton.isEnabled = false
        refreshButton.alpha = 0.3
        LoadingOverlay.shared.show(over: view)
        viewModel.fetchData()
    }
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] segments in
            guard let self = self else { return }
            self.allSegments = segments
            self.refreshSummaries(from: segments)
            self.applyFilterAndRender()
            self.updateHeaderDates()
            
            self.isReloading = false
            self.refreshButton.isEnabled = true
            self.refreshButton.alpha = 1.0
            LoadingOverlay.shared.hide()
        }
    }
    
    private func populateStaticHeaderInfo() {
        if let p = UserProfileStorage.load() {
            nameLabel.text = p.fullname
            roleLabel.text = p.role
        }
    }
    
    private func updateHeaderDates() {
        if let ts = viewModel.ospfTimestamp {
            ospfDateLabel.text = "OSPF: \(ts.friendlyDateES())"
        }
        if let ts = viewModel.bgpTimestamp {
            bgpDateLabel.text  = "BGP: \(ts.friendlyDateES())"
        }
    }
    
    @objc private func toggleOSPF() {
        showOSPF.toggle()
        ospfButton.alpha = showOSPF ? 1.0 : 0.4
        applyFilterAndRender()
    }
    
    @objc private func toggleBGP() {
        showBGP.toggle()
        bgpButton.alpha = showBGP ? 1.0 : 0.4
        applyFilterAndRender()
    }
    
    private func currentFilteredSegments() -> [SegmentUiModel] {
        allSegments.filter {
            ($0.tipo == .ospf && showOSPF) || ($0.tipo == .bgp && showBGP)
        }
    }
    
    private func applyFilterAndRender() {
        let protoFiltered = currentFilteredSegments()
        let finalList: [SegmentUiModel] = {
            guard let seg = selectedSegment else { return protoFiltered }
            return protoFiltered.filter { $0.segmento == seg }
        }()
        renderSegments(finalList)
        refreshSummaries(from: protoFiltered)
    }
    
    private func renderSegments(_ segments: [SegmentUiModel]) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        for seg in segments {
            let o = CLLocationCoordinate2D(latitude: seg.origenLat,  longitude: seg.origenLng)
            let d = CLLocationCoordinate2D(latitude: seg.destinoLat, longitude: seg.destinoLng)
            
            let line = MKPolyline(coordinates: [o, d], count: 2)
            line.title = seg.estado.lowercased() != "ok" ? "error" :
            (seg.tipo == .bgp ? "bgp" : "ospf")
            mapView.addOverlay(line)
            
            mapView.addAnnotation(createAnnotation(hostname: seg.origen,
                                                   ip:       seg.origenIP,
                                                   coord:    o,
                                                   tipo:     seg.tipo,
                                                   status:   seg.estado))
            mapView.addAnnotation(createAnnotation(hostname: seg.destino,
                                                   ip:       seg.destinoIP,
                                                   coord:    d,
                                                   tipo:     seg.tipo,
                                                   status:   seg.estado))
        }
        
        guard !segments.isEmpty else { return }
        
        let coords = segments.flatMap {
            [CLLocationCoordinate2D(latitude: $0.origenLat, longitude: $0.origenLng),
             CLLocationCoordinate2D(latitude: $0.destinoLat, longitude: $0.destinoLng)]
        }
        var rect = MKMapRect.null
        coords.map { MKMapPoint($0) }
            .forEach { rect = rect.union(MKMapRect(origin: $0, size: .init(width: 0, height: 0))) }
        
        view.layoutIfNeeded()
        let topPadding    = headerView.frame.maxY + 80
        let bottomPadding = view.safeAreaInsets.bottom + 80
        
        let insets = UIEdgeInsets(top: topPadding,left: 40,bottom: bottomPadding,right: 40)
        
        mapView.setVisibleMapRect(rect,edgePadding: insets,animated: true)
        
    }
    
    private func createAnnotation(hostname: String,
                                  ip: String,
                                  coord: CLLocationCoordinate2D,
                                  tipo: SegmentoTipo,
                                  status: String) -> CustomAnnotation {
        let ann = CustomAnnotation()
        ann.coordinate = coord
        ann.title      = hostname
        ann.subtitle   = "IP: \(ip)\nTipo: \(tipo == .bgp ? "BGP" : "OSPF")"
        ann.ip         = ip
        ann.tipo       = tipo == .bgp ? "BGP" : "OSPF"
        ann.status     = status
        return ann
    }
    
    private func refreshSummaries(from segs: [SegmentUiModel]) {
        segmentSummaries = Dictionary(grouping: segs, by: \.segmento).map { name, items in
            let enlaces  = items.count
            let hasError = items.contains { $0.estado.lowercased() != "ok" }
            let tiposSet = Set(items.map(\.tipo))
            return SegmentSummary(nombre: name,
                                  enlaces: enlaces,
                                  estado: hasError ? "error" : "ok",
                                  tipo:   tiposSet.count == 1 ? tiposSet.first : nil)
        }.sorted { $0.nombre < $1.nombre }
        
        summaryCollection.reloadData()
    }
}

extension TopologyMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let line = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let r = MKPolylineRenderer(polyline: line)
        switch line.title ?? "" {
        case "error": r.strokeColor = .red
        case "bgp":   r.strokeColor = .blue
        case "ospf":  r.strokeColor = .green
        default:      r.strokeColor = .gray
        }
        r.lineWidth = 3
        return r
        
    }
    
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let ann = annotation as? CustomAnnotation else { return nil }
        let id = "routerMarker"
        let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id)as? MKMarkerAnnotationView) ?? MKMarkerAnnotationView(annotation: ann,reuseIdentifier: id)
        view.annotation = ann
        view.canShowCallout = true
        view.glyphImage     = UIImage(systemName: "network")
        view.markerTintColor = ann.status.lowercased() == "ok" ? .systemGreen : .systemRed
        view.clusteringIdentifier = nil
        
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        let telnetBtn = UIButton(type: .contactAdd)
        telnetBtn.tintColor = .systemTeal
        view.leftCalloutAccessoryView = telnetBtn
        return view
        
    }
    
    func mapView(_ mapView: MKMapView,annotationView view: MKAnnotationView,calloutAccessoryControlTapped ctrl: UIControl) {
        
        guard let ann = view.annotation as? CustomAnnotation else { return }
        
        if ctrl == view.leftCalloutAccessoryView {
            let info = RouterInfo(nombre: ann.title ?? "-", ip: ann.ip)
            let vc = TelnetConsoleViewController()
            vc.modalPresentationStyle = .formSheet
            vc.origen  = info
            vc.destino = info
            vc.tipo    = ann.tipo.lowercased() == "bgp" ? .bgp : .ospf
            present(vc, animated: true);  return
        }
        
        if ctrl == view.rightCalloutAccessoryView {
            let msg = """
            Hostname: \(ann.title ?? "-")
            IP: \(ann.ip)
            Tipo: \(ann.tipo)
            Estatus: \(ann.status.uppercased())
            """
            let alert = UIAlertController(title: "Detalles del nodo",
                                          message: msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

extension TopologyMapViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ cv: UICollectionView,numberOfItemsInSection section: Int) -> Int { segmentSummaries.count }
    
    func collectionView(_ cv: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: SegmentCardCell.reuseID,
                                          for: indexPath) as! SegmentCardCell
        cell.configure(with: segmentSummaries[indexPath.item])
        return cell
    }
    
    func collectionView(_ cv: UICollectionView,layout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 12 * 4
        let width = (cv.bounds.width - totalSpacing) / 3
        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ cv: UICollectionView,didSelectItemAt indexPath: IndexPath) {
        
        let name = segmentSummaries[indexPath.item].nombre
        selectedSegment = (selectedSegment == name) ? nil : name
        applyFilterAndRender()
        if let seg = selectedSegment { zoomToSegment(named: seg) }
        cv.reloadData()
    }
    
    private func zoomToSegment(named seg: String) {
        let segs = currentFilteredSegments().filter { $0.segmento == seg }
        guard !segs.isEmpty else { return }
        
        let coords = segs.flatMap {
            [CLLocationCoordinate2D(latitude: $0.origenLat, longitude: $0.origenLng),
             CLLocationCoordinate2D(latitude: $0.destinoLat, longitude: $0.destinoLng)]
        }
        var rect = MKMapRect.null
        coords.map { MKMapPoint($0) }
            .forEach { rect = rect.union(MKMapRect(origin: $0, size: .init(width: 0, height: 0))) }
        
        mapView.setVisibleMapRect(rect,edgePadding: .init(top: 280, left: 40, bottom: 40, right: 40),animated: true)
    }
}
