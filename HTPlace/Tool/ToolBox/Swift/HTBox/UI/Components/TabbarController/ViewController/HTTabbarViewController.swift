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
    // 渲染方法
    func rendModel(model: AnyClass) {
        
    }
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


class HTTabbarItemCell: HTCollectionViewCell {
    // 图标
    let itemIcon = UIButton()
    
    // 内容
    let itemContent = UILabel()
    
    // 初始化UI
    override func setupUI() {
        // 不可点击,点击事件由cell完成
        itemIcon.isUserInteractionEnabled = false;
        
        addSubview(itemIcon)
        addSubview(itemContent)
        
        
        // layout
        itemIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(0)
        }
        
        
        itemContent.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(itemIcon.snp.bottom)
        }
    }
}


struct HTTabbarViewControllerItemModel {
    // 未选中图片名字
    var normalImageName = ""
    
    // 选中item时的图片的名字
    var selectedImageName = ""
    
    // 内容
    var itemContent = ""
    
    // 选中状态
    var selected = false
    
    
}




// viewModel,准备数据源，和相关网络请求等
class HTTabbarViewControllerViewModel {
    var sourceData = [Any]()
    var items = [HTTabbarViewControllerItemModel]()
    //    var items = Observable.just([
    //        HTTabbarViewControllerItemModel()
    //    ])
    
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




// 自定义tabbar导航栏高度
let HTTabbarHeight = SCREEN_Height > 667.0 ? ver(49) : ver(49 + 34)






class HTTabbarViewBar: UIView {
    // items数组，方便获取item
    var itemsArray = [QMUIButton]()
    
