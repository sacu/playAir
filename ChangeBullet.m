//
//  ChangeBullet.m
//  playAir
//
//  Created by lcc on 13-8-26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "ChangeBullet.h"


@implementation ChangeBullet

@synthesize prop,bulletType;

- (void) initWithType:(prosType) type
{
    self.bulletType = type;
    NSString *proKey = [NSString stringWithFormat:@"enemy%d_fly_1.png",type];
    self.prop = [CCSprite spriteWithSpriteFrameName:proKey];
    [self.prop setPosition:ccp(arc4random()%268 + 23,732)];
}

- (void) propAnimation
{
    id act1 = [CCMoveTo actionWithDuration:1 position:ccp(self.prop.position.x,250)];//移动到400像素位置
    id act2 = [CCMoveTo actionWithDuration:0.4 position:ccp(self.prop.position.x,252)];//停留一下
    id act3 = [CCMoveTo actionWithDuration:1 position:ccp(self.prop.position.x,732)];//回去
    id act4 = [CCMoveTo actionWithDuration:2 position:ccp(self.prop.position.x,-55)];//自由落下
    
    [self.prop runAction:[CCSequence actions:act1,act2,act3,act4, nil]];
}

@end
