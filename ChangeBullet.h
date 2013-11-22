//
//  ChangeBullet.h
//  playAir
//
//  Created by lcc on 13-8-26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    propsTypeBomb = 4,
    propsTypeBullet = 5
} prosType;

@interface ChangeBullet : CCNode

@property (assign) CCSprite *prop;
@property (assign) prosType bulletType;

- (void) initWithType:(prosType) type;
- (void) propAnimation;

@end
