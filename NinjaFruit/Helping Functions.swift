//
//  Helping Functions.swift
//  NinjaFruit
//
//  Created by Solomon Chai on 2020-08-15.
//  Copyright © 2020 Solomon Chai. All rights reserved.
//

import Foundation
import UIKit

func randomCGFlaot(_ lowerLimit: CGFloat, _ upperLimit: CGFloat) -> CGFloat {
    return lowerLimit + CGFloat(arc4random()) / CGFloat(UInt32.max) * (upperLimit - lowerLimit)
}
