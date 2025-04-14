//
//  PeripheralManager.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/14.
//

import Combine
import CoreBluetooth

class PeripheralManager: NSObject, CBPeripheralDelegate, ObservableObject {
    
    @Published var isCharacteristicFound = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published private var _receivedData: Data? = nil
    
    var receivedData: AnyPublisher<Data, Never> {
        $_receivedData
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    private let onUpdateValue: ((Data) -> Void)?
    
    private var characteristic: CBCharacteristic? {
        didSet {
            isCharacteristicFound = characteristic != nil
        }
    }
    
    init(onUpdateValue: ((Data) -> Void)? = nil) {
        self.onUpdateValue = onUpdateValue
    }
    
    func set(connectedPerihperal: CBPeripheral) {
        self.connectedPeripheral = connectedPerihperal
        connectedPerihperal.discoverServices([BLE.Services.ledToggle])
    }
    
    func send(data: Data) {
        guard let characteristic = self.characteristic else { return }
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func disconnect() {
        connectedPeripheral = nil
        characteristic = nil
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == BLE.Services.ledToggle {
                peripheral.discoverCharacteristics([BLE.Characteristics.ledToggle], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Found characteristic", characteristic.uuid, characteristic.properties)

            if characteristic.uuid == BLE.Characteristics.ledToggle {
                self.characteristic = characteristic
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == BLE.Services.ledToggle,
              let value = characteristic.value else { return }
        
        _receivedData = value
    }
    
}
