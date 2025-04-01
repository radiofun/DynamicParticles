//
//  ParticleAnimationView.swift
//  DynamicParticles
//
//  Created by Minsang Choi on 3/30/25.
//

import SwiftUI

struct ParticleAnimation: View {
    
    let particleCount = 1000
    
    @State private var particles: [Particle] = []
    @State private var size: CGSize = .zero
    @State private var state: ParticleState = .idle
    @State private var dragPosition: CGPoint?
    @State private var dragVelocity: CGSize?

    let timer = Timer.publish(every: 1/120, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        Canvas { context, size in
            renderCanvas(&context)
        }
        .onReceive(timer) { _ in
            updateParticles()
        }
        .onChange(of: state, initial: true) {
            createParticles()
        }
        .gesture(gesture)
        .background(.background)
        .onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { newValue in
            size = newValue
        }
        
        PickerView(selectedState: $state)
          .padding()
        
    }

    private func renderCanvas(_ context: inout GraphicsContext) {
        context.blendMode = .normal
        let mutedColors: [Color] = [
            Color(red: 0.2, green: 0.7, blue: 0.6),
            Color(red: 1.0, green: 0.8, blue: 0.6),
            Color(red: 0.6, green: 1.0, blue: 0.8),
            Color(red: 0.8, green: 0.6, blue: 0.7),
            Color(red: 0.6, green: 0.8, blue: 0.7)
        ]

        for (index, particle) in particles.enumerated() {
            let path = Path(ellipseIn: CGRect(x: particle.x, y: particle.y, width: 3, height: 3))
            let color = mutedColors[index % mutedColors.count].opacity(1.0)
            context.fill(path, with: .color(color))
        }
    }

    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragPosition = value.location
                dragVelocity = value.velocity
                triggerHapticFeedback()
            }
            .onEnded { value in
                dragPosition = nil
                dragVelocity = nil
                updateParticles()
            }
    }

    private func createParticles() {
        let renderer = ImageRenderer(content:
                                        Image(systemName
                                              : state.text)
            .resizable()
            .scaledToFit()
            .frame(width: 360, height: 360)
        )
        
        renderer.scale = 1.0
        
        guard let image = renderer.uiImage else { return }
        guard let cgImage = image.cgImage else { return }
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        guard let pixelData = cgImage.dataProvider?.data, let data = CFDataGetBytePtr(pixelData) else { return }
        
        let offsetX = (size.width - CGFloat(width)) / 2
        let offsetY = (size.height - CGFloat(height)) / 2
        
        particles = (0..<particleCount).map { _ in
            var x, y: Int
            repeat {
                x = Int.random(in: 0..<width)
                y = Int.random(in: 0..<height)
            } while data[((width * y) + x) * 4 + 3] < 128
            
            return Particle(
                x: Double.random(in: 0...size.width),
                y: Double.random(in: 0...size.height),
                baseX: Double(x) + offsetX,
                baseY: Double(y) + offsetY,
                density: Double.random(in: 5...20)
            )
        }
    }
    
    private func updateParticles() {
        withAnimation(state.animation) {
            for i in particles.indices {
                particles[i].update(state: state,
                                    dragPosition: dragPosition,
                                    dragVelocity: dragVelocity)
            }
        }
    }
}

func triggerHapticFeedback() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
}

#Preview {
    ParticleAnimation()
}
