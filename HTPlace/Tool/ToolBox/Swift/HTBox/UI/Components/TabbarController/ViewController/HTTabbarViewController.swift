//
//  HTTabbarViewController.swift
//  HTPlace
//
//  Created by Mr.hong on 2020/10/10.
//  Copyright © 2020 Mr.hong. All rights reserved.
//

import UIKit
import RxSwift
import SnapKitExtend
import Kingfisher
//import QMUIKit

// 根据字符串获取类名
func HTClassFromString(classNames: String) -> AnyClass {
    // 工程名
    let workName = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
    return NSClassFromString("\(workName).\(classNames)")!
}


class HTCollectionView: UICollectionView {
    // 代理必须牵到控制器上去,由控制器vm管理数据源
    var flowLayout: UICollectionViewFlowLayout!
    
    
    // 传类名，和layout
    init(classNames:[String],flowLayout: UICollectionViewFlowLayout) {
        self.flowLayout = flowLayout
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        self.backgroundColor = .white
        _registCell(classNames: classNames)
    }
    
    
    init(lineSpacing: CGFloat,interitemSpacing: CGFloat,classNames:[String])  {
        flowLayout = UICollectionViewFlowLayout.init()
        // 滚动方向相同的间距为minimumLineSpacing  垂直的minimumInteritemSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.minimumInteritemSpacing = interitemSpacing
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        
        
        _registCell(classNames: classNames)
    }
    
    // 注册所需的cell
    func _registCell(classNames: [String]) {
        let _ = classNames.map {
            let cellClass = HTClassFromString(classNames: $0) as! UICollectionViewCell.Type
            self.register(cellClass, forCellWithReuseIdentifier: $0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//class HTTabbar: HTCollectionView {
//
//
//
//
//
//    // tabbar的创建由CollectionView控制,动态平分宽度
//    func itemSelcetd() {
//
//    }
//
//}



extension UICollectionViewCell {
    //    // 渲染方法
    //    func rendModel(model: AnyClass) {
    //
    //    }
}

// 底层通用Cell类
class HTCollectionViewCell: UICollectionViewCell {
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


// tabbar 的全局设置
var tabbarConfiguration = HTTabbarConfiguration()

// itemCell
class HTTabbarItemCell: HTCollectionViewCell {
    // 图标
    let itemIcon = UIImageView.empty()
    
    // 内容
    let itemContent = UILabel()
    
    // 初始化UI
    override func setupUI() {
        // 不可点击,点击事件由cell完成
        itemIcon.isUserInteractionEnabled = false;
        itemContent.textAlignment = .center
        
        addSubview(itemIcon)
        addSubview(itemContent)
        
        // layout
        itemIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 25, height: 25))
            make.top.equalTo(tabbarConfiguration.iconTopInteval)
        }
        
        itemContent.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(itemIcon.snp.bottom).offset(tabbarConfiguration.spacingBetweenImageAndTitle)
        }
    }
    
    // 双击事件，添加手势响应速度太慢，思路，靠两次点击的间隔，来实现判断检测是否是双击
//    @objc func doubleClickAction(_ sender: UITapGestureRecognizer) {
//        print("双击了")
//    }
    
    
    // 渲染模型
    func rendModel(_ itemModel: HTTabbarViewControllerItemModel) {
        var imageName = ""
        if itemModel.selected {
            imageName = itemModel.selectedImageName
            self.itemContent.textColor = tabbarConfiguration.selectedColor
            self.itemContent.font = tabbarConfiguration.selectedFont
        }else {
            imageName = itemModel.normalImageName
            self.itemContent.textColor = tabbarConfiguration.normalClor
            self.itemContent.font = tabbarConfiguration.normalFont
        }
        
        // 如果包含网页
        if  imageName.contains("http") {
            self.itemIcon.kf.setImage(with: URL.init(string: imageName))
        }else {
            let image = UIImage(named: imageName)
            self.itemIcon.image = image
        }

        self.itemContent.text = itemModel.itemContent
    }
    
    // 播放动画
    func playAnimationIcon(_ iconNames: [String]) {
        // 如果为没有图片名称，那么就不执行
        guard iconNames.count == 0 else {
            return
        }
        
        
        var iconImages = [Image]()
        for i in 0...12 {
            iconImages.append(Image.name(iconNames[i]))
        }
        
        itemIcon.animationImages = iconImages  // 装图片的数组(需要做动画的图片数组)
        itemIcon.animationDuration = 2        // 动画时间
        itemIcon.animationRepeatCount = 1     // 重复次数 0 表示重复
        itemIcon.startAnimating()             // 开始序列帧动画
    }
}

struct HTTabbarViewControllerItemModel: Equatable {
    // 未选中图片名字
    var normalImageName = ""
    
