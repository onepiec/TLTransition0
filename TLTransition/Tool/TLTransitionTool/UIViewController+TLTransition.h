//
//  UIViewController+TLTransition.h
//  zhuanchang
//
//  Created by Mac on 2019/1/28.
//  Copyright © 2019年 tanglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLTransitionAnimationStyle.h"
#import "TLPanDirectionStyle.h"

//侧滑距离
#define TLPanEdgeInside 50

NS_ASSUME_NONNULL_BEGIN

#pragma mark UIViewController


@interface UIViewController (TLTransition)<UIScrollViewDelegate>

@property (nonatomic, assign) TLAnimationType animationType;
@property (nonatomic, assign) TLPanDirectionType panDirectionTypes;

- (void)tlPresentViewController:(UIViewController *)vc tlAnimationType:(TLAnimationType)tlAnimationType animated:(BOOL)animated completion:(void (^__nullable)(void))completion;

//重写ScrollViewDidScroll方法
- (void)tlScrollViewDidScroll:(UIScrollView *)scrollView;

//转场动画涉及的视图数组
- (NSArray *_Nonnull)tl_transitionUIViewFrameViews;

//TLTransition转场的图片
- (NSString *_Nonnull)tl_transitionUIViewImage;
@end



#pragma mark UINavigationController
@interface UINavigationController (TLTransition)

@property (nonatomic ,assign)BOOL   hideNavBar;
@property (nonatomic, assign) NSInteger index;

- (void)tlPushViewController:(UIViewController *)vc tlAnimationType:(TLAnimationType)tlAnimationType;


@end

NS_ASSUME_NONNULL_END
