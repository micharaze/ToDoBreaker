import Foundation
import ServiceManagement

final class LoginItemService {
    static let shared = LoginItemService()
    private init() {}

    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[LoginItemService] \(error)")
        }
    }
}
