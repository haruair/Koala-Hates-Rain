//
//  CounterHandler.h
//  Wet Koala
//
//  Created by ed on 13/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@interface CounterHandler : SKNode

-(CounterHandler *) initWithNumber:(NSInteger) initNumber;
-(void) setNumber:(NSInteger) number;
-(NSInteger) getNumber;

-(void) resetNumber;
-(void) increse;

@end
