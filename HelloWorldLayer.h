//
//  HelloWorldLayer.h
//  playAir
//
//  Created by lcc on 13-8-23.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "FeoPlane.h"
#import "ChangeBullet.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    // 背景 -- 滚动
    CCSprite *BG1;
    CCSprite *BG2;
    NSInteger adjustmentBG;
    
    // 判断游戏是否结束
    BOOL isGameOver;
    
    // 玩家飞机
    CCSprite *player;
    
    // 飞机的子弹
    CCSprite *bullet;
    int bulletSpeed;//子弹速度
    
    //敌人飞机
    CCArray *foePlanes;
    int smallPlaneTime;//25毫秒出现一个敌人小飞机
    int mediumPlaneTime;//400毫秒出现一个敌人的中等飞机
    int bigPlaneTime;//每个1秒中出现一个敌人的打飞机
    
    //空降物品时间计数
    int propTime;
    //空降物品
    ChangeBullet *prop;
    //判断空间物品是否出去了
    BOOL isVisible;
    
    //得分
    CCLabelTTF *scoreLabel;
    int scoreInt;//得分
    
    //开始
    CCMenu *restart;
    
    //更换子弹
    BOOL isBigBullet;
    BOOL isChangeBullet;
    int bulletLastTime;//更换子弹持续的时间

    //游戏结束提示
    CCLabelTTF *gameOverLabel;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

//初始化数据
- (void) initData;

//背景
- (void) loadBackground;
- (void) scrollBackground;

//玩家飞机
- (void) loadPlayer;

//制造子弹 开火 移动
- (void) madeBullet;
- (void) firingBullets;
- (void) resetBullet;

//制造敌人飞机
- (void) addFeoPlane;
//制造小飞机
- (FeoPlane *) makeSmallFoePlane;
//制造中等飞机
- (FeoPlane *) makeMediumFoePlane;
//制造大飞机
- (FeoPlane *) makeBigFoePlane;

//飞机移动
- (void) moveFoePlane;

//碰撞检测
- (void) collisionDetection;

//添加空降物品
- (void) addBulletTypeTip;

//设置游戏属性
- (void) gamePause;
- (void) gameStart;

//子弹持续时间
- (void) bulletLastTime;

@end
