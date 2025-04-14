//
//  SettingsViewModel.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/13.
//

import SwiftUI
import Combine
import CoreBluetooth

class SettingsViewModel: NSObject, ObservableObject {
    
    @Published var availablePeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var hasConnectedPeripheral = false
    @Published var isScanning = false
    
    var isCharacteristicFound: Bool {
        peripheralManager.isCharacteristicFound
    }
    
    private let centralManager: CentralManager
    private let peripheralManager: PeripheralManager
    
    private var cancellables = Set<AnyCancellable>()
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(to: peripheral)
    }
    
    func stopScanIfNeeded() {
        centralManager.stopScanIfNeeded()
    }
    
    func startScanIfNeeded() {
        centralManager.startScanIfNeeded()
    }
    
    init(centralManager: CentralManager, peripheralManager: PeripheralManager) {
        self.centralManager = centralManager
        self.peripheralManager = peripheralManager
        
        super.init()
        
        centralManager.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: \.isScanning, on: self)
            .store(in: &cancellables)
        
        peripheralManager.$connectedPeripheral.map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasConnectedPeripheral, on: self)
            .store(in: &cancellables)
        
        peripheralManager.$connectedPeripheral
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectedPeripheral, on: self)
            .store(in: &cancellables)
        
        centralManager.$discoveredPeripherals
            .combineLatest(peripheralManager.$connectedPeripheral)
            .map { discoverablePeripherals, connectedPeripheral in
                discoverablePeripherals.filter { $0.identifier != connectedPeripheral?.identifier }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.availablePeripherals, on: self)
            .store(in: &cancellables)
    }
}
