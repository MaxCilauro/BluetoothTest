//
//  SettingsView.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/13.
//

import SwiftUI
import CoreBluetooth

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    
    init(centralManager: CentralManager, peripheralManager: PeripheralManager) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(centralManager: centralManager, peripheralManager: peripheralManager))
    }
    
    var body: some View {
        VStack() {
            if viewModel.isScanning {
                Button("Stop Scan", action: { viewModel.stopScanIfNeeded() })
            } else {
                Button("Start Scan", action: { viewModel.startScanIfNeeded() })
            }
            
            List {
                if let peripheral = viewModel.connectedPeripheral {
                    Section("Connected Device") {
                        HStack() {
                            Text(peripheral.name ?? "Unknown")
                            Image(systemName: "checkmark")
                                .scaledToFit()
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section(
                    content: {
                        if viewModel.availablePeripherals.isEmpty {
                            Text("No devices found.")
                        } else {
                            ForEach(viewModel.availablePeripherals, id: \.identifier) { peripheral in
                                Button(action: {
                                    viewModel.connect(to: peripheral)
                                }) {
                                    HStack {
                                        Text(peripheral.name ?? "Unknown")
                                    }
                                }
                            }
                        }
                    },
                    header: {
                        HStack {
                            Text("\(viewModel.hasConnectedPeripheral ? "Other Devices" : "Devices")")
                            if viewModel.isScanning {
                                ProgressView()
                            }
                        }
                    }
                )
            }
            Spacer()
        }
            .onAppear() {
                viewModel.startScanIfNeeded()
            }
            .onDisappear() {
                viewModel.stopScanIfNeeded()
            }
    }
}


#Preview {
    ContentView()
}
