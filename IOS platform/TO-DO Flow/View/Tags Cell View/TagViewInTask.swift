//
//  TagViewInTask.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/27/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

class TagViewInTask: UIView {
    private var taskTag: UIView!
    var tagColor: String!
    
    init(frame: CGRect, tagColor: String) {
        super.init(frame: frame)
        self.tagColor = tagColor
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    enum Color: String {
        case red
        case blue
        case green
        case brown
        case cyan
        case magenta
        case orange
        case purple
        case yellow
        
        var create: UIColor {
            switch self {
            case .red:
                return UIColor.red
            case .blue:
                return UIColor.blue
            case .green:
                return UIColor.green
            case .brown:
                return UIColor.brown
            case .cyan:
                return UIColor.cyan
            case .magenta:
                return UIColor.magenta
            case .orange:
                return UIColor.orange
            case .purple:
                return UIColor.purple
            case .yellow:
                return UIColor.yellow
            }
        }
    }
    
    private func commonInit() {
        backgroundColor = UIColor.white
        layer.cornerRadius = frame.width * 0.5
        
        taskTag = UIView()
        taskTag.translatesAutoresizingMaskIntoConstraints = false
        
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y:0 , width: 12, height: 12))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.cgPath
        
        
        guard let color = Color(rawValue: tagColor) else { return }
        let colorSelected = color.create // colorSelected is now UIColor.red
        
        shapeLayer.fillColor = colorSelected.cgColor // UIColor.red.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.gray.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        
        taskTag.layer.addSublayer(shapeLayer)
        addSubview(taskTag)
        
        NSLayoutConstraint.activate([
            taskTag.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            taskTag.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            taskTag.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            taskTag.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
            ])
    }
}
