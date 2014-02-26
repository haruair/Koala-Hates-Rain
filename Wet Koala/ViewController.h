//
//  ViewController.h
//  Wet Koala
//

//  Copyright (c) 2014 haruair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>

@interface ViewController : UIViewController

@property (nonatomic) BOOL gameCenterLogged;
@property (nonatomic) GKLocalPlayer * localPlayer;

- (void) showGameCenterLeaderBoard;

-(void) turnOffSound;
-(void) turnOnSound;
-(void) switchSound;
-(BOOL) isSound;

- (void) shareText:(NSString *)string andImage:(UIImage *)image;
- (void) reportScore: (int64_t) score;
@end
