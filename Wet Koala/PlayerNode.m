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
    SKShapeNode * _player;
    SKSpriteNode * _playerNode;
    SKShapeNode * _physicsNode;
    
    SKTexture * _defaultTexture;
    SKTexture * _endedTexture;
    SKTexture * _endedAdditionalTexture;
    NSArray * _animateTextures;
    CGPoint _location;
    CGVector _direction;
    CGVector _currentDirection;
    CGMutablePathRef _path;
}

-(id) initWithDefaultTexture:(SKTexture *)defaultTexture andAnimateTextures:(NSArray *)animateTextures {
    self = [super init];
    if (self) {
        
        self.isLive = YES;
        
        _defaultTexture = defaultTexture;
        _animateTextures = animateTextures;
        
        _direction = CGVectorMake(0.0, 0.0);
        _currentDirection = CGVectorMake(0.0, 0.0);
        
        _player = [[SKShapeNode alloc] init];
        _playerNode = [SKSpriteNode spriteNodeWithTexture:_defaultTexture];
        
        [_player addChild:_playerNode];
        
        [_playerNode runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:@[_defaultTexture]
                                             timePerFrame:0.1f
                                                   resize:YES
                                                  restore:YES]] withKey:@"player-default"];
        
        CGFloat offsetX = _playerNode.frame.size.width / 2 * _playerNode.anchorPoint.x;
        CGFloat offsetY = _playerNode.frame.size.height / 2 * _playerNode.anchorPoint.y;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 34 - offsetX, 45 - offsetY);
        CGPathAddLineToPoint(path, NULL, 35 - offsetX, 12 - offsetY);
        CGPathAddLineToPoint(path, NULL, 25 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 10 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 13 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 44 - offsetY);
        
        CGPathCloseSubpath(path);
        _path = path;
        
        _physicsNode = [[SKShapeNode alloc] init];
        _physicsNode.path = path;
        _physicsNode.lineWidth = 0.0;
        
        [_player addChild:_physicsNode];
        [self addChild:_player];

    }
    return self;
}

-(CGPoint) position {
    return _player.position;
}

-(void) setEndedTexture:(SKTexture *) endedTexture {
    _endedTexture = endedTexture;
}

-(void) setEndedAdditionalTexture:(SKTexture *) endedAdditionalTexture {
    _endedAdditionalTexture = endedAdditionalTexture;
}

-(void) setPhysicsBodyCategoryMask:(uint32_t) playerCategory andContactMask:(uint32_t) targetCategory {
    _physicsNode.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:_path];
    _physicsNode.physicsBody.allowsRotation = YES;
    _physicsNode.physicsBody.dynamic = YES;
    _physicsNode.physicsBody.categoryBitMask = playerCategory;
    _physicsNode.physicsBody.contactTestBitMask = targetCategory;
    _physicsNode.physicsBody.usesPreciseCollisionDetection = YES;
    _physicsNode.physicsBody.collisionBitMask = 0;
    
}

-(void) moved {
    if ([_playerNode actionForKey:@"player-walking"]) {
        [_playerNode removeActionForKey:@"player-walking"];
    }
    [_playerNode runAction:[SKAction repeatActionForever:
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
        [_playerNode insertChild:effect atIndex:0];
        [effect runAction:[SKAction sequence:@[[SKAction scaleBy:0.1 duration:0.0],
                                               [SKAction group:@[[SKAction fadeInWithDuration:0.1], [SKAction scaleBy:20.0 duration:0.2]]],
                                               [SKAction group:@[[SKAction fadeOutWithDuration:0.4]]],
                                               
                                               [SKAction runBlock:^{
            [effect removeFromParent];
            _playerNode.zPosition = 0.0;
        }]]]];
    }
    
    if (_endedTexture != nil) {
        [_playerNode runAction:[SKAction waitForDuration:0.2] completion:^{
            [_playerNode runAction:
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
    if ([_playerNode actionForKey:@"player-move"]) {
        return YES;
    }
    return NO;
}

-(void) stopped {
    _direction.dx = 0.0;
    _currentDirection.dx = 0.0;
    
    if ([_playerNode actionForKey:@"player-walking"]) {
        [_playerNode removeActionForKey:@"player-walking"];
    }
    if ([_player actionForKey:@"player-move"]) {
        [_player removeActionForKey:@"player-move"];
    }
}

-(void) directionUpdate:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    if (
        (
         (location.x > _player.position.x  + _playerNode.size.width / 3 ||
          location.x < _player.position.x - _playerNode.size.width / 3) &&
         _direction.dx == 0
         ) || (
         (location.x > _player.position.x  + _playerNode.size.width / 2 ||
          location.x < _player.position.x - _playerNode.size.width / 2) &&
         _direction.dx != 0
         )
        
        ) {
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
        
        if ((_currentDirection.dx < 0 && _player.position.x < _location.x) ||
            (_currentDirection.dx > 0 && _player.position.x > _location.x) ||
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
    if(_direction.dx * _playerNode.xScale < 0){
        _playerNode.xScale = - _playerNode.xScale;
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
