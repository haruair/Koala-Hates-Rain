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
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKTextureAtlas * atlas;
@end

@implementation GameScene
{
    CounterHandler * _counter;
    NSArray * _waterDroppingFrames;
    PlayerNode * _player;
    
    SKSpriteNode * _ground;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        self.atlas = [SKTextureAtlas atlasNamed:@"sprite"];
        
        // set background
        SKSpriteNode * background = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"background"]];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild: background];
        
        // set cloud
        SKSpriteNode * cloudDark = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"cloud-dark"]];
        SKSpriteNode * cloudBright = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"cloud-bright"]];
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
        SKSpriteNode * ground = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"ground"]];
        ground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - ground.size.height / 4);
        ground.anchorPoint = CGPointMake(0.5, 0.0);
        [self addChild:ground];
        
        _ground = ground;
        
        // set count
        CounterHandler * counter = [[CounterHandler alloc] init];
        counter.position = CGPointMake(CGRectGetMidX(self.frame) + 105.0, ground.position.y + ground.size.height * 3 / 4 - 45.0);
        [self addChild:counter];
        _counter = counter;
        
        
        // set Koala Player
        NSMutableArray * _koalaAnimateTextures = [[NSMutableArray alloc] init];
        
        for (int i = 1; i <= 6; i++) {
            NSString * textureName = [NSString stringWithFormat:@"koala-walk-%d", i];
            SKTexture * texture = [self.atlas textureNamed:textureName];
            [_koalaAnimateTextures addObject:texture];
        }
        
        SKTexture * koalaTexture = [self.atlas textureNamed:@"koala-stop"];
        PlayerNode * player = [[PlayerNode alloc] initWithDefaultTexture:koalaTexture andAnimateTextures:_koalaAnimateTextures];
        player.position = CGPointMake(CGRectGetMidX(self.frame), ground.position.y + ground.size.height + koalaTexture.size.height / 2 - 15.0);
        [player setPhysicsBodyCategoryMask:koalaCategory andContactMask:rainCategory];
        [self addChild: player];
        _player = player;
        
        // set Rain Sprite
        NSMutableArray * _rainTextures = [[NSMutableArray alloc] init];
        
        for (int i = 1; i <= 4; i++) {
            NSString * textureName = [NSString stringWithFormat:@"rain-%d", i];
            SKTexture * texture = [self.atlas textureNamed:textureName];
            [_rainTextures addObject:texture];
        }
        
        _waterDroppingFrames = [[NSArray alloc] initWithArray: _rainTextures];

        
    }
    return self;
}

-(void) addRaindrop {

    SKTexture *temp = _waterDroppingFrames[0];
    SKSpriteNode * raindrop = [SKSpriteNode spriteNodeWithTexture:temp];
    int minX = raindrop.size.width / 2;
    int maxX = self.frame.size.width - raindrop.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    raindrop.name = @"raindrop";
    
    // set raindrop physicsbody
    raindrop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:raindrop.size];
    raindrop.physicsBody.dynamic = YES;
    raindrop.physicsBody.categoryBitMask = rainCategory;
    raindrop.physicsBody.contactTestBitMask = koalaCategory;
    raindrop.physicsBody.collisionBitMask = 0;
    
    raindrop.position = CGPointMake(actualX, self.frame.size.height + raindrop.size.height / 2);
    
    [raindrop runAction:[SKAction repeatActionForever:
                          [SKAction animateWithTextures:_waterDroppingFrames
                                           timePerFrame:0.1f
                                                 resize:YES
                                                restore:YES]] withKey:@"rainingWaterDrop"];
    
    [self addChild:raindrop];
    
    int minDuration = 1.0;
    int maxDuration = 2.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, _ground.position.y + _ground.size.height)
                                    duration:actualDuration];
    SKAction * countMove = [SKAction runBlock:^{
        [_counter increse];
    }];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [raindrop runAction:[SKAction sequence:@[actionMove, countMove, actionMoveDone]] withKey:@"rain"];
}

-(void) stopAllRaindrop{
    for (SKSpriteNode * node in [self children]) {
        if ([node actionForKey:@"rain"]) {
            [node removeActionForKey:@"rain"];
        }
    }
}

-(void) didBeginContact:(SKPhysicsContact *) contact {
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & rainCategory) != 0 &&
        (secondBody.categoryBitMask & koalaCategory) != 0) {
        [self player:(SKSpriteNode *) secondBody.node didCollideWithRaindrop:(SKSpriteNode *)firstBody.node];
    }
}

-(void) player:(SKSpriteNode *)playerNode didCollideWithRaindrop:(SKSpriteNode *)raindropNode {
    if (_player.isLive) {
        [self stopAllRaindrop];
        [_player ended];
    }
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

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    if(_player.isLive){
        self.lastSpawnTimeInterval += timeSinceLast;
        if(self.lastSpawnTimeInterval> 0.3){
            self.lastSpawnTimeInterval = 0;
            [self addRaindrop];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1.0) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    [_player update:currentTime];
}

@end