    // 选中item时的图片的名字
    var selectedImageName = ""
    
    // 内容
    var itemContent = ""
    
    // 选中状态
    var selected = false
    
    static func == (lhs: HTTabbarViewControllerItemModel, rhs: HTTabbarViewControllerItemModel) -> Bool {
           return lhs.normalImageName == rhs.normalImageName
       }
}

// viewModel,准备数据源，和相关网络请求等
class HTTabbarViewControllerViewModel {
    var sourceData = [HTTabbarViewControllerItemModel]()
    //    var items = [HTTabbarViewControllerItemModel]()
    var items = Observable.just([
        HTTabbarViewControllerItemModel()
    ])
}

extension DispatchQueue {
    private static var _onceToken = [String]()
    
    class func once(token: String = "\(#file):\(#function):\(#line)", block: ()->Void) {
        objc_sync_enter(self)
        
        defer
        {
            objc_sync_exit(self)
        }
        
        if _onceToken.contains(token)
        {
            return
        }
        
        _onceToken.append(token)
        block()
    }
}

// 自定义tabbar导航栏高度, 49感觉有点矮
let HTDefalutBarHeight: CGFloat = 53

// tabbar的总高度
let HTTabbarHeight = HaveSafeArea ? HTDefalutBarHeight + 34 : HTDefalutBarHeight


// 点击代理
protocol  HTTabbarViewControllerDelegate{
    func itemDidSelected(index: Int)
    func canChangePage(index: Int) -> Bool
}

extension HTTabbarViewControllerDelegate{

}

// tabbar的配置
struct HTTabbarConfiguration {
    // 原数据
    var sourceData = [HTTabbarViewControllerItemModel]()
 
    // rx相关包装过后的数据
      var items = Observable.just([
          HTTabbarViewControllerItemModel()
      ])
     
    // 全局未选中颜色
    var normalClor: UIColor = .gray
    
    // 全局未选中字体,默认10
    var normalFont: UIFont  = UIFont.size(10)

    // 全局选中颜色
    var selectedColor: UIColor = .black
    
    // 全局选中字体,默认10
    var selectedFont: UIFont  = UIFont.size(10)
    
     // 图标距离顶部的距离
    var iconTopInteval: CGFloat = HaveSafeArea ? ver(8) : ver(4)
    
    // 文字之间的间距
    var spacingBetweenImageAndTitle = ver(3)
    
    // 是否显示tabbar横线
    var showTabbarLine: Bool = true
}

// 外层只是个容器，包裹着bar,这样bar可以动态调整位置
class HTTabbar: UIView {
    
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
        line.backgroundColor = rgba(151, 151, 151, 0.4)
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        return line
    }()
    
    
    // 自定义导航栏
       lazy var bar: HTCollectionView = {
          let flowLayout = UICollectionViewFlowLayout.init()
                 flowLayout.scrollDirection = .horizontal
              flowLayout.itemSize = CGSize.init(width: SCREEN_WIDTH / CGFloat(tabbarConfiguration.sourceData.count), height: HTDefalutBarHeight + tabbarConfiguration.iconTopInteval)
                 var bar = HTCollectionView.init(classNames: ["HTTabbarItemCell"], flowLayout: flowLayout)
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
                    make.height.equalTo(HTDefalutBarHeight + tabbarConfiguration.iconTopInteval)
                }
            return bar
    }()

}


//classNames:[String]
class HTTabbarViewController: UITabBarController,HTTabbarViewControllerDelegate {
    
    
    // 自定义导航栏
    var htTabbar = HTTabbar()
    
    // vm数据源
    let vm = HTTabbarViewControllerViewModel()
    
