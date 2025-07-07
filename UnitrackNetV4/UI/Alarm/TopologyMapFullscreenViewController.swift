import UIKit
import MapKit

private class EndpointAnnotation: MKPointAnnotation {
    let isOk: Bool
    init(coord: CLLocationCoordinate2D, isOk: Bool) {
        self.isOk = isOk
        super.init()
        coordinate = coord
        title      = nil          
    }
}

class TopologyMapFullscreenViewController: UIViewController {
    
    private let mapView = MKMapView()
    private let seg: SegmentUiModel
    
    init(segment: SegmentUiModel) {
        self.seg = segment
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .pageSheet
        isModalInPresentation  = false
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupMap()
        renderLink(seg)
    }
    
    private func setupMap() {
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled  = false
        
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.mapType  = .mutedStandard
        mapView.overrideUserInterfaceStyle = .dark
        view.addSubview(mapView)
        
        let hint = UILabel()
        hint.text = "Desliza hacia abajo para cerrar"
        hint.font = .systemFont(ofSize: 12)
        hint.textColor = .lightGray
        hint.textAlignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hint)
        NSLayoutConstraint.activate([
            hint.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            hint.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func renderLink(_ seg: SegmentUiModel) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        let origin = CLLocationCoordinate2D(latitude: seg.origenLat, longitude: seg.origenLng)
        let dest   = CLLocationCoordinate2D(latitude: seg.destinoLat,longitude: seg.destinoLng)
        let line = MKPolyline(coordinates: [origin, dest], count: 2)
        line.title = seg.estado.lowercased() != "ok" ? "error": (seg.tipo == .bgp ? "bgp" : "ospf")
        mapView.addOverlay(line)
        
        let isOk = seg.estado.lowercased() == "ok"
        mapView.addAnnotations([
            EndpointAnnotation(coord: origin, isOk: isOk),
            EndpointAnnotation(coord: dest,   isOk: isOk)
        ])
        let p1 = MKMapPoint(origin)
        let p2 = MKMapPoint(dest)
        let distance = p1.distance(to: p2)
        
        let minX = min(p1.x, p2.x)
        let maxX = max(p1.x, p2.x)
        let minY = min(p1.y, p2.y)
        let maxY = max(p1.y, p2.y)
        
        let rect = MKMapRect(x: minX, y: minY,width:  maxX - minX,height: maxY - minY)
        let edge: CGFloat
        switch distance {
        case 0..<500_000:         edge = 150
        case 500_000..<1_000_000: edge = 180
        default:                  edge = 220
        }
        
        mapView.setVisibleMapRect(rect,edgePadding: UIEdgeInsets(top: edge,left: edge,bottom: edge,right: edge),animated: false)
    }
}

extension TopologyMapFullscreenViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let poly = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let r = MKPolylineRenderer(polyline: poly)
        switch poly.title ?? "" {
        case "error": r.strokeColor = .red
        case "bgp":   r.strokeColor = .blue
        case "ospf":  r.strokeColor = .green
        default:      r.strokeColor = .gray
        }
        r.lineWidth = 3
        return r
    }
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let end = annotation as? EndpointAnnotation else { return nil }
        
        let id = "endpoint"
        let v = (mapView.dequeueReusableAnnotationView(withIdentifier: id)as? MKMarkerAnnotationView) ?? MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: id)
        v.annotation = annotation
        v.displayPriority = .required
        v.canShowCallout  = false
        v.glyphImage      = UIImage(systemName: "circle.fill")
        v.markerTintColor = end.isOk ? .systemGreen : .systemRed
        return v
    }
}
