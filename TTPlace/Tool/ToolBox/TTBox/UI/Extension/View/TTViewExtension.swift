//
//  TTViewExtension.swift
//  HotDate
//
//  Created by Mr.hong on 2020/8/24.
//  Copyright © 2020 刘超. All rights reserved.
//

import Foundation
extension UIView {
    // 倒圆角
    func settingCornerRadius(_ radius: CGFloat) {
       self.layer.cornerRadius = radius
       self.layer.masksToBounds = true
    }
    
    
    class func color(_ color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
    // 获取一个容器
    class func fetchContainerViewWithRadius(radius: CGFloat,color: UIColor,size: CGSize) -> UIView {
        let view = UIView()
        if radius > 0 {
            return fetchImageViewContainerViewWithRadius(radius: radius, color: color, size: size)
        }else{
            view.backgroundColor = color
        }
        view.size = size
        
        // 这样写,并不会引起离屏渲染,同时设置maskTobounds才会T
        view.layer.cornerRadius = radius
        return view
    }
    
    
    // 获取一个ImageView容器,不会离屏渲染
     class func fetchImageViewContainerViewWithRadius(radius: CGFloat,color: UIColor,size: CGSize) -> UIImageView {
        let view = UIImageView.empty()
        view.isUserInteractionEnabled = true

        if radius > 0 {
            if let image = UIImage.init(color: color,size: size)?.byRoundCornerRadius(radius) {
                view.image = image
            }
        }else {
            view.backgroundColor = color
        }
        view.size = size
        view.layer.cornerRadius = radius
        return view
    }
    
    
    //MARK: - 导一半圆角
    func halfRadius() {
        self.cornerRadius = self.size.height / 2
    }
}


