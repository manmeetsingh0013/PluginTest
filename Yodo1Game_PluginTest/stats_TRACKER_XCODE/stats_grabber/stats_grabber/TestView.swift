import SwiftUI

struct TestView: View {
    var body: some View {
        let cpu = StatsTrackingPlugin()
        SwiftUI.Button("Load CPU"){
            let usage = cpu.hostCPULoadInfo()
                
            print("CPU Usage: \(String(describing: usage)) MB")
            }
        
    SwiftUI.Button("Load RAM")
        {
                let usage = cpu.getRAMUsage()
                print("RAM Usage: \(usage)")
            
        }
    }
}

#Preview {
    TestView()
}
