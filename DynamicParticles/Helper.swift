//
//  Helper.swift
//  DynamicParticles
//
//  Created by Minsang Choi on 3/30/25.
//

import SwiftUI


enum ParticleState : String, CaseIterable, Identifiable {
    case idle
    case listening
    case speaking
    case question

    var id: String {
        self.rawValue
    }

    var text: String {
        switch self {
        case .idle, .listening, .speaking:
            return "circle.fill"
        case .question:
            return "questionmark"
        }
    }

    var animation: Animation {
        switch self {
        case .listening:
            .spring()
        default:
            .linear(duration: 0.5)
        }
    }
}


struct Particle {
    
    var x: Double
    var y: Double
    let baseX: Double
    let baseY: Double
    let density: Double
    var isStopped = false
    var angle: Double = .random(in: 0..<360)
    
    var targetAngle: Double = 0
    var angularSpeed: Double = 0
    var circulationAngle: Double = 0 
  
    mutating func update(state: ParticleState, dragPosition: CGPoint?, dragVelocity: CGSize?) {
        
        switch state {
        case .idle:
            circulate()
        case .listening:
            explodeOutward()
        case .speaking:
            moveToOutline()
        case .question:
            circulate()
        }

        if let dragPosition = dragPosition {
            applyDragEffect(dragPosition: dragPosition, dragVelocity: dragVelocity)
        }
    }

    mutating func circulate() {
        angle += 0.04
        let newX = baseX + cos(angle) * 5
        let newY = baseY + sin(angle) * 5

        x += (newX - x) * 0.1
        y += (newY - y) * 0.1
    }
    
    mutating func moveToOutline() {
        angle += 0.03
        let radius: Double = 60
        
        let newX = baseX + cos(angle) * radius
        let newY = baseY + sin(angle) * radius
        
        x += (newX - x) * 0.1
        y += (newY - y) * 0.2
        
    }

    mutating func explodeOutward() {
        angle += 0.05

        let radius: Double = 180 // half of frame
        let centerX: Double = UIScreen.main.bounds.width * 0.5
        let centerY: Double = UIScreen.main.bounds.height * 0.5 - 40.0
        
        let newX = centerX + cos(angle) * radius
        let newY = centerY + sin(angle) * radius

        x += (newX - x) * 0.1
        y += (newY - y) * 0.1
    }
    
    mutating func applyDragEffect(dragPosition: CGPoint, dragVelocity: CGSize?) {
        let dragDx = x - dragPosition.x
        let dragDy = y - dragPosition.y
        
        var velocityF = 0.0
        
        if let dragVelocity = dragVelocity {
            velocityF = max(abs(dragVelocity.width),abs(dragVelocity.height))
        }
        
        let dragDistance = sqrt(dragDx * dragDx + dragDy * dragDy)
        let dragForce = (200 - min(dragDistance, 200)) / 200 + velocityF * 0.00005
        
        x += dragDx * dragForce * 0.3
        y += dragDy * dragForce * 0.3
    }
}

