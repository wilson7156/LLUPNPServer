//
//  UPNPListViewController.m
//  LLUPNPServer_Example
//
//  Created by wilson on 2020/2/25.
//  Copyright © 2020 704110362@qq.com. All rights reserved.
//

#import "UPNPListViewController.h"
#import <LLUPNPServer/LLUPNPServer.h>
#import <AVFoundation/AVFoundation.h>
#import "LLAVMediaRenderViewController.h"

/*测试用例步骤
   1.测试是否可以正常播放、暂停、停止、获取时长、获取进度,设置音量到播放结束
   2.测试播放进度设置
   3.测试如果当前已经播放了，是否可以先停止当前的，再播放下一音视频
   4.测试如果当前设备结束了，是否可以停止播放回调
 */


@interface UPNPListViewController ()<LLUPNPDiscoverDelegate,UITableViewDataSource,UITableViewDelegate,LLUPNPAVMediaControlDelegate>

@property (nonatomic,strong) NSMutableArray *devicesArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) LLUPNPDiscover *discover;
@property (nonatomic,strong) LLUPNPAVMediaControl *mediaControl;

@end

@implementation UPNPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRefresh];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.discover = [[LLUPNPDiscover alloc] initWithType:LLUPNPDiscoverTypeDefault name:nil];
    self.discover.delegate = self;
    [self refresh];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    LLUPNPDevice *device = self.devicesArray[indexPath.row];
    cell.textLabel.text = device.deviceName;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    LLUPNPDevice *device = [self.devicesArray objectAtIndex:indexPath.row];
    
    LLAVMediaRenderViewController *viewController = [LLAVMediaRenderViewController new];
    viewController.device = device;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)setupRefresh {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)refresh {
    
    self.title = @"搜索中...";
    [self.discover discover];
}

- (void)discover:(LLUPNPDiscover *)discover didDiscoverDevices:(NSArray<LLUPNPDevice *> *)devices {
    
    self.title = @"UPNP服务设备";
    for (LLUPNPDevice * device in devices) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceName=%@",device.deviceName];
        NSArray *filterArray = [self.devicesArray filteredArrayUsingPredicate:predicate];
        if (filterArray.count == 0) {
            [self.devicesArray addObject:device];
            [self.tableView reloadData];
        }
    }
}

- (void)discover:(LLUPNPDiscover *)discover willDismissDevice:(LLUPNPDevice *)device {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceName=%@",device.deviceName];
    NSArray *filterArray = [self.devicesArray filteredArrayUsingPredicate:predicate];
    if (filterArray.count > 0) {
        [self.devicesArray removeObjectsInArray:filterArray];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)devicesArray {
    
    if (!_devicesArray) {
        _devicesArray = [NSMutableArray new];
    }
    return _devicesArray;
}

@end
