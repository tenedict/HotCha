
import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                // 인터넷 연결 상태를 확인
                self?.isConnected = path.status == .satisfied
            }
        }
        
        // 네트워크 모니터 시작
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
