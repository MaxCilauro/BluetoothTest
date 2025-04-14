//
//  CentralManager.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/12.
//

import Combine
import CoreBluetooth

class CentralManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    
    private let peripheralManager: PeripheralManager?
    
    @Published var canScanForDevices = false
    @Published var discoveredPeripherals = [CBPeripheral]()
    
    @Published var isScanning = false
    
    var availablePeripherals: [CBPeripheral] {
        guard let connectedPeripheral = peripheralManager?.connectedPeripheral else { return discoveredPeripherals }
        
        return discoveredPeripherals.filter { $0.identifier != connectedPeripheral.identifier }
    }
    
    private var centralManager: CBCentralManager? {
        didSet {
            canScanForDevices = centralManager != nil
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    init(peripheralManager: PeripheralManager?) {
        self.peripheralManager = peripheralManager
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func toggleBluetooth() {
        if centralManager?.state == .poweredOn {
            stopScanIfNeeded()
            centralManager = nil
            isScanning = false
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        canScanForDevices = central.state.isPoweredOn
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) && peripheral.name != nil {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = peripheralManager
        stopScanIfNeeded()

        peripheralManager?.set(connectedPerihperal: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("❌ Failed to disconnect: \(error.localizedDescription)")
        } else {
            print("✅ Disconnected from peripheral: \(peripheral.name ?? "Unnamed")")
            
            peripheralManager?.disconnect()
        }
    }
    
    func startScanIfNeeded() {
        guard canScanForDevices else { return }
        guard let centralManager else { return }
        guard !isScanning else { return }
        guard peripheralManager?.connectedPeripheral == nil else { return }

        discoveredPeripherals.removeAll()

        centralManager.scanForPeripherals(withServices: [BLE.Services.ledToggle], options: nil)
        isScanning = true
    }
    
    func stopScanIfNeeded() {
        guard isScanning else { return }

        centralManager?.stopScan()
        isScanning = false
    }
}

private extension CBManagerState {
    
    var isPoweredOn: Bool {
        switch self {
        case .poweredOn: return true
        default: return false
        }
    }
}
