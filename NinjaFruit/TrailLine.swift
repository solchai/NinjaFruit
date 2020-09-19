//
//  TrailLine.swift
//  NinjaFruit
//
//  Created by Solomon Chai on 2020-08-16.
//  Copyright © 2020 Solomon Chai. All rights reserved.
//

import SpriteKit

class TrailLine: SKShapeNode {
    var shrinkTimer = Timer()
    
    init(position: CGPoint, lastPosition: CGPoint, width: CGFloat, color: UIColor) {
        super.init()
        
        let path = CGMutablePath()
        path.move(to: position)
        path.addLine(to: lastPosition)
        
        self.path = path
        lineWidth = width
        strokeColor = color
        
        shrinkTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: {_ in
            self.lineWidth -= 2
            
            if self.lineWidth == 0 {
                self.shrinkTimer.invalidate()
                self.removeFromParent()
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
