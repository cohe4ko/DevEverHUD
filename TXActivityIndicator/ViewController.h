//
//  ViewController.h
//  TXActivityIndicator
//
//  Created by Ruslan Rezin on 29.04.13.
//  Copyright (c) 2013 Ruslan Rezin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXActivityIndicator.h"
#import "MBProgressHUD.h"

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    TXActivityIndicator *activityIndicator;
    MBProgressHUD *_progressHud;
}

@end
