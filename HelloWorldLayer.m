//
//  HelloWorldLayer.m
//  playAir
//
//  Created by lcc on 13-8-23.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

#define WINDOWHEIGHT [[UIScreen mainScreen] bounds].size.height

// HelloWorldLayer implementation
@implementation HelloWorldLayer

- (void) dealloc
{
    [BG1 release];
    [BG2 release];
    
    [player release];
    [bullet release];
    
    [foePlanes release];
    [scoreLabel release];
    
    [scoreLabel release];
    
    [prop release];
    
    [gameOverLabel release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark - 系统默认
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]))
    {
        //播放音乐
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3" loop:YES];
        
        //初始化数据
        [self initData];
        
        //载入背景
        [self loadBackground];
        
        //载入玩家
        [self loadPlayer];
        
        isVisible = NO;
        
        //加入子弹
        [self madeBullet];
        [self resetBullet];
        
		[self scheduleUpdate];
	}
	return self;
}

#pragma mark -
#pragma mark - 游戏属性 得分 开始 结束等等
- (void) gamePause
{
    if (isGameOver == NO)
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        
        CCMenuItemFont *gameOverItem = [CCMenuItemFont itemFromString:@"START GAME" target:self selector:@selector(gameStart)];
        [gameOverItem setFontName:@"MarkerFelt-Thin"];
        [gameOverItem setFontSize:30];
        restart = [CCMenu menuWithItems:gameOverItem, nil];
        [restart setPosition:ccp(160, WINDOWHEIGHT/2)];
        [self addChild:restart z:4];

        isGameOver = YES;
    }
    else
    {
        [prop stopAllActions];
    }
}

- (void) gameStart
{
    if (isGameOver == YES)
    {
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        [self removeChild:restart cleanup:YES];
        isGameOver = NO;
    }
}

- (void) restart
{
    [self removeAllChildrenWithCleanup:YES];
    [foePlanes removeAllObjects];
    [self initData];
    [self loadBackground];
    [self loadPlayer];
    [self madeBullet];
    [self resetBullet];
}

- (void) gameOver {
    
    isGameOver = YES;

    [self gamePause];
    
    gameOverLabel = [CCLabelTTF labelWithString:@"GameOver" fontName:@"MarkerFelt-Thin" fontSize:35];
    [gameOverLabel setPosition:ccp(160, 300)];
    [self addChild:gameOverLabel z:4];
    
    CCMenuItemFont *gameOverItem = [CCMenuItemFont itemFromString:@"restart" target:self selector:@selector(restart)];
    [gameOverItem setFontName:@"MarkerFelt-Thin"];
    [gameOverItem setFontSize:30];
    restart = [CCMenu menuWithItems:gameOverItem, nil];
    [restart setPosition:ccp(160, 200)];
    [self addChild:restart z:4];
}

#pragma mark -
#pragma mark - 发送子弹声音
- (void) playFireSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bullet.mp3"];
}

- (void) smallPlaneDownSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy1_down.mp3"];
}

- (void) bigPlaneOutSount
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy2_out.mp3"];
}

- (void) mediumPlaneDownSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy3_down.mp3"];
}

- (void) bigPlaneDownSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"enemy2_down.mp3"];
}

#pragma mark -
#pragma mark - 页面刷新
- (void) update:(ccTime) delta
{
    if (!isGameOver)
    {
        //移动背景
        [self scrollBackground];
        
        //子弹发射
//        [self firingBullets];
        
        //添加敌人飞机 移动飞机
        [self addFeoPlane];
        [self moveFoePlane];
        
        [self bulletLastTime];
        
        //碰撞检测
        [self collisionDetection];
        
        //添加空降物品
        [self addBulletTypeTip];
        
    }
}

#pragma mark -
#pragma mark - 初始化数据
- (void) initData
{
    adjustmentBG = 568;
    isGameOver = NO;
    //子弹初速度是25
    bulletSpeed = 25;
    
    //各种类型飞机出现的时间间隔
    smallPlaneTime = 0;
    mediumPlaneTime = 0;
    bigPlaneTime = 0;
    
    bulletLastTime = 1200;
    
    //空降物品计数
    propTime = 0;
    
    //得分计数
    scoreInt = 0;
    
    isBigBullet = YES;
    isChangeBullet = YES;
    
    //保存所有敌人飞机
    foePlanes = [CCArray array];
    [foePlanes retain];
}

