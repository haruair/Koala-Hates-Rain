//
//  ButtonNode.m
//  Wet Koala
//
//  Created by ed on 14/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import "ButtonNode.h"

@interface ButtonNode()
@property (nonatomic, readonly, assign) CGSize size;
@end

@implementation ButtonNode
{
    SKTexture * _defaultTexture;
    SKTexture * _touchedTexture;
    SKSpriteNode * _button;
    AnonBlock _returnMethod;
}

@synthesize size = _size;

+ (void)removeButtonPressed:(NSArray *)nodes {
    for (SKNode * node in nodes) {
        if ([node isKindOfClass:[self class]]) {
            ButtonNode * button = (ButtonNode *) node;
            [button didActionDefault];
        }
    }
}

+ (BOOL)isButtonPressed:(NSArray *)nodes {
    BOOL pressed = NO;
    for (SKNode * node in nodes) {
        if ([node isKindOfClass:[self class]]) {
            ButtonNode * button = (ButtonNode *) node;
            if ([button actionForKey:@"button-touched"]) {
                pressed = YES;
            }
        }
    }
    return pressed;
}

+(void) doButtonsActionBegan:(SKNode *)node touches:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![ButtonNode isButtonPressed:[node children]]) {
        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInNode:node];
        SKNode * targetNode = [node nodeAtPoint:location];
        
        if ([node isEqual:targetNode.parent]) {
            [targetNode touchesBegan:touches withEvent:event];
        }else{
            [targetNode.parent touchesBegan:touches withEvent:event];
        }
    }
}

+(void) doButtonsActionEnded:(SKNode *)node touches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:node];
    SKNode * targetNode = [node nodeAtPoint:location];
    
    if ([node isEqual:targetNode.parent]) {
        [targetNode touchesEnded:touches withEvent:event];
    }else{
        [targetNode.parent touchesEnded:touches withEvent:event];
    }
    [ButtonNode removeButtonPressed:[node children]];
}

-(id) initWithDefaultTexture:(SKTexture *) defaultTexture andTouchedTexture:(SKTexture *)touchedTexture {
    self = [super init];
    if (self) {
        _returnMethod = ^{};
        
        _defaultTexture = defaultTexture;
        _touchedTexture = touchedTexture;
        
        _button = [SKSpriteNode spriteNodeWithTexture:_defaultTexture];
        [_button runAction:
         [SKAction repeatActionForever:
          [SKAction animateWithTextures:@[_defaultTexture]
                           timePerFrame:10.0f
                                 resize:YES
                                restore:YES]] withKey:@"button-default"];
        
        [self addChild:_button];
        
        _size = _button.size;
    }
    return self;
}

-(SKAction *)actionForKey:(NSString *)key {
    return [_button actionForKey:key];
}

-(void)removeActionForKey:(NSString *)key {
    [_button removeActionForKey:key];
}

-(void) setMethod:(void (^)()) returnMethod {
    _returnMethod = returnMethod;
}

-(void) runMethod {
    _returnMethod();
}

-(void) didActionTouched {
    if ([_button actionForKey:@"button-touched"]) {
        [_button removeActionForKey:@"button-touched"];
    }
    [_button runAction:
     [SKAction repeatActionForever:
      [SKAction animateWithTextures:@[_touchedTexture]
                       timePerFrame:10.0f
                             resize:YES
                            restore:YES]] withKey:@"button-touched"];
    
}

-(void) didActionDefault {
    [_button removeActionForKey:@"button-touched"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self runAction:[SKAction playSoundFileNamed:@"button-in.m4a" waitForCompletion:NO]];
    [self didActionTouched];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self actionForKey:@"button-touched"]) {
        [self runAction:[SKAction playSoundFileNamed:@"button-out.m4a" waitForCompletion:NO]];
        [self runMethod];
    }
    [self didActionDefault];
}


@end