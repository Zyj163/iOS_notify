//
//  ViewController.m
//  IOS_Remote_Notify
//
//  Created by zhangyj on 16/3/18.
//  Copyright © 2016年 xitong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=PRIVACY&PATH=@"""]];
}


@end
