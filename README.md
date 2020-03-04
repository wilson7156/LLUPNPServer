# LLUPNPServer

这是使用UPNP协议可以实现iOS可以投屏的简单实现，使用比较简单.

1.搜索设备

LLDiscover *discover = [[LLDiscover alloc] initWithType:LLUPNPDiscoverTypeDefault name:nil];
[discover discover];
discover.delegage = self;
