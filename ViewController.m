//
//  ViewController.m
//  CoreDataManager
//
//  Created by neolix on 14-8-6.
//  Copyright (c) 2014年 Neolix. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"
#import "Bus.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    for (int i = 0; i< 10; i++) {
        //插入
        [Bus insertItem_asyncWithBlock:^(Bus *item) {
            item.name = @"公家车";
            item.number = [NSString stringWithFormat:@"%d第几个",i];
        }];
    }
    //查询
    [Bus items_asyncSortDescriptions:nil withFormat:nil complete:^(NSMutableArray *items) {
        for (Bus *item in items) {
            NSLog(@"item===%@",item);
            //删除
            [item remove];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
