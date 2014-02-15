//
//  ButtonNode.h
//  Wet Koala
//
//  Created by ed on 14/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef void (^AnonBlock)();

@interface ButtonNode : SKSpriteNode
-(id) initWithDefaultTexture:(SKTexture *) defaultTexture andTouchedTexture:(SKTexture *)touchedTexture;
-(void) setMethod:(void (^)()) returnMethod;
-(void) runMethod;
+(void) removeButtonPressed:(NSArray *) nodes;
+(BOOL) isButtonPressed:(NSArray *) nodes;
+(void) doButtonsActionBegan:(SKNode *)node touches:(NSSet *)touches withEvent:(UIEvent *)event;
+(void) doButtonsActionEnded:(SKNode *)node touches:(NSSet *)touches withEvent:(UIEvent *)event;
@end
