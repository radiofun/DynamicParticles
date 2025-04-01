//
//  PickerView.swift
//  DynamicParticles
//
//  Created by Jan Stehlík on 01.04.2025.
//
import SwiftUI

// Extracted to avoid SwiftUI bug where Timer interferes with Picker.
struct PickerView: View {
    @Binding var selectedState: ParticleState

    var body: some View {
        Picker("State", selection: $selectedState) {
            ForEach(ParticleState.allCases) { state in
                Text(state.rawValue).tag(state)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedState: ParticleState = .idle
    PickerView(selectedState: $selectedState)
}
