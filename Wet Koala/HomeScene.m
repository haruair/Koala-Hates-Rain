//
//  HomeScene.m
//  Wet Koala
//
//  Created by ed on 13/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import "HomeScene.h"
#import "GameScene.h"

#import "ButtonNode.h"
#import "ViewController.h"

@implementation HomeScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

        SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"sprite"];
        
        SKSpriteNode * background = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"background"]];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:background];
        
        SKSpriteNode * title = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"text-logo"]];
        title.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 5 / 8);
        [self addChild:title];
        
        [title runAction:
         [SKAction repeatActionForever:
          [SKAction sequence:@[
                               [SKAction moveByX:0 y:-5 duration:0.3],
                               [SKAction moveByX:0 y:5 duration:0.3]
                               ]
           ]
          ]
         ];
        
        SKSpriteNode * copyright = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"text-copyright"]];
        copyright.position = CGPointMake(self.size.width / 2, self.size.height / 4 - 60);
        [self addChild:copyright];
        
        
        CGFloat buttonY = CGRectGetMidY(self.frame) / 2;
        
        SKTexture * startDefault = [atlas textureNamed:@"button-start-off"];
        SKTexture * startTouched = [atlas textureNamed:@"button-start-on"];
        
        ButtonNode * startButton = [[ButtonNode alloc] initWithDefaultTexture:startDefault andTouchedTexture:startTouched];
        startButton.position = CGPointMake(CGRectGetMidX(self.frame) - (startButton.size.width / 2 + 8), buttonY);
        
        [startButton setMethod: ^ (void) { [self startButtonPressed]; } ];
        [self addChild:startButton];
        
        SKTexture * scoreDefault = [atlas textureNamed:@"button-score-off"];
        SKTexture * scoreTouched = [atlas textureNamed:@"button-score-on"];
        
        ButtonNode * scoreButton = [[ButtonNode alloc] initWithDefaultTexture:scoreDefault andTouchedTexture:scoreTouched];
        scoreButton.position = CGPointMake(CGRectGetMidX(self.frame) + (scoreButton.size.width / 2 + 8), buttonY);
        
        [scoreButton setMethod: ^ (void) { [self scoreButtonPressed]; } ];
        [self addChild:scoreButton];

        
        SKTexture * musicDefault = [atlas textureNamed:@"button-music-off"];
        SKTexture * musicTouched = [atlas textureNamed:@"button-music-on"];
        
        ButtonNode * musicButton = [[ButtonNode alloc] initWithDefaultTexture:musicDefault andTouchedTexture:musicTouched];
        
        if(self.frame.size.height > 500.0){
            musicButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                               buttonY + scoreButton.size.height);
        }else{
            musicButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                               CGRectGetMinY(self.frame) + musicButton.size.height * 2 / 3);
        }
        [musicButton setMethod: ^ (void) {
            ViewController * viewController = (ViewController *) self.view.window.rootViewController;
            [viewController switchSound];
        }];
        
        [self addChild:musicButton];
        
    }
    return self;
}

-(void) startButtonPressed {
    SKTransition * reveal = [SKTransition fadeWithDuration: 0.5];
    SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:myScene transition:reveal];
}

-(void) scoreButtonPressed {
    ViewController * viewController = (ViewController *) self.view.window.rootViewController;
    [viewController showGameCenterLeaderBoard];
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [ButtonNode doButtonsActionEnded:self touches:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [ButtonNode doButtonsActionBegan:self touches:touches withEvent:event];
}


@end
