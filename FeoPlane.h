//
//  FeoPlane.h
//  playAir
//
//  Created by lcc on 13-8-23.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//敌人飞机
@interface FeoPlane : CCSprite

//飞机的类型 1 小飞机  2 大飞机 3 中等飞机
@property (readwrite) int planeType;
//飞机的血 即能挨多少子弹
@property (readwrite) int hp;
//飞机的速度
@property (readwrite) int speed;

@end
