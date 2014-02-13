//
//  CounterHandler.m
//  Wet Koala
//
//  Created by ed on 13/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import "CounterHandler.h"

@interface CounterHandler()

@end

@implementation CounterHandler
{
    NSArray * numberTexture;
    NSMutableArray * numbersNode;
    NSInteger count;
}

-(id) init {
    return [self initWithNumber:0];
}

-(id) initWithNumber:(NSInteger) initNumber {
    self = [super init];
    if (self) {
        
        // init number sprite
        SKTextureAtlas * numberAtlas = [SKTextureAtlas atlasNamed:@"sprite"];
        NSMutableArray * numberArray = [[NSMutableArray alloc] init];
        for (int i = 0; i <= 9; i++) {
            SKTexture * temp = [numberAtlas textureNamed:[NSString stringWithFormat:@"num-%d", i]];
            [numberArray addObject:temp];
        }
        numberTexture = [[NSArray alloc] initWithArray:numberArray];
        numbersNode = [[NSMutableArray alloc] init];
        
        // init number
        count = initNumber;
        [self updateCounter];
    }
    return self;
}

-(void) resetNumber {
    [self setNumber:0];
    [self clearCounter];
    [self updateCounter];
}

-(void) setNumber:(NSInteger)number {
    count = number;
    [self clearCounter];
    [self updateCounter];
}

-(NSInteger) getNumber {
    return count;
}

-(void) increse {
    count++;
    [self updateCounter];
}

-(void) clearCounter {
    for (SKSpriteNode * number in numbersNode) {
        [number removeFromParent];
    }
    [numbersNode removeAllObjects];
}
-(void) updateNumbersPosition {
    CGFloat x = 0.0;
    for (SKSpriteNode * number in numbersNode) {
        CGFloat y = number.position.y;
        number.position = CGPointMake(x, y);
        x -= number.size.width;
    }
}

-(void) updateCounter {
    
    NSInteger displayNumber = count;
    NSInteger digit;
    
    int figure = 0;
    
    if (displayNumber == 0) {
        [self addNumber:0 atIndex:0];
        return;
    }
    
    while (displayNumber) {
        digit = displayNumber % 10;
        displayNumber /= 10;
        
        NSString * numberName =[NSString stringWithFormat:@"number-%d", (int) digit];
        
        if (figure < [numbersNode count] && [numbersNode objectAtIndex:figure] != [NSNull null]) {
            SKSpriteNode * oldNumberNode = [numbersNode objectAtIndex:figure];
            if ([numberName isEqualToString:oldNumberNode.name]) {
                figure++;
                continue;
            }else{
                [oldNumberNode removeFromParent];
                [numbersNode removeObject:oldNumberNode];
            }
        }
        [self addNumber:digit atIndex:figure];
        figure++;
    }
    [self updateNumbersPosition];
}

-(void) addNumber:(NSInteger)digit atIndex:(int)index {
    NSString * numberName =[NSString stringWithFormat:@"number-%d", (int) digit];
    SKSpriteNode * number = [SKSpriteNode spriteNodeWithTexture: [numberTexture objectAtIndex:digit]];
    number.anchorPoint = CGPointMake(1.0, .0);
    number.name = numberName;
    
    [self addChild:number];
    [number runAction:[self getShowAction]];
    [numbersNode insertObject:number atIndex:index];
}

-(SKAction *) getShowAction {
    SKAction * act = [SKAction group:@[
                                       [SKAction scaleBy:1.1 duration:0.0],
                                       [SKAction scaleBy:1 duration:0.2]
                                       ]];
    return act;
}
@end