    init(itemModels:[HTTabbarViewControllerItemModel]) {
        super.init(frame: .zero)
        
        
        let normalColor = UIColor.gray
        let selectedColor = UIColor.red
        let itemFont = UIFont.size(12)
        
        for itemModel in itemModels {
            let item = QMUIButton.qm_title(font: itemFont, normalTitle: itemModel.itemContent, normalTitleColor: normalColor, normalIconName: itemModel.normalImageName, selectedTitle: itemModel.itemContent, selectedTitleColor: selectedColor, selectedIconName: itemModel.selectedImageName)
            item.imagePosition = .top
            item.spacingBetweenImageAndTitle = 0
            item.isSelected = itemModel.selected
            
            
            self.addSubview(item)
            item.snp.makeConstraints { (make) in
                make.height.equalTo(HTTabbarHeight)
            }
            
            itemsArray.append(item)
            itemsArray.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0);
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



//    override init(frame: CGRect) {
//        super.init()
//
//
//
//
//
//    }


//    // 图标
//      let itemIcon = UIButton()
//
//      // 内容
//      let itemContent = UILabel()
//
//      // 初始化UI
//      override func setupUI() {
//          // 不可点击,点击事件由cell完成
//          itemIcon.isUserInteractionEnabled = false;
//
//          addSubview(itemIcon)
//          addSubview(itemContent)
//
//
//          // layout
//          itemIcon.snp.makeConstraints { (make) in
//              make.centerX.equalTo(self)
//              make.top.equalTo(0)
//          }
//
//
//          itemContent.snp.makeConstraints { (make) in
//              make.left.right.equalTo(self)
//              make.top.equalTo(itemIcon.snp.bottom)
//          }
//      }
//}









protocol  HTTabbarViewControllerDelegate{
    func itemDidSelected(item: QMUIButton)
    func canChangePage() -> Bool
}

extension HTTabbarViewControllerDelegate{
    func itemDidSelected(item: QMUIButton) {
        
    }
}

//classNames:[String]
class HTTabbarViewController: UITabBarController,HTTabbarViewControllerDelegate {
  
    
    // 自定义导航栏
    //    lazy var htTabbar: HTCollectionView = {
    //        let flowLayout = UICollectionViewFlowLayout.init()
    //        flowLayout.minimumLineSpacing = 0;
    //        flowLayout.minimumInteritemSpacing = 0;
    //        flowLayout.itemSize = CGSize.init(width: SCREEN_WIDTH / CGFloat(vm.sourceData.count), height: 44)
    //        var htTabbar = HTCollectionView.init(classNames: ["HTTabbarItemCell"], flowLayout: flowLayout)
    //        return htTabbar
    //    }()
    
    
    //    var htTabbar = HTTabbarViewBar(itemModels: <#T##[HTTabbarViewControllerItemModel]#>)
    
    lazy var htTabbar: HTTabbarViewBar = {
        //            let flowLayout = UICollectionViewFlowLayout.init()
        //            flowLayout.minimumLineSpacing = 0;
        //            flowLayout.minimumInteritemSpacing = 0;
        //            flowLayout.itemSize = CGSize.init(width: SCREEN_WIDTH / CGFloat(vm.sourceData.count), height: 44)
        var htTabbar = HTTabbarViewBar.init(itemModels: vm.items)
        return htTabbar
    }()
    
    // vm数据源
    let vm = HTTabbarViewControllerViewModel()
    
    // 模型数据
    init(itemModels:[HTTabbarViewControllerItemModel]) {
        vm.items = itemModels
        //      vm.items = Observable.just(itemModels)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = .red
        self.tabBar.removeFromSuperview()
        setupTabbar()
        
//        DispatchQueue.once(token: "identify") {
//            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"), object: nil, queue: .main) { (notifi) in
//
//                //            self.htTabbar.removeFromSuperview()
//                //
//                //            self.htTabbar.backgroundColor = .yellow
//                //            //        htTabbar.isScrollEnabled = false
//                //
//                //            self.view.addSubview(self.htTabbar)
//                //            self.htTabbar.snp.makeConstraints { (make) in
//                //                        make.left.right.bottom.equalTo(0)
//                //                        make.height.equalTo(HTTabbarHeight)
//                //                    }
//                //
//                //                print("热更新了")
//                //            self.htTabbar.reloadData()
//            }
//        }
        
    }
    
//    @objc func injected() {
//        print("热更新了111")
//
//        //        for views in self.view.subviews {
//        //                       views.removeFromSuperview()
//        //                   }
//        //        setupTabbar()
//        htTabbar.backgroundColor = .gray
//    }
    
    
    
    // 设置tabbar
    func setupTabbar() {
        
        htTabbar.backgroundColor = .gray
        
        
        // 为item添加点击事件
        for item in htTabbar.itemsArray {
            item.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
        }
        
        
        
        self.view.addSubview(htTabbar)
        htTabbar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(HTTabbarHeight)
        }
        
        
        //        // rx绑定数据源,直接显示
        //        vm.items.bind(to: htTabbar.rx.items(cellIdentifier: "HTTabbarItemCell", cellType: HTTabbarItemCell.self)) { (collectionView, itemModel, cell) in
        //
        //            // 创建监听
        //            let observable = Observable.just(itemModel.selected)
        //            observable.bind(to: cell.itemIcon.rx.isSelected)
        //            cell.itemIcon.setImage( .name(itemModel.unSelectImageName), for: .normal)
        //            cell.itemIcon.setImage( .name(itemModel.selectedImageName), for: .selected)
        //        }
        //        .disposed(by: rx.disposeBag)
        //
        //
        //        //  获取点击行
        //        htTabbar.rx.itemSelected.subscribe(onNext: { [weak self] (index) in
        //            print("\(index.row)")
        //            self?.showAlert(title: "点击第几行", message: "\(index.row)")
        //        }).disposed(by: rx.disposeBag)
        //
        //        //  获取点击内容的item
        //        htTabbar.rx.modelSelected(HTTabbarViewControllerItemModel.self).subscribe(onNext: { [weak self] (item) in
        //            print("\(item.itemContent)")
        //
        //            // 如果可以选中，那么选中
        ////            if 1 {
        ////
        ////            }
        //
        //
        //            var itemModel = item
        //            itemModel.selected = true
        //
        //            self?.showAlert(title: "点击内容", message: "\(item.itemContent)")
        //        }).disposed(by: rx.disposeBag)
        //
        //
        //        // 获取取消点击内容的item
        //        htTabbar.rx.modelDeselected(HTTabbarViewControllerItemModel.self).subscribe(onNext: {[weak self] (item) in
        //            var itemModel = item
        //            itemModel.selected = false;
        //            print("取消选中的item\(item.itemContent)")
        ////            self?.showAlert(title: "点击内容", message: "\(item.itemContent)")
        //        }).disposed(by: rx.disposeBag)
        
        
        // item的size
        
    }
    
    
    // 上次点击的item
    //      var lastClickItem: QMUIButton?
    @objc func itemClick(_ sender: QMUIButton) {
        // 是否可以切换页面
        guard canChangePage()else {
            return
        }
        
        
        // 变更状态
        for item in htTabbar.itemsArray {
            sender.isSelected = sender == item ? true : false
        }
        
        
        
        // 代理点击
        itemDidSelected(item: sender)
        
        
        
        let index =  htTabbar.itemsArray.firstIndex(of: sender)!
        
        self.selectedIndex = index
    }
    
    // 控制条件,默认ture
//    func canChangePage() -> Bool {
//        return true;
//    }
    
    func canChangePage() -> Bool {
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
