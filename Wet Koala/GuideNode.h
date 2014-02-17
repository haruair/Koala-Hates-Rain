//
//  GuideNode.h
//  Wet Koala
//
//  Created by ed on 17/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef void (^AnonBlock)();

@interface GuideNode : SKSpriteNode
-(id) initWithTitleTexture:(SKTexture *)titleTexture andIndicatorTexture:(SKTexture *)indicatorTexture;
-(void) setMethod:(void (^)()) returnMethod;
-(void) runMethod;
@end
