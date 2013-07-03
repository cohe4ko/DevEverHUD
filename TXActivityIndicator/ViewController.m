//
//  ViewController.m
//  TXActivityIndicator
//
//  Created by Ruslan Rezin on 29.04.13.
//  Copyright (c) 2013 Ruslan Rezin. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    activityIndicator = [[TXActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    [activityIndicator.buttonClose addTarget:self
                                      action:@selector(actionCloseIndicator)
                            forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActivityIndicator{
    _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [_progressHud setCustomView:activityIndicator];
    [_progressHud setMode:MBProgressHUDModeCustomView];
    [_progressHud setDetailsLabelText:@"Загрузка..."];
    [self.view addSubview:_progressHud];
    [_progressHud show:YES];
    
    [activityIndicator startAnimating];
}

- (void)actionCloseIndicator{
    [activityIndicator stopAnimating];
    [_progressHud hide:YES];
}

#pragma mark - UITable

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Cell%d",indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showActivityIndicator];
}

@end