#pragma mark -
#pragma mark - 添加移动的背景与移动背景
- (void) loadBackground
{
    BG1 = [CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    [BG1 setAnchorPoint:ccp(0.5,0)];
    [BG1 setPosition:ccp(160, 0)];
    [self addChild:BG1 z:0];
    
    BG2 = [CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    [BG2 setAnchorPoint:ccp(0.5,0)];
    [BG2 setPosition:ccp(160, adjustmentBG - 1)];
    [self addChild:BG2 z:0];
    
    [self setIsTouchEnabled:YES];
    
    scoreLabel = [CCLabelTTF labelWithString:@"0000"
                                  fontName:@"MarkerFelt-Thin"
                                    fontSize:20];
    [scoreLabel setColor:ccc3(0, 0, 0)];
    [scoreLabel setAnchorPoint:ccp(0, 1)];
    [scoreLabel setPosition:ccp(55, WINDOWHEIGHT - 15)];
    [self addChild:scoreLabel z:4];
    
    
    CCMenuItem *pauseMenuItem = [CCMenuItemImage
                                itemFromNormalImage:@"BurstAircraftPause.png" selectedImage:@"BurstAircraftPause.png"
                                 target:self selector:@selector(gamePause)];
    [pauseMenuItem setAnchorPoint:ccp(0, 1)];
    pauseMenuItem.position = ccp(10, WINDOWHEIGHT - 10);
    CCMenu *starMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
    starMenu.position = CGPointZero;
    [self addChild:starMenu z:4];
    starMenu.tag = 10;
}

//背景移动
- (void) scrollBackground
{
    adjustmentBG --;
    
    if (adjustmentBG <= 0)
    {
        adjustmentBG = 568;
    }
    
    [BG1 setPosition:ccp(160, adjustmentBG - 568)];
    [BG2 setPosition:ccp(160, adjustmentBG - 1)];
}

#pragma mark -
#pragma mark - 玩家飞机加载
- (void) loadPlayer
{
    //初始化飞机自身动画
    NSMutableArray *playerActionArray = [NSMutableArray array];
    for (int i = 1; i < 3; i++)
    {
        NSString *key = [NSString stringWithFormat:@"hero_fly_%d.png",i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [playerActionArray addObject:frame];
    }
    
    //将图片数据转化成动画，换帧时间间隔为0.1秒 飞机本身在动
    CCAnimation *animPlayer = [CCAnimation animationWithFrames:playerActionArray delay:0.1];
    //生成动画播放的行为对象
    id actPlayer = [CCAnimate actionWithAnimation:animPlayer];
    //清空飞机动画数据
    [playerActionArray removeAllObjects];
    
    //加载玩家飞机
    player = [[CCSprite alloc] initWithSpriteFrameName:@"hero_fly_1.png"];
    player.position = ccp(160, 50);
    [self addChild:player z:3];
    //给玩家加上重复的动画
    [player runAction:[CCRepeatForever actionWithAction:actPlayer]];
    
}

- (CGPoint)boundLayerPos:(CGPoint)newPos
{
    CGPoint retval = newPos;
    retval.x = player.position.x+newPos.x;
    retval.y = player.position.y+newPos.y;
    
    if (retval.x>=286) {
        retval.x = 286;
    }else if (retval.x<=33) {
        retval.x = 33;
    }
    
    if (retval.y >=WINDOWHEIGHT-50) {
        retval.y = WINDOWHEIGHT-50;
    }else if (retval.y <= 43) {
        retval.y = 43;
    }
    
    return retval;
}

//飞机随着手指移动
- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    //获取之前的活动点
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    //坐标转换
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    
    if (!isGameOver)
    {
        player.position = [self boundLayerPos:translation];
    }
}

#pragma mark -
#pragma mark - 子弹制造 发射子弹 还原子弹
- (void) madeBullet
{
//    bullet = [CCSprite spriteWithSpriteFrameName:(!isBigBullet)?@"bullet1.png":@"bullet2.png"];
//    bullet.anchorPoint = ccp(0.5, 0.5);
//    [self addChild:bullet];
//    [self playFireSound];
}

//重置子弹
- (void) resetBullet
{
//    if ((isBigBullet&&isChangeBullet) || (!isBigBullet&&isChangeBullet))
//    {
//        [bullet removeFromParentAndCleanup:NO];
//        [self madeBullet];
//        isChangeBullet = YES;
//    }
//    
//    
//    bulletSpeed = (WINDOWHEIGHT - (player.position.y + 50))/15;
//    
//    if (bulletSpeed<5)
//    {
//        bulletSpeed=5;
//    }
//    
//    bullet.position=ccp(player.position.x,player.position.y+50);
}

//开火
- (void) firingBullets
{
    bullet.position = ccp(bullet.position.x,bullet.position.y + bulletSpeed);
    if (bullet.position.y > WINDOWHEIGHT - 20)
    {
        [self resetBullet];
    }
    
}

#pragma mark -
#pragma mark - 添加敌人的飞机 小 中 大 飞机移动
//添加小飞机
- (void) addFeoPlane
{
    smallPlaneTime ++;
    mediumPlaneTime ++;
    bigPlaneTime ++;
    
    if (smallPlaneTime > 25)
    {
        FeoPlane *smallPlane = [self makeSmallFoePlane];
        [self addChild:smallPlane z:3];
        [foePlanes addObject:smallPlane];
        
        smallPlaneTime = 0;
    }
    
    if (mediumPlaneTime > 400)
    {
        FeoPlane *mediumPlane = [self makeMediumFoePlane];
        [self addChild:mediumPlane z:3];
        [foePlanes addObject:mediumPlane];
        
        mediumPlaneTime = 0;
    }
    
    if (bigPlaneTime > 700)
    {
        FeoPlane *bigPlane = [self makeBigFoePlane];
        [self addChild:bigPlane z:3];
        [foePlanes addObject:bigPlane];
        
        [self performSelector:@selector(bigPlaneOutSount) withObject:nil afterDelay:0.5];
        
        bigPlaneTime = 0;
    }
}

//制造小飞机
- (FeoPlane *) makeSmallFoePlane
{
    FeoPlane *smallPlane = [FeoPlane spriteWithSpriteFrameName:@"enemy1_fly_1.png"];
    [smallPlane setPosition:ccp((arc4random()%290) + 17,568)];
    [smallPlane setPlaneType:1];
    [smallPlane setHp:1];
    [smallPlane setSpeed:arc4random()%4 + 2];
    return smallPlane;
}

//制造中等飞机
- (FeoPlane *) makeMediumFoePlane
{
    FeoPlane *mediumPlane = [FeoPlane spriteWithSpriteFrameName:@"enemy3_fly_1.png"];
    [mediumPlane setPosition:ccp((arc4random()%280 + 23),568)];
    [mediumPlane setPlaneType:3];
    [mediumPlane setHp:15];
    [mediumPlane setSpeed:arc4random()%3 + 2];
    return mediumPlane;
}

//制造大飞机
- (FeoPlane *) makeBigFoePlane
{
    //打飞机有螺旋桨
    NSMutableArray *bigPlaneAnimationArr = [NSMutableArray array];
    for (int i = 1; i <= 2; i ++)
    {
        NSString *key = [NSString stringWithFormat:@"enemy2_fly_%i.png",i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [bigPlaneAnimationArr addObject:frame];
    }
    
    //将图片转化成动画序列 切换时间为 0.1秒
    CCAnimation *animation = [CCAnimation animationWithFrames:bigPlaneAnimationArr delay:0.1];
    //转成动画对象
    id animate = [CCAnimate actionWithAnimation:animation];
    //清空缓存的数组
    [bigPlaneAnimationArr removeAllObjects];
    
    //运行动画
    FeoPlane *bigPlane = [FeoPlane spriteWithSpriteFrameName:@"enemy2_fly_1.png"];
    [bigPlane setPosition:ccp((arc4random()%210 + 55),700)];
    [bigPlane setPlaneType:2];//大飞机
    [bigPlane setHp:25];//打二十下可以打爆
    [bigPlane setSpeed:arc4random()%2 + 2];
    [bigPlane runAction:[CCSequence actions:[CCRepeatForever actionWithAction:animate], nil]];
    
    return bigPlane;
    
}


//飞机移动
- (void) moveFoePlane
{
    for (FeoPlane *tmpPlane in foePlanes)
    {
        [tmpPlane setPosition:ccp(tmpPlane.position.x,tmpPlane.position.y - tmpPlane.speed)];
        if (tmpPlane.position.y < (-75))
        {
            [foePlanes removeObject:tmpPlane];
            [tmpPlane removeFromParentAndCleanup:NO];
        }
    }
}

#pragma mark -
#pragma mark - 更换子弹 制造空降物品
- (void) addBulletTypeTip
{
    propTime ++;
    
    if (propTime > 1500)
    {
        prop = [ChangeBullet node];
        [prop initWithType:arc4random()%2 + 4];
        [self addChild:prop.prop];
        [prop propAnimation];
        [prop retain];
        propTime = 0;
        isVisible = YES;
    }
}

//子弹持续时间
- (void) bulletLastTime
{
    if (isBigBullet)
    {
        if (bulletLastTime > 0)
        {
            bulletLastTime --;
        }
        else
        {
            bulletLastTime = 1200;
            isBigBullet = YES;
            isChangeBullet = YES;
        }
    }
}

#pragma mark -
#pragma mark - 添加飞机被打击的动画
- (void) hitAnimationToFoePlane:(FeoPlane *) feoPlane
{
    if (feoPlane.planeType == 3)
    {
        //中等飞机
        if (feoPlane.hp == 13)
        {
            NSMutableArray *frames = [NSMutableArray array];
            for (int i = 1; i <= 2; i ++)
            {
                NSString *key = [NSString stringWithFormat:@"enemy3_hit_%d.png",i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
                [frames addObject:frame];
            }
            
            CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1];
            id animate = [CCAnimate actionWithAnimation:animation];
            [frames removeAllObjects];
            //把之前动画停止
            [feoPlane stopAllActions];
            
            [feoPlane runAction:[CCRepeatForever actionWithAction:animate]];
        }
    }
    else
    {
        //大飞机
        if (feoPlane.hp == 20)
        {            
            NSMutableArray *frames = [NSMutableArray array];
            for (int i = 1; i <= 1; i ++)
            {
                NSString *key = [NSString stringWithFormat:@"enemy2_hit_%d.png",i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
                [frames addObject:frame];
            }
            
            CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1];
            id animate = [CCAnimate actionWithAnimation:animation];
            [frames removeAllObjects];
            //把之前动画停止
            [feoPlane stopAllActions];
            
            [feoPlane runAction:[CCRepeatForever actionWithAction:animate]];
        }
    }
}

#pragma mark -
#pragma mark - 自己的飞机爆炸
- (void) playerBlowupAnimation
{
    [player stopAllActions];
    
    NSMutableArray *foePlaneActionArray = [NSMutableArray array];
    
    for (int i = 1; i<=4 ; i++ ) {
        NSString* key = [NSString stringWithFormat:@"hero_blowup_%i.png", i];
        //从内存池中取出Frame
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        //添加到序列中
        [foePlaneActionArray addObject:frame];
    }
    
    //将数组转化为动画序列,换帧间隔0.1秒
    CCAnimation* animPlayer = [CCAnimation animationWithFrames:foePlaneActionArray delay:0.1f];
    //生成动画播放的行为对象
    id actFowPlane = [CCAnimate actionWithAnimation:animPlayer];
    id end = [CCCallFuncN actionWithTarget:self selector:@selector(blowupEnd:)];
    //清空缓存数组
    [foePlaneActionArray removeAllObjects];
    
    [player runAction:[CCSequence actions:actFowPlane,end, nil]];
}

#pragma mark -
#pragma mark - 碰撞检测
- (void) foePlaneBlowupAnimation:(FeoPlane *) foePlane
{
    int animationNum = 0;
    
    if (foePlane.planeType == 1)
    {
        animationNum = 4;
        scoreInt += 2000;
    }
    
    if (foePlane.planeType == 3)
    {
        animationNum = 4;
        scoreInt += 10000;
    }
    
    if (foePlane.planeType == 2)
    {
        animationNum = 7;
        scoreInt += 40000;
    }
    
    [scoreLabel setString:[NSString stringWithFormat:@"%d",scoreInt]];
    
    //首先飞机停止所有动画
    [foePlane stopAllActions];
    
    //动画集合--就是图片
    NSMutableArray *foeActionArr = [NSMutableArray array];
    for (int i = 1; i <= animationNum; i ++)
    {
        NSString *key = [NSString stringWithFormat:@"enemy%d_blowup_%i.png",foePlane.planeType,i];
        //取出图片
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        //加入集合中
        [foeActionArr addObject:frame];
    }
    
    //定义运行动画的属性
    CCAnimation *aniPlayer = [CCAnimation animationWithFrames:foeActionArr delay:0.1f];
    id actFowPlane = [CCAnimate actionWithAnimation:aniPlayer];
    id end = [CCCallFuncN actionWithTarget:self selector:@selector(blowupEnd:)];
    //清空缓存的数组
    [foeActionArr removeAllObjects];
    
    //动画运行
    [foePlane runAction:[CCSequence actions:actFowPlane,end, nil]];
    
    if (foePlane.planeType == 3)
    {
        [self mediumPlaneDownSound];
    }
    else if (foePlane.planeType == 2)
    {
        [self bigPlaneDownSound];
    }
    else if (foePlane.planeType == 1)
    {
        [self smallPlaneDownSound];
    }
}

- (void) blowupEnd:(id) sender
{
    FeoPlane *tmpPlane = (FeoPlane *)sender;
    [tmpPlane removeFromParentAndCleanup:NO];
}

- (void) collisionDetection
{
    //获取当前子弹所在矩形框
    CGRect bulletRect = bullet.boundingBox;
    for (FeoPlane *tmpPlane in foePlanes)
    {
        if (CGRectIntersectsRect(bulletRect, tmpPlane.boundingBox))
        {
            //子弹重设
            [self resetBullet];
            
            //判读敌人飞机是否还有血
            tmpPlane.hp = tmpPlane.hp - (isBigBullet?2:1);//一个子弹一滴血
            
            tmpPlane.hp = 0;
            if (tmpPlane.hp <= 0)
            {
                //运行爆炸动画
                [self foePlaneBlowupAnimation:tmpPlane];
                [foePlanes removeObject:tmpPlane];
            }
            else
            {
                //每个子弹都有打击效果 主要是中等飞机和大飞机
                [self hitAnimationToFoePlane:tmpPlane];
            }
        }
    }
    
    //检测敌人飞机是否撞到我
    CGRect playerRec = player.boundingBox;
    playerRec.origin.x += 25;
    playerRec.size.width -= 50;
    playerRec.origin.y -= 10;
    playerRec.size.height -= 10;
    for (FeoPlane *tmpPlane in foePlanes)
    {
        if (CGRectIntersectsRect(playerRec, tmpPlane.boundingBox))
        {
//            [self gameOver];
//            [self playerBlowupAnimation];
//            [self foePlaneBlowupAnimation:tmpPlane];
//            [foePlanes removeObject:tmpPlane];
            
            //运行爆炸动画
            [self foePlaneBlowupAnimation:tmpPlane];
            [foePlanes removeObject:tmpPlane];
        }
    }
    
    //判断飞机是否吃到空降物品
    if (isVisible == YES)
    {
        CGRect playerRect1 = player.boundingBox;
        CGRect propRect = prop.prop.boundingBox;
        
        if (CGRectIntersectsRect(playerRect1, propRect))
        {
            [prop.prop stopAllActions];
            [prop.prop removeFromParentAndCleanup:YES];
            isVisible = NO;
            
            if (prop.bulletType == propsTypeBullet)
            {
                isBigBullet = YES;
                isChangeBullet = YES;
            }
            else
            {
                for (FeoPlane *tmpPlane in foePlanes)
                {
                    [self foePlaneBlowupAnimation:tmpPlane];
                }
                [foePlanes removeAllObjects];
            }
            
        }
    }
    
}


@end
