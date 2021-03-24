//
//  TTAutoRefreshTableView.swift
//  Yuhun
//
//  Created by Mr.hong on 2021/1/19.
//

import UIKit


enum TTAutoRefreshState {
    case neitherHeaderFooter // 没有刷新头也没有尾巴
    case headerAndFooter // 有刷新头和刷新尾部
    case justHeader // 只有刷新头
    case justFooter // 只有刷新尾部
    case endReFresh //停止刷新状态,没有刷新头要加刷新头和刷新尾部
    case noMore // 无更多数据
    case empty // 无数据状态
    case error // 报错状态
}


// 自动刷新协议
protocol TTAutoRefreshProtocol: UIScrollView {
    // 头部刷新事件
    var headerRefreshEvent: PublishSubject<Int> { get set }
    
    //  尾部刷新事件
    var footerRefreshEvent: PublishSubject<Int> { get set }
    
    // 刷新控件状态
    func refreshHeaderOrFooterState(_ state: TTAutoRefreshState)
    
    /**
     刷新时执行刷新信号,刷新信号去执行ViewModel里的fetchData，自动控制页码和数据源
     空页面展示
     */
    var state: TTAutoRefreshState { get set }
    
    
    // 添加footer
    func addFooter()
}

extension TTAutoRefreshProtocol {
    func refreshHeaderOrFooterState(_ state: TTAutoRefreshState)  {
        switch state {
        case .neitherHeaderFooter:
            mj_header = nil
            mj_footer = nil
        case .headerAndFooter:
            addHeader()
            addFooter()
        case .justHeader:
            mj_footer = nil
            addHeader()
        case .justFooter:
            mj_header = nil
            addFooter()
        case .endReFresh:
            mj_header?.endRefreshing()
            mj_footer?.endRefreshing()
            
            // 成功刷新数据的时候，不显示尾部，自动滑动加载
            mj_footer?.isHidden = true
        case .noMore:
            mj_header?.endRefreshing()
            addFooter()
            mj_footer?.endRefreshing()
            mj_footer?.endRefreshingWithNoMoreData()
            
            // 没有更多数据的时候才显示刷新尾
            mj_footer?.isHidden = false
        case .empty:
            mj_header?.endRefreshing()
            mj_footer?.endRefreshing()
            mj_footer = nil
        case .error:
            // 单纯取消刷新
            mj_header?.endRefreshing()
            mj_footer?.endRefreshing()
        }
    }
    
    
    func addHeader() {
        if self.mj_header == nil {
            self.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self]  in guard let self = self else { return }
                print("头部刷新事件")
                self.headerRefreshEvent.onNext((0))
            })
        }
    }
    
    func addFooter() {
        // 尾部默认开始是隐藏的
        if self.mj_footer == nil {
            self.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {[weak self]  in guard let self = self else { return }
                print("尾部刷新事件")
                self.footerRefreshEvent.onNext((1))
            })
        }
    }
    
  
}



class TTAutoRefreshTableView: TTTableView,TTAutoRefreshProtocol {
    var headerRefreshEvent = PublishSubject<Int>()
    var footerRefreshEvent = PublishSubject<Int>()
    var state: TTAutoRefreshState = .empty  {
        didSet {
            refreshHeaderOrFooterState(self.state)
        }
    }
    
    // 根据状态初始化
    init(cellClassNames: [String], style: UITableView.Style = .plain,state: TTAutoRefreshState) {
        super.init(cellClassNames: cellClassNames, style: style)
        
        self.state = state
        self.refreshHeaderOrFooterState(state)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
