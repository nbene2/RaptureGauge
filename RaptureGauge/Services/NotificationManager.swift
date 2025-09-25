import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {
        requestNotificationPermission()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func sendCriticalAlert(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }

    func scheduleWindowShiftNotification() {
        // Schedule daily check for window shift
        let content = UNMutableNotificationContent()
        content.title = "Window Shift Update"
        content.body = "The 100-year window has shifted. Check for changes in readiness."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "windowShift", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func notifyConditionChange(condition: RaptureCondition, changeType: String) {
        let title = "Condition \(changeType)"
        let body = "\(condition.scriptureReference): \(condition.scriptureQuote)"
        sendCriticalAlert(title: title, body: body)
    }

    func notifyReadinessThreshold(percentage: Float) {
        if percentage > 90 {
            sendCriticalAlert(
                title: "Critical Readiness Level",
                body: "Rapture readiness has reached \(Int(percentage))% - highest level recorded!"
            )
        } else if percentage > 85 {
            sendCriticalAlert(
                title: "High Alert",
                body: "Readiness at \(Int(percentage))% - approaching critical convergence"
            )
        }
    }
}

class ConditionMonitor: ObservableObject {
    @Published var lastChecked = Date()
    @Published var monitoringActive = true

    private let calculator: RaptureCalculator
    private let notificationManager = NotificationManager.shared
    private var timer: Timer?

    init(calculator: RaptureCalculator) {
        self.calculator = calculator
        startMonitoring()
    }

    func startMonitoring() {
        // Check every hour for changes
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.checkForChanges()
        }

        // Also check daily for window shift
        checkWindowShift()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        monitoringActive = false
    }

    func checkForChanges() {
        lastChecked = Date()

        // Check for threshold changes
        let currentScore = calculator.currentScore.percentage

        if currentScore > 90 {
            notificationManager.notifyReadinessThreshold(percentage: currentScore)
        }

        // Check for rapid acceleration
        if calculator.currentScore.acceleration > 3 {
            notificationManager.sendCriticalAlert(
                title: "Rapid Acceleration Detected",
                body: "Readiness increasing at \(String(format: "%.1f", calculator.currentScore.acceleration))% per year"
            )
        }
    }

    func checkWindowShift() {
        let calendar = Calendar.current
        let today = Date()
        let windowStart = calendar.date(byAdding: .year, value: -100, to: today)!

        // Check if any conditions are about to expire from window
        let conditions = ConditionData.shared.getAllConditions()
        for condition in conditions {
            if let fulfillmentDate = condition.fulfillmentDate {
                let daysUntilExpiry = calendar.dateComponents([.day], from: today, to: fulfillmentDate).day ?? 0

                if daysUntilExpiry <= 7 && daysUntilExpiry > 0 {
                    notificationManager.sendCriticalAlert(
                        title: "Condition Expiring Soon",
                        body: "\(condition.scriptureReference) will exit 100-year window in \(daysUntilExpiry) days"
                    )
                }
            }
        }
    }

    func manualRefresh() {
        checkForChanges()
        calculator.calculateCurrentReadiness()
    }
}