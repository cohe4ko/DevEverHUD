//
//  TXActivityIndicator.h
//  TXActivityIndicator
//
//  Created by Ruslan Rezin on 29.04.13.
//  Copyright (c) 2013 Ruslan Rezin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXActivityIndicator : UIView{
    CALayer *_layerDisplay;
    UIImageView *_imageViewBackground;
    UIImageView *_imageViewRotationInternalWheel;
    UIImageView *_imageViewRotationExternalWheel;
    UIButton *_buttonClose;
    CGFloat _progress;
    CGFloat _currentRotationAngle;
    
    NSTimer *_timerRotation;
}

@property(nonatomic,readwrite)CGFloat progress;
@property(nonatomic,readonly)UIButton *buttonClose;

- (void)startAnimating;
- (void)stopAnimating;

@end
