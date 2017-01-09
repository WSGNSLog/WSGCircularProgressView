//
//  CircularProgressView.h
//  WSGCircularProgressView
//
//  Created by wsg on 2017/1/6.
//  Copyright © 2017年 wsg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularProgressView : UIControl

@property (nonatomic) float progress;


@property (nonatomic, strong) UIColor *progressTintColor;

@property (nonatomic, strong) UILabel *centerLabel; /**< 记录进度的Label*/
@property (nonatomic, strong) UIColor *labelbackgroundColor; /**<Label的背景色 默认clearColor*/
@property (nonatomic, strong) UIColor *textColor; /**<Label的字体颜色 默认黑色*/
@property (nonatomic, strong) UIFont *textFont; /**<Label的字体大小 默认15*/

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