    // 模型数据
    init(itemModels:[HTTabbarViewControllerItemModel]) {
        tabbarConfiguration.sourceData = itemModels
        
        //        vm.items = itemModels
        vm.sourceData = itemModels
        vm.items = Observable.just(itemModels)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // 移除之前的导航栏
        self.tabBar.isHidden = true
        self.tabBar.removeFromSuperview()
        
        setupTabbar()
        
        //        DispatchQueue.once(token: "identify") {
        //            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"), object: nil, queue: .main) { (notifi) in

        //            }
        //        }
        
    }
    
    // 上次点击的按钮模型
    var lastClickItemModel: HTTabbarViewControllerItemModel?
    
    // 上次点击的时间
    var lastClickTime: UInt64 = 0
    
    
    
    
//    // 用于统计时间
//    double MachTimeToSecs(uint64_t time)
//    {
//        mach_timebase_info_data_t timebase;
//        mach_timebase_info(&timebase);
//        return (double)time * (double)timebase.numer / (double)timebase.denom / 1e9;
//    }
    
    // 设置tabbar
    func setupTabbar() {
        self.view.addSubview(htTabbar)
        htTabbar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(HTTabbarHeight)
        }
        
        // rx绑定数据源,直接显示
        vm.items.bind(to: htTabbar.bar.rx.items(cellIdentifier: "HTTabbarItemCell", cellType: HTTabbarItemCell.self)) { [weak self] (collectionView, itemModel, cell) in
            cell.rendModel(itemModel)
            if itemModel.selected {
                self!.lastClickItemModel = itemModel
            }
        }
        .disposed(by: rx.disposeBag)
        
        // UInt64 转秒数
        func MachTimeToSecs(time: UInt64) -> Double {
            var  timebase = mach_timebase_info_data_t()
            mach_timebase_info(&timebase)
            
            return Double(time) * Double(timebase.numer) / Double(timebase.denom) / 1e9;
        }
        
        //  获取点击行
        htTabbar.bar.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            
            // 如果可以选中，那么选中
            if self?.canChangePage(index: indexPath.row) == true {
              
                
                // 点击的是同一个，就返回,检测是否双击
              var itemModel = self!.vm.sourceData[indexPath.row]
                if itemModel == self?.lastClickItemModel {
                  
                    // 当前时间
                    let currentTime: UInt64 = mach_absolute_time()
                    
                    // 如果时间小于0.5秒，0.5秒是最早windows双击的缺省值参考，可以调整
                    if MachTimeToSecs(time: currentTime - self!.lastClickTime) < 0.5 {
                        // 触发双击事件
                        self?.doubleClickAction(index: indexPath.row)
                    }
                    
                    // 记录上次的点击时间
                    self!.lastClickTime = currentTime
                    return
                }
                
                
                // 有上一个模型
                if (self?.lastClickItemModel != nil) {
                        // 取消上一个选中
                      self?.lastClickItemModel?.selected = false
                      
//                         let lastIndex = 0
//                    self!.vm.sourceData.firstIndex(where:{$0 == self?.lastClickItemModel})
                    
                    
                    if let lastIndex = self!.vm.sourceData.firstIndex(where: { item -> Bool in
                        
                        print("\(item.normalImageName)")
                               return item == self!.lastClickItemModel
                       }){
                        
                        
                           let lastCell = self!.htTabbar.bar.cellForItem(at: IndexPath(row: lastIndex, section: 0)) as! HTTabbarItemCell
                            lastCell.rendModel(self!.lastClickItemModel!)
                       }
                    
                    
                }
                
            
                
                
                let cell = self!.htTabbar.bar.cellForItem(at: indexPath) as! HTTabbarItemCell
            
                itemModel.selected = true
                
                cell.rendModel(itemModel)
                
                self?.lastClickItemModel = itemModel
                
                self?.selectedIndex = indexPath.row
                
                self?.itemDidSelected(index: indexPath.row)
                
                
                // 播放动画
                cell.playAnimationIcon([""])
            }
       
            
        }).disposed(by: rx.disposeBag)
        
        
        // 没有选中
//        htTabbar.bar.rx.itemDeselected.subscribe(onNext: { [weak self] (indexPath) in
//        }).disposed(by: self.rx.disposeBag)
    }
    
    
    // 选择某个下标
    func itemDidSelected(index: Int) {
        
    }
    
    // 双击事件
    func doubleClickAction(index: Int) {
        
    }
    
    // 是否可以点击
    func canChangePage(index: Int) -> Bool {
        return true
    }
    
    //显示消息提示框
    func showAlert(title: String,message: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}