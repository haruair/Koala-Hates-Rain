//
//  GameScene.m
//  Wet Koala
//
//  Created by ed on 12/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import "GameScene.h"
#import "CounterHandler.h"
#import "PlayerNode.h"
#import "ButtonNode.h"

static const uint32_t rainCategory     =  0x1 << 0;
static const uint32_t koalaCategory    =  0x1 << 1;

@interface GameScene()  <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation GameScene
{
    CounterHandler * _counter;
    PlayerNode * _player;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"sprite"];
        
        // set background
        SKSpriteNode * background = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"background"]];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild: background];
        
        // set cloud
        SKSpriteNode * cloudDark = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"cloud-dark"]];
        SKSpriteNode * cloudBright = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"cloud-bright"]];
        cloudDark.anchorPoint = CGPointMake(0.5, 1.0);
        cloudBright.anchorPoint = CGPointMake(0.5, 1.0);
        cloudDark.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        cloudBright.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        [self addChild:cloudBright];
        [self addChild:cloudDark];
        
        
        SKAction * cloudMoveUpDown = [SKAction repeatActionForever:
                                         [SKAction sequence:@[
                                                              [SKAction moveByX:0.0 y:30.0 duration:2.5],
                                                              [SKAction moveByX:0.0 y:-30.0 duration:2.5]
                                                           ]]];
        SKAction * cloudMoveLeftRight = [SKAction repeatActionForever:
                                         [SKAction sequence:@[
                                                              [SKAction moveByX:30.0 y:0.0 duration:3.0],
                                                              [SKAction moveByX:-30.0 y:0.0 duration:3.0]
                                                           ]]];

        [cloudBright runAction:cloudMoveUpDown];
        [cloudDark   runAction:cloudMoveLeftRight];
        
        // set ground
        SKSpriteNode * ground = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"ground"]];
        ground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - ground.size.height / 4);
        ground.anchorPoint = CGPointMake(0.5, 0.0);
        [self addChild:ground];
        
        // set count
        CounterHandler * counter = [[CounterHandler alloc] init];
        counter.position = CGPointMake(CGRectGetMidX(self.frame) + 105.0, ground.position.y + ground.size.height * 3 / 4 - 45.0);
        [self addChild:counter];
        _counter = counter;
        
        
        // set Koala Player
        NSMutableArray * _koalaAnimateTextures = [[NSMutableArray alloc] init];
        
        for (int i = 1; i <= 6; i++) {
            NSString * textureName = [NSString stringWithFormat:@"koala-walk-%d", i];
            SKTexture * texture = [atlas textureNamed:textureName];
            [_koalaAnimateTextures addObject:texture];
        }
        
        SKTexture * koalaTexture = [atlas textureNamed:@"koala-stop"];
        PlayerNode * player = [[PlayerNode alloc] initWithDefaultTexture:koalaTexture andAnimateTextures:_koalaAnimateTextures];
        player.position = CGPointMake(CGRectGetMidX(self.frame), ground.position.y + ground.size.height + koalaTexture.size.height / 2 - 15.0);
        [player setPhysicsBodyCategoryMask:koalaCategory andContactMask:rainCategory];
        [self addChild: player];
        _player = player;
        
    }
    return self;
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [ButtonNode doButtonsActionEnded:self touches:touches withEvent:event];
    [_player touchesEnded:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_player touchesMoved:touches withEvent:event];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [ButtonNode doButtonsActionBegan:self touches:touches withEvent:event];
    [_player touchesBegan:touches withEvent:event];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1.0) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [_player update:currentTime];
}

@end
