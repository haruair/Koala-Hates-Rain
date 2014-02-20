//
//  PlayerNode.m
//  Wet Koala
//
//  Created by ed on 16/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import "PlayerNode.h"

@interface PlayerNode()
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@end

@implementation PlayerNode
{
    SKSpriteNode * _player;
    SKTexture * _defaultTexture;
    SKTexture * _endedTexture;
    SKTexture * _endedAdditionalTexture;
    NSArray * _animateTextures;
    CGPoint _location;
    CGVector _direction;
    CGVector _currentDirection;
}

-(id) initWithDefaultTexture:(SKTexture *)defaultTexture andAnimateTextures:(NSArray *)animateTextures {
    self = [super init];
    if (self) {
        _defaultTexture = defaultTexture;
        _animateTextures = animateTextures;
        
        _direction = CGVectorMake(0.0, 0.0);
        _currentDirection = CGVectorMake(0.0, 0.0);
        
        _player = [SKSpriteNode spriteNodeWithTexture:_defaultTexture];
        self.isLive = YES;
        
        [self addChild:_player];
        
        [_player runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:@[_defaultTexture]
                                             timePerFrame:0.1f
                                                   resize:YES
                                                  restore:YES]] withKey:@"player-default"];
        
    }
    return self;
}

-(void) setEndedTexture:(SKTexture *) endedTexture {
    _endedTexture = endedTexture;
}

-(void) setEndedAdditionalTexture:(SKTexture *) endedAdditionalTexture {
    _endedAdditionalTexture = endedAdditionalTexture;
}

-(void) setPhysicsBodyCategoryMask:(uint32_t) playerCategory andContactMask:(uint32_t) targetCategory {
    _player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_player.size.width/3];
    _player.physicsBody.dynamic = YES;
    _player.physicsBody.categoryBitMask = playerCategory;
    _player.physicsBody.contactTestBitMask = targetCategory;
    _player.physicsBody.usesPreciseCollisionDetection = YES;
    _player.physicsBody.collisionBitMask = 0;
    
}

-(void) moved {
    if ([_player actionForKey:@"player-walking"]) {
        [_player removeActionForKey:@"player-walking"];
    }
    [_player runAction:[SKAction repeatActionForever:
                        [SKAction animateWithTextures:_animateTextures
                                         timePerFrame:0.1f
                                               resize:YES
                                              restore:YES]] withKey:@"player-walking"];
}

-(void) ended {
    self.isLive = NO;
    
    [self runAction:[SKAction playSoundFileNamed:@"wet.m4a" waitForCompletion:NO]];
    
    if (_endedAdditionalTexture != nil) {
        
        SKSpriteNode * effect = [SKSpriteNode spriteNodeWithTexture:_endedAdditionalTexture];
        effect.alpha = 0.0;
        [_player insertChild:effect atIndex:0];
        [effect runAction:[SKAction sequence:@[[SKAction scaleBy:0.1 duration:0.0],
                                               [SKAction group:@[[SKAction fadeInWithDuration:0.1], [SKAction scaleBy:20.0 duration:0.2]]],
                                               [SKAction group:@[[SKAction fadeOutWithDuration:0.4]]],
                                               
                                               [SKAction runBlock:^{
            [effect removeFromParent];
            _player.zPosition = 0.0;
        }]]]];
    }
    
    if (_endedTexture != nil) {
        [_player runAction:[SKAction waitForDuration:0.2] completion:^{
            [_player runAction:
             [SKAction repeatActionForever:
              [SKAction animateWithTextures:@[_endedTexture]
                               timePerFrame:0.1f
                                     resize:YES
                                    restore:YES]] withKey:@"player-ended"];
            
        }];
    }
    [self stopped];
}

-(BOOL) isMoved {
    if ([_player actionForKey:@"player-move"]) {
        return YES;
    }
    return NO;
}

-(void) stopped {
    _direction.dx = 0.0;
    _currentDirection.dx = 0.0;
    
    if ([_player actionForKey:@"player-walking"]) {
        [_player removeActionForKey:@"player-walking"];
    }
    if ([_player actionForKey:@"player-move"]) {
        [_player removeActionForKey:@"player-move"];
    }
}

-(void) directionUpdate:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    if (location.x < _player.position.x  + 10.0 && location.x > _player.position.x - 10.0) {
        _direction.dx = 0.0;
    } else {
        _direction.dx = 0.0;
        if (location.x > _player.position.x) {
            _direction.dx = 1.0;
        }else if (location.x < _player.position.x) {
            _direction.dx = -1.0;
        }
        _location = location;
    }
}

-(void) checkLocation:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if(self.lastSpawnTimeInterval >= 1.0 / 60.0){
        self.lastSpawnTimeInterval = 0;
        
        if ((_currentDirection.dx < 0 && _player.position.x - 10 < _location.x) ||
            (_currentDirection.dx > 0 && _player.position.x + 10 > _location.x) ||
            (_direction.dx == 0 && _currentDirection.dx != 0)){
            [self stopped];
        }else if (_direction.dx != 0 && _direction.dx != _currentDirection.dx){
            [self updateMotion];
        }

    }
}

-(void) updateMotion {
    // set animation
    [self moved];
    
    // set direction and move
    CGPoint targetPoint = CGPointMake(0.0, 0.0);
    
    if(_direction.dx > 0){
        // go right
        targetPoint.x = self.parent.frame.size.width / 2;
    }else if(_direction.dx < 0){
        // go left
        targetPoint.x = - self.parent.frame.size.width / 2;
    }
    
    CGSize screenSize = self.parent.frame.size;
    
    float playerVelocity = screenSize.width / 1.3;
    CGPoint moveDifference = CGPointMake(targetPoint.x - _player.position.x, targetPoint.y - _player.position.y);
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    float moveDuration = distanceToMove / playerVelocity;

    
    SKAction * moveAction = [SKAction moveTo:targetPoint duration:moveDuration];
    SKAction * doneAction = [SKAction runBlock:(dispatch_block_t)^(){
        [self stopped];
    }];
    
    SKAction * moveActionWithDone = [SKAction sequence:@[moveAction, doneAction]];
    [_player runAction:moveActionWithDone withKey:@"player-move"];

    // turn direction
    if(_direction.dx * _player.xScale < 0){
        _player.xScale = - _player.xScale;
    }
    // override new direction
    _currentDirection = _direction;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.isLive){
        [self directionUpdate:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.isLive){
        [self directionUpdate:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.isLive){
        [self stopped];
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
    if (self.isLive) {
        [self checkLocation:timeSinceLast];
    }
}

@end
