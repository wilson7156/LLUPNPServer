//
//  LLViewController.m
//  LLUPNPServer
//
//  Created by 704110362@qq.com on 02/19/2020.
//  Copyright (c) 2020 704110362@qq.com. All rights reserved.
//

#import "LLViewController.h"
#define DISPATCH_DECLS(name) typedef struct name##_s *name##_t
DISPATCH_DECLS(LL_Queue);

@interface LLViewController ()

@property (nonatomic,strong) NSMutableArray *devices;

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
