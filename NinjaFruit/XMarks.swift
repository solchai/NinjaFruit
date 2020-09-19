//
//  XMarks.swift
//  NinjaFruit
//
//  Created by Solomon Chai on 2020-08-17.
//  Copyright © 2020 Solomon Chai. All rights reserved.
//

import SpriteKit

class XMarks: SKNode {
    var xArray = [SKSpriteNode]()
    var numXs = Int()
    
    let watermelonPic = SKTexture(imageNamed: "Watermelon")
    let redXPic = SKTexture(imageNamed: "RedX")
    

    init(num: Int = 0) {
        super.init()
        
        numXs = num
        
        for i in 0..<num {
            let xMark = SKSpriteNode(imageNamed: "Watermelon")
            xMark.size = CGSize(width: 60, height: 60)
            xMark.position.x = -CGFloat(i)*70
            addChild(xMark)
            xArray.append(xMark)
        }
    }
    
    func update(num: Int) {
        if num <= numXs {
            xArray[xArray.count-num].texture = redXPic
        }
    }
    
    func reset() {
        for xMark in xArray {
            xMark.texture = watermelonPic
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
