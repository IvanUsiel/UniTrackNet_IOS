import UIKit
import BackgroundTasks
import UserNotifications

@main
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let bgRefreshTaskID = "mx.reduno.UnitrackNetV4.refresh"
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        requestNotificationPermission()
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: bgRefreshTaskID,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        scheduleAppRefresh()
        
        return true
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print(" Error pidiendo permiso de notificación: \(error)")
                } else {
                    print(granted ? " Permiso de notificación CONCEDIDO"
                          : " Permiso de notificación DENEGADO")
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: bgRefreshTaskID)
        print(" Intentando agendar tarea...")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print(" BGAppRefreshTask programada")
        } catch {
            print(" BGAppRefreshTask error al programar: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let fetchOp = AlarmFetchOperation()
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        fetchOp.completionBlock = {
            task.setTaskCompleted(success: !fetchOp.isCancelled)
        }
        
        queue.addOperation(fetchOp)
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration",
                             sessionRole: connectingSceneSession.role)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //AlarmCenter.shared.refresh()
    }
    
    
}
