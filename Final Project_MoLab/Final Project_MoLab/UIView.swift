//
//  UIView.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 11/30/23.
//

import UIKit

class GlassView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Draw the glass shape
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        UIColor.blue.setFill()
        path.fill()
    }
}
