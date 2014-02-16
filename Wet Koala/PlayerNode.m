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
@property (nonatomic) BOOL isLive;
@end

@implementation PlayerNode
{
    SKSpriteNode * _player;
    SKTexture * _defaultTexture;
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

-(void) setPhysicsBodyCategoryMask:(uint32_t) playerCategory andContactMask:(uint32_t) targetCategory {
    _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.size];
    _player.physicsBody.dynamic = YES;
    _player.physicsBody.categoryBitMask = playerCategory;
    _player.physicsBody.contactTestBitMask = targetCategory;
    _player.physicsBody.collisionBitMask = 0;
    _player.physicsBody.usesPreciseCollisionDetection = YES;
    
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

-(BOOL) isMoved {
    if ([_player actionForKey:@"player-walking"]) {
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
    if (CGPointEqualToPoint(location, _player.position)) {
        return;
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

-(void) checkLocation {
    if (_location.x + 10 > _player.position.x && _location.x - 10 < _player.position.x){
        [self stopped];
    }else{
        [self updateMotion];
    }
}


-(void) updateMotion {
    if(_currentDirection.dx == _direction.dx){
        return;
    }else{
        // set animation
        [self moved];
        
        // set direction and move
        CGPoint targetPoint = CGPointMake(0.0, 0.0);
        
        if(_direction.dx > 0){
            targetPoint.x = self.parent.frame.size.width / 2;
        }else if(_direction.dx < 0){
            targetPoint.x = - self.parent.frame.size.width / 2;
        }
        
        CGSize screenSize = self.parent.frame.size;
        
        float playerVelocity = screenSize.width / 1.3;
        CGPoint moveDifference = CGPointMake(targetPoint.x - _player.position.x, targetPoint.y - _player.position.y);
        float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
        float moveDuration = distanceToMove / playerVelocity;
        
        [_player runAction:[SKAction moveTo:targetPoint duration:moveDuration] withKey:@"player-move"];
        
        // turn direction
        if(_direction.dx * _player.xScale < 0){
            _player.xScale = - _player.xScale;
        }
        // override new direction
        _currentDirection = _direction;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.isLive){
        [self moved];
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
        [self checkLocation];
    }
}

@end
