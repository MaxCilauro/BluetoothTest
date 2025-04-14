//
//  ControlView.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/13.
//

import SwiftUI

struct ControlView: View {
    @StateObject var viewModel: ControlViewModel
    
    init(peripheralManager: PeripheralManager) {
        _viewModel = StateObject(wrappedValue: ControlViewModel(peripheralManager: peripheralManager))
    }
    
    var body: some View {
        VStack {
            Slider(value: $viewModel.brigthness, in: 0...255, step: 15) {
                Text("Brightness")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    ControlView(peripheralManager: .init())
}
