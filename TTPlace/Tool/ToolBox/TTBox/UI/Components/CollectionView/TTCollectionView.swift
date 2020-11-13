//
//  TTCollectionView.swift
//  TTPlace
//
//  Created by Mr.hong on 2020/10/29.
//  Copyright © 2020 Mr.hong. All rights reserved.
//

import Foundation


class TTCollectionView: UICollectionView {
    // 代理必须牵到控制器上去,由控制器vm管理数据源
    var flowLayout: UICollectionViewFlowLayout!
    
    // 类名
    var classNames = [String]()
    
    
    // 传类名，和layout
    init(classNames:[String],flowLayout: UICollectionViewFlowLayout) {
        self.flowLayout = flowLayout
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        self.backgroundColor = .white
        
        _registCell(classNames: classNames)
    }
    
    
    init(lineSpacing: CGFloat,interitemSpacing: CGFloat,classNames:[String],derection: UICollectionView.ScrollDirection)  {
        flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = derection
        // 滚动方向相同的间距为minimumLineSpacing  垂直的minimumInteritemSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.minimumInteritemSpacing = interitemSpacing
        flowLayout.itemSize = CGSize.init(width: SCREEN_W, height: SCREEN_H)
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        _registCell(classNames: classNames)
        contentInsetAdjustmentBehavior = .never;
        
    }
    
    // 注册所需的cell
    func _registCell(classNames: [String]) {
        var classNamesArray = classNames
        
        if !classNamesArray.contains("TTCollectionViewCell") {
            classNamesArray.append("TTCollectionViewCell")
        }
        let _ = classNamesArray.map {
            let cellClass = TTClassFromString(classNames: $0) as! UICollectionViewCell.Type
            self.register(cellClass, forCellWithReuseIdentifier: $0)
        }
        
        // 赋值Cell类名数组
        self.classNames =  classNamesArray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// 底层通用Cell类
class TTCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
}
