//
//  HomeViewController.h
//  HTPlace
//
//  Created by Mr.hong on 2020/9/8.
//  Copyright © 2020 Mr.hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTCommonTableViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController: HTCommonTableViewController
/**
 label
 */
@property(nonatomic, readwrite, strong)UILabel *tempLabel;

@end

NS_ASSUME_NONNULL_END