//
//  TTTabbar.swift
//  Yuhun
//
//  Created by Mr.hong on 2021/2/1.
//

import Foundation

// 外层只是个容器，包裹着bar,这样bar可以动态调整位置
class TTTabbar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .white
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 分割线
    lazy var segementLine: UIView = {
        var line = UIView()
        line.backgroundColor = tabbarConfiguration.segementLineColor
        self.addSubview(line)
        self.layer.insertSublayer(line.layer, at: 0)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(tabbarConfiguration.segementLineHeight)
        }
        return line
    }()
    
    
    // 自定义导航栏
       lazy var bar: TTCollectionView = {
          let flowLayout = UICollectionViewFlowLayout.init()
             flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0;
            flowLayout.minimumInteritemSpacing = 0;
            let width: Int = Int(SCREEN_W / CGFloat(tabbarConfiguration.sourceData.count))
        
        
          print("宽度是\(width)")
        flowLayout.itemSize = CGSize.init(width:CGFloat(width) , height: TTDefalutBarHeight + tabbarConfiguration.iconTopInteval - 1)
                 var bar = TTCollectionView.init(classNames: ["TTTabbarItem"], flowLayout: flowLayout)
                 bar.isScrollEnabled = false
                self.addSubview(bar)
                bar.snp.makeConstraints { (make) in
                    make.left.right.equalTo(0)
                    
                     // 如果展示line
                    if tabbarConfiguration.showTabbarLine {
                        make.top.equalTo(self.segementLine.snp.bottom)
                    }else {
                        make.top.equalTo(0)
                    }
                    make.height.equalTo(TTDefalutBarHeight + tabbarConfiguration.iconTopInteval)
                }
        
        bar.clipsToBounds = false
        bar.layer.masksToBounds = false
        
//        self.clipsToBounds = false
//               self.layer.masksToBounds = false
            return bar
    }()
    
    
    // 获取点击的cell
    func fetchItemWithIndex(index: Int) ->  TTTabbarItem{
        return bar.cellForItem(at: IndexPath(row: index, section: 0)) as! TTTabbarItem
    }
}
