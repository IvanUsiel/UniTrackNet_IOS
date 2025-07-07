import Foundation
import UserNotifications

class AlarmFetchOperation: Operation, @unchecked Sendable {
    
    private(set) var alarmCount: Int          = 0
    private(set) var segments:   [SegmentUiModel] = []
    
    override func main() {
        if isCancelled { return }
        
        let repo   = TopologyRepository()
        let sema   = DispatchSemaphore(value: 0)
        
        repo.fetchAll { [weak self] (result: Result<TopologyResult,Error>) in
            defer { sema.signal() }
            guard let self = self else { return }
            
            if case .success(let topo) = result {
                self.segments   = topo.segments
                self.alarmCount = topo.segments.filter { $0.estado.lowercased() != "ok" }.count
            }
        }
        
        sema.wait()
        
        if isCancelled { return }
        
        NotificationCenter.default.post(
            name: .alarmsUpdated,
            object: nil,
            userInfo: ["count": alarmCount,
                       "segmentos": segments]
        )
        
        guard alarmCount > 0 else { return }
        let content      = UNMutableNotificationContent()
        content.title    = "🚨 Alarmas de red"
        content.body     = "Se detectaron \(alarmCount) trayectorias con error."
        content.sound    = .default
        content.badge    = NSNumber(value: alarmCount)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil)                        // inmediata
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("No se pudo mostrar notificación: \(error)")
            }
        }
    }
}
