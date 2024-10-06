//
//  CircularProgressView.swift
//  Pradakshina
//
//  Created by Vasisht Muduganti on 9/17/24.
//

import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var backgroundLayer = CAShapeLayer()
    
    // Customizeable properties
    var lineWidth: CGFloat = 13 {
        didSet {
            configureLayers()
        }
    }
    
    var progressColor: UIColor = #colorLiteral(red: 0.9986872077, green: 0.3591775596, blue: 0.006945624482, alpha: 1){
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var backgroundCircleColor: UIColor = #colorLiteral(red: 0.8838221431, green: 0.8838221431, blue: 0.8838221431, alpha: 1) {
        didSet {
            backgroundLayer.strokeColor = backgroundCircleColor.cgColor
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayers()
    }
    
    // MARK: - Configuration
    private func configureLayers() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Background Circle
        backgroundLayer.path = createCirclePath().cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = backgroundCircleColor.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        // Progress Circle
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    }
    func resetProgress(animated: Bool = false, duration: CFTimeInterval = 0.5, clockwise: Bool) {
        if clockwise == true{
            setProgress(to: 300, animated: animated, duration: duration, didFinish: true, clockwise: clockwise)
        }
        else{
            setProgress(to: 300, animated: animated, duration: duration, didFinish: true, clockwise: clockwise)
        }
        }
    private func createCirclePath() -> UIBezierPath {
        return UIBezierPath(arcCenter: centerPoint(),
                            radius: radius(),
                            startAngle: 0,
                            endAngle: 2 * CGFloat.pi,
                            clockwise: true)
    }
    
    private func centerPoint() -> CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private func radius() -> CGFloat {
        return min(bounds.width, bounds.height) / 2 - lineWidth / 2
    }
    
    // MARK: - Set Progress
    
    func setProgress(to angle: CGFloat, animated: Bool = false, duration: CFTimeInterval = 0.5, didFinish: Bool, clockwise: Bool) {
        
        let clampedAngle = angle.truncatingRemainder(dividingBy: 360)
        let startAngle: CGFloat = -CGFloat.pi / 2 // 0 degrees at top
        var endAngle: CGFloat = startAngle + (clampedAngle * .pi / 180)
        var c = clockwise
        
        if clampedAngle > 270 {
            endAngle = startAngle - ((360 - clampedAngle) * .pi / 180)
            if didFinish == false{
                c = false
            }
        }
        else{
            if didFinish == false{
                c = true
            }
        }
        
        let progressPath = UIBezierPath(arcCenter: centerPoint(),
                                        radius: radius(),
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: c)
        
        progressLayer.path = progressPath.cgPath
        
        if animated {
            animateProgress(duration: duration)
        }
    }
    
    // MARK: - Animation
    private func animateProgress(duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        progressLayer.add(animation, forKey: "progressAnimation")
    }
}
class HollowRingView: UIView {

    var ringColor: UIColor = .blue
    var ringThickness: CGFloat = 10.0

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Define the center and radius of the ring
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - ringThickness / 2
        let outerRadius = radius + ringThickness
        
        // Set up the color and line width
        context.setStrokeColor(ringColor.cgColor)
        context.setLineWidth(ringThickness)
        
        // Draw the outer circle
        context.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Draw the inner circle
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Clip to the ring shape
        context.clip()
        
        // Draw the ring by stroking the outer circle
        context.strokePath()
    }
}
