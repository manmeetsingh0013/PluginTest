// SystemStatsPlugin.swift

import Foundation
import UIKit
import Metal

private let HOST_CPU_LOAD_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

public class StatsTrackingPlugin: NSObject {
    func hostCPULoadInfo() -> host_cpu_load_info {
        var hostCPULoadInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        
        let kerr = withUnsafeMutablePointer(to: &hostCPULoadInfo) { hostCPULoadInfoPtr in
            hostCPULoadInfoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { hostCPULoadInfoIntPtr in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, hostCPULoadInfoIntPtr, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            fatalError("Failed to retrieve CPU load information")
        }
        
        return hostCPULoadInfo
    }
    
    
    func getRAMUsage() -> Double {
            var info = task_vm_info_data_t()
            var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
            
            let kerr = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
                }
            }
            
            if kerr == KERN_SUCCESS {
                let usedBytes = Double(info.phys_footprint)
                let memoryUsage = usedBytes / (1024 * 1024) // Memory usage in MB
                return memoryUsage
            } else {
                return -1.0
            }
        }



private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?


    func getGpuData() -> Double {
        guard let device = device, let commandQueue = commandQueue else {
            print("Metal is not supported on this device")
            return -1.0
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Failed to create command buffer")
            return -1.0
        }

        // Create a Metal command encoder for some GPU work
        // For example, you might encode rendering commands here
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: MTLRenderPassDescriptor())

        // End encoding commands
        commandEncoder?.endEncoding()

        // Measure the time it takes to execute the command buffer
        let startTime = CACurrentMediaTime()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        let endTime = CACurrentMediaTime()

        // Calculate GPU usage based on execution time
        let executionTime = endTime - startTime
        let gpuUsage = executionTime * 1000 // Multiply by 1000 to convert to milliseconds

        return gpuUsage
    }
}


//UNITY

let a  = StatsTrackingPlugin()

var cpuStartUsage = 0.0
var cpuEndUsage = 0.0

var ramStartUsage = 0.0
var ramEndUsage = 0.0

var gpuStartUsage = 0.0
var gpuEndUsage = 0.0

var trackedData: [Double] = [0,0,0]

@_cdecl("startTracking")
public func startTracking()
{
    //cpu usage
    let cpuLoadInfo = a.hostCPULoadInfo()
        // Access cpu_ticks
        let userTicks = cpuLoadInfo.cpu_ticks.0
        let systemTicks = cpuLoadInfo.cpu_ticks.1
        let idleTicks = cpuLoadInfo.cpu_ticks.2
        let interruptTicks = cpuLoadInfo.cpu_ticks.3

    let totalTicks = userTicks + systemTicks + idleTicks
    let nonIdleTicks = userTicks + systemTicks

    cpuStartUsage = Double(nonIdleTicks) / Double(totalTicks) * 100
    
    //ram usage
    ramStartUsage = a.getRAMUsage()
    
    //gpu usage
    gpuStartUsage = a.getGpuData()
    
    print("Unity Tracking Started")
}


@_cdecl("stopTracking")
public func stopTracking() -> UnsafeMutablePointer<Double>
{
    //cpu usage
    let cpuLoadInfo = a.hostCPULoadInfo()
        // Access cpu_ticks
        let userTicks = cpuLoadInfo.cpu_ticks.0
        let systemTicks = cpuLoadInfo.cpu_ticks.1
        let idleTicks = cpuLoadInfo.cpu_ticks.2
        let interruptTicks = cpuLoadInfo.cpu_ticks.3

    let totalTicks = userTicks + systemTicks + idleTicks
    let nonIdleTicks = userTicks + systemTicks

    cpuEndUsage = Double(nonIdleTicks) / Double(totalTicks) * 100
    
    //ram usage
    ramEndUsage = a.getRAMUsage()
    
    //gpu usage
    gpuEndUsage = a.getGpuData()
    
    trackedData[0] = cpuEndUsage - cpuStartUsage
    trackedData[1] = ramEndUsage - ramStartUsage
    trackedData[2] = gpuEndUsage - gpuStartUsage
    
    print("Unity CPU Usage: \( trackedData[0])")
    print("Unity RAM Usage: \( trackedData[1])")
    print("Unity GPU Usage: \( trackedData[2])")
    
    let pointer = UnsafeMutablePointer<Double>.allocate(capacity: trackedData.count)
    trackedData.withUnsafeBufferPointer {
        pointer.initialize(from: $0.baseAddress!, count: trackedData.count)
    }
    return pointer
    
}
