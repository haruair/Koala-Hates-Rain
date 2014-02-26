//
//  PlayerNode.h
//  Wet Koala
//
//  Created by ed on 16/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PlayerNode : SKSpriteNode

@property (nonatomic) BOOL isLive;

-(id) initWithDefaultTexture:(SKTexture *)defaultTexture andAnimateTextures:(NSArray *)animateTextures;
-(CGPoint) position;
-(void) ended;
-(void) update:(CFTimeInterval)currentTime;
-(void) setPhysicsBodyCategoryMask:(uint32_t) playerCategory andContactMask:(uint32_t) targetCategory;
-(void) setEndedTexture:(SKTexture *) endedTexture;
-(void) setEndedAdditionalTexture:(SKTexture *) endedAdditionalTexture;
@end
