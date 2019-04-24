//
//  TLPressTransitionDelegate.m
//  TLTransition
//
//  Created by hello on 2019/4/12.
//  Copyright © 2019 tanglei. All rights reserved.
//

#import "TLPressTransitionDelegate.h"
#import "UIViewController+TLTransition.h"
#import "TLAnimationBottomViewAlert.h"

@interface TLPressTransitionDelegate ()

@property (nonatomic, assign) BOOL isInteraction;
@property (nonatomic, assign) BOOL isMiss;
@property (nonatomic, assign) CGFloat edgeLeftBeganFloat;//侧滑距离

@end

@implementation TLPressTransitionDelegate

+ (instancetype)shareInstance{
    
    static TLPressTransitionDelegate *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [TLPressTransitionDelegate new];
    });
    return _instance;
}
#pragma mark 是否识别多手势

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return self.panMix;
}
#pragma mark 系统手势
- (void)addEdgeLeftGestureForViewController:(UIViewController *)viewController{
    
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(doInteractiveTypeDisMiss:)];
    edgePan.edges = UIRectEdgeLeft;
    [viewController.view addGestureRecognizer:edgePan];
    
}
- (void)doInteractiveTypeDisMiss:(UIPanGestureRecognizer *)gesture{
    
    CGPoint  translation = [gesture translationInView:gesture.view];
    CGFloat percentComplete = 0.0;
    
    //左右滑动的百分比
    percentComplete = translation.x / UIScreen.mainScreen.bounds.size.width;
    percentComplete = fabs(percentComplete);
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            self.isInteraction = YES;
            [self.disMissController dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            self.isInteraction = NO;
            [self updateInteractiveTransition:percentComplete];
            break;
        case UIGestureRecognizerStateEnded:
            self.isInteraction = NO;
            if (percentComplete > 0.5f)
                [self finishInteractiveTransition];
            else
                [self cancelInteractiveTransition];
            break;
        default:
            self.isInteraction = NO;
            [self cancelInteractiveTransition];
            break;
    }
}
#pragma mark 自定义手势
- (void)addPanGestureForViewController:(UIViewController *)viewController directionTypes:(TLPanDirectionType)directionTypes{
    
    if (0 == directionTypes) return;
    
    viewController.panDirectionTypes = directionTypes;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doGestureRecognizerDisMiss:)];
    pan.delegate = self;
    [viewController.view addGestureRecognizer:pan];
    
}
- (void)doGestureRecognizerDisMiss:(UIPanGestureRecognizer *)gesture{
    
    CGFloat gestureHeight = UIScreen.mainScreen.bounds.size.height;
    if (TLAnimationBottomViewAlert == self.disMissController.animationType) {
        gestureHeight = TLTransitionPressHeight;
    }
    CGPoint  translation = [gesture translationInView:gesture.view];
    CGFloat percentCompleteX = 0.0;
    CGFloat percentCompleteY = 0.0;
    CGFloat percentComplete = 0.0;
    
    //左右滑动的百分比
    percentCompleteX = translation.x / UIScreen.mainScreen.bounds.size.width;
    percentCompleteX = fabs(percentCompleteX);
    
    //上下滑动的百分比
    percentCompleteY = translation.y / gestureHeight;
    percentCompleteY = fabs(percentCompleteY);
    
    TLPanDirectionType panDirection = TLPanDirectionNone;
    if (fabs(translation.x) > fabs(translation.y)) {
        if(translation.x > 0){
            
            panDirection = TLPanDirectionEdgeLeft;//右滑
        }else if(translation.x < 0){
            
            panDirection = TLPanDirectionEdgeRight;//左滑
        }
        percentComplete = percentCompleteX;
    }else{
        if (translation.y >0) {
            panDirection = TLPanDirectionEdgeUp;//下滑
        }else if(translation.y < 0){
            
            panDirection = TLPanDirectionEdgeDown;//上滑
        }
        percentComplete = percentCompleteY;
    }
    
    //转场进度动画处理
    [self handleGesture:gesture percentComplete:percentComplete directionType:panDirection];
}

- (void)handleGesture:(UIPanGestureRecognizer *)gesture percentComplete:(CGFloat)percentComplete directionType:(TLPanDirectionType)directionType{
    
    //对于不包含的手势禁止动画
    if (!(self.disMissController.panDirectionTypes &directionType)) {
        percentComplete = 0;
    }
    //向右滑动起始位置超出TLPanEdgeInside则失效
    if (TLPanDirectionEdgeLeft == directionType) {
        if (self.edgeLeftBeganFloat >TLPanEdgeInside) {
            percentComplete = 0;
        }
    }
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            
            [self gestureRecognizerStateBegan:gesture];
            break;
        case UIGestureRecognizerStateChanged:

            
            self.isInteraction = NO;
            [self updateInteractiveTransition:percentComplete];
            break;
        case UIGestureRecognizerStateEnded:
            
            [self gestureRecognizerStateEnded:gesture percentComplete:percentComplete directionType:directionType];            
            break;
        default:
            self.isInteraction = NO;
            [self cancelInteractiveTransition];
            break;
    }
}
- (void)gestureRecognizerStateBegan:(UIPanGestureRecognizer *)gesture{

    self.edgeLeftBeganFloat = [gesture locationInView:gesture.view].x;
    self.isInteraction = YES;
    [self.disMissController dismissViewControllerAnimated:YES completion:nil];
}
- (void)gestureRecognizerStateEnded:(UIPanGestureRecognizer *)gesture percentComplete:(CGFloat)percentComplete directionType:(TLPanDirectionType)directionType{
    
    if (percentComplete > 0.3f){
        [self finishInteractiveTransition];
    }else{
        [self cancelInteractiveTransition];
    }
    self.isInteraction = NO;

}
#pragma mark pres动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    self.isMiss = NO;
    if (TLAnimationBottomViewAlert == presented.animationType) {
        return [TLAnimationBottomViewAlertPress new];
    }
    
    return nil;
}
#pragma mark dis动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    self.isMiss = YES;
    if (TLAnimationBottomViewAlert == dismissed.animationType) {
        return [TLAnimationBottomViewAlertDiss new];
    }
    return nil;
}
#pragma mark 是否返回交互
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    
    if (self.isMiss) {
        return self.isInteraction ? self : nil;
    }
    return nil;
}
@end
