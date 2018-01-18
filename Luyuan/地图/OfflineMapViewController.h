//
//  OfflineMapViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/2.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface OfflineMapViewController : BaseViewController<BMKMapViewDelegate,BMKOfflineMapDelegate>

{
    BMKMapView* _mapView;//.xib里要有BMKMapView类用于初始化数据驱动
    BMKOfflineMap* _offlineMap;
    
    
    NSMutableArray* _arrayHotCityData;//热门城市
    NSMutableArray* _arrayOfflineCityData;//全国支持离线地图的城市
    NSMutableArray * _arraylocalDownLoadMapInfo;//本地下载的离线地图
    NSMutableDictionary *_showDic;//用来判断分组展开与收缩的
    NSMutableDictionary *_cellshowDic;//用来判断cell的收缩的
}


@end
