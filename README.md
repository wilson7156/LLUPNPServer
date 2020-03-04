# LLUPNPServer

这是使用UPNP协议可以实现iOS可以投屏的简单实现，使用比较简单

搜索可以播放的设备使用 LLUPNPDiscover

LLUPNPDiscover *discover = [[LLUPNPDiscover alloc] initWithType:LLUPNPDiscoverTypeDefault name:nil];
    discover.delegate = self;
    [discover discover];
