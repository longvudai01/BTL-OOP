//
//  TaskTagsView.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/26/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

protocol TaskTagsViewDataSource: class {
    func numberOfViews(in taskTagsView: TaskTagsView) -> Int
    func taskTagsView(_ taskTagsView: TaskTagsView, viewAt index: Int) -> UIView
}

class TaskTagsView: UIView {
    
    weak var dataSource: TaskTagsViewDataSource?
    
    private enum ViewConstants {
        static let Padding: CGFloat = 0
        static let Dimensions: CGFloat = 12
        static let Offset: CGFloat = 0
    }
    
    private var contentViews = [UIView]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reload() {
        guard let dataSource = dataSource else { return }
        
        contentViews.forEach { $0.removeFromSuperview() }
        contentViews.removeAll()
        
        //var xValued = self.bounds.maxX
        var xValued = ViewConstants.Offset
        
        // fetched and add the new views
        contentViews = (0..<dataSource.numberOfViews(in: self)).map({ index in
            let view = dataSource.taskTagsView(self, viewAt: index)
            view.frame = CGRect(x: xValued, y: ViewConstants.Padding, width: ViewConstants.Dimensions, height: ViewConstants.Dimensions)
            self.addSubview(view)
            
            xValued += ViewConstants.Dimensions * 0.5
            
            return view
        })
    }
    
}
