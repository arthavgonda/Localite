//
//  MorphingStrokeShape.swift
//  localite2
//
//  Created by ANOOP on 21/07/26.
//

import SwiftUI

struct MorphingStrokeShape: Shape {
    var progress: CGFloat
    let diameter: CGFloat
    let overflow: CGFloat
    let trackOffset: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let segments = 24
        let radius = diameter / 2
        let cx = rect.minX + radius
        let circleCy = rect.midY
        let lineCy = rect.midY + trackOffset
        let leftPoint = CGPoint(x: rect.minX + radius - overflow * progress, y: lineCy)
        let rightPoint = CGPoint(x: rect.maxX - radius + overflow * progress, y: lineCy)

        var points: [CGPoint] = []

        for i in 0...segments {
            let t = CGFloat(i) / CGFloat(segments)
            let angle = -CGFloat.pi / 2 + t * CGFloat.pi
            let circlePoint = CGPoint(x: cx + radius * cos(angle), y: circleCy + radius * sin(angle))
            let linePoint = CGPoint(x: leftPoint.x + (rightPoint.x - leftPoint.x) * t, y: lineCy)
            points.append(lerp(circlePoint, linePoint, progress))
        }

        for i in 0...segments {
            let t = CGFloat(i) / CGFloat(segments)
            let angle = CGFloat.pi / 2 + t * CGFloat.pi
            let circlePoint = CGPoint(x: cx + radius * cos(angle), y: circleCy + radius * sin(angle))
            let linePoint = CGPoint(x: rightPoint.x - (rightPoint.x - leftPoint.x) * t, y: lineCy)
            points.append(lerp(circlePoint, linePoint, progress))
        }

        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        return path
    }

    private func lerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
}
