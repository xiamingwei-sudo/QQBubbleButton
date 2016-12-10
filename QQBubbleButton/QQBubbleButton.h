//
//  QQBubbleButton.h
//  QQBubbleButton
//
//  Created by 夏明伟 on 2016/12/8.
//  Copyright © 2016年 夏明伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QQBubbleButton : UIButton

/**
 大圆脱离小圆的最大距离
 */
@property (nonatomic ,assign)CGFloat maxDistance;

/**
 小圆
 */
@property (nonatomic , strong)UIView *smallCircleView;

/**
 按钮消失的动画数组
 */
@property (nonatomic , strong)NSMutableArray *images;

@end
