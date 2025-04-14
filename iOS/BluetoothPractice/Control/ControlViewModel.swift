//
//  ControlViewModel.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/13.
//

import Combine
import Foundation

class ControlViewModel: NSObject, ObservableObject {
    @Published var brigthness = 0.0
    
    private let peripheralManager: PeripheralManager
    private var cancellables = Set<AnyCancellable>()
    
    init(peripheralManager: PeripheralManager) {
        self.peripheralManager = peripheralManager
        super.init()

        $brigthness.removeDuplicates().sink(receiveValue: { brigthness in
            let int = UInt8(brigthness)
            let data = Data([int])

            peripheralManager.send(data: data)
        })
        .store(in: &cancellables)
        
        peripheralManager.receivedData.sink { [self] data in
            guard let receivedBrightness = data.first else { return }

            if receivedBrightness != UInt8(brigthness) {
                brigthness = Double(receivedBrightness)
            }
        }
        .store(in: &cancellables)
    }
}
