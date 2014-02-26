//
//  ViewController.m
//  Wet Koala
//
//  Created by ed on 12/02/2014.
//  Copyright (c) 2014 haruair. All rights reserved.
//

#import "ViewController.h"
#import "HomeScene.h"
#import "GameScene.h"

@import AVFoundation;

@interface ViewController() <GKGameCenterControllerDelegate>
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

@implementation ViewController
{
    NSString * _leaderboardIdentifier;
    NSUserDefaults * _settings;
}
- (void)viewWillLayoutSubviews
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        [self authenticateLocalPlayer];
        
        _settings = [NSUserDefaults standardUserDefaults];
        
        if([_settings objectForKey:@"sound"] == nil){
            [_settings setObject:@"YES" forKey:@"sound"];
        }
        
        NSString * musicPlaySetting = [_settings objectForKey:@"sound"];
        
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"bgm" withExtension:@"m4a"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];

        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        
        if ([musicPlaySetting isEqualToString:@"YES"]) {
            // Add Background Music
            [self.backgroundMusicPlayer play];
        }
        
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        self.gameCenterLogged = NO;
        
        // Create and configure the scene.
        
        SKScene * scene = [HomeScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
    

}

-(void) turnOffSound
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [self.backgroundMusicPlayer stop];
    [_settings setObject:@"NO" forKey:@"sound"];
}

-(void) turnOnSound
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [self.backgroundMusicPlayer play];
    [_settings setObject:@"YES" forKey:@"sound"];
}

-(void) switchSound
{
    if ([self isSound]) {
        [self turnOffSound];
    }else{
        [self turnOnSound];
    }
}

-(BOOL) isSound {
    NSString * musicPlaySetting = [_settings objectForKey:@"sound"];
    if ([musicPlaySetting isEqualToString:@"YES"]){
        return YES;
    }else{
        return NO;
    }
}

- (void) showGameCenterLeaderBoard
{
    if(self.gameCenterLogged){
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            [self presentViewController: gameCenterController animated: YES completion:nil];
        }
    }else{
        [self showAuthenticationDialogWhenReasonable];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showBannerWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [GKNotificationBanner showBannerWithTitle: title
                                      message: message
                            completionHandler: ^{}];
}

- (void) authenticateLocalPlayer
{
    GKLocalPlayer * localPlayer = [GKLocalPlayer localPlayer];
    self.localPlayer = localPlayer;
    
    __weak GKLocalPlayer * weakPlayer = localPlayer;
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (error) {
            // NSLog(@"%@",[error localizedDescription]);
        }
        
        if (viewController != nil)
        {
            [self showAuthenticationDialogWhenReasonable];
        }
        else if (weakPlayer.isAuthenticated)
        {
            [self authenticatedPlayer: weakPlayer];
        }
        else
        {
            [self disableGameCenter];
        }
    };
}

-(void) showAuthenticationDialogWhenReasonable {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
}

-(void) authenticatedPlayer:(GKLocalPlayer *) player {
    // NSLog(@"authenticatedPlayer");
    self.localPlayer = player;
    self.gameCenterLogged = YES;
    [self loadLeaderboardInfo];
    // [self showBannerWithTitle:@"Koala Hates Rain" andMessage:[NSString stringWithFormat:@"Welcome %@", self.localPlayer.displayName]];
}

-(void) disableGameCenter {
    // NSLog(@"disabled");
    self.gameCenterLogged = NO;
}

- (void) loadLeaderboardInfo
{
    [self.localPlayer loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
        _leaderboardIdentifier = leaderboardIdentifier;
    }];
}

- (void) reportScore: (int64_t) score {
    // NSLog(@"_leaderboardIdentifier %@",_leaderboardIdentifier);
    [self reportScore:score forLeaderboardID:_leaderboardIdentifier];
}

- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) identifier
{
    if(self.gameCenterLogged){
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        
        NSArray *scores = @[scoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            // NSLog(@"I sent your score %lld", score);
        }];
    }
}

- (void)shareText:(NSString *)string andImage:(UIImage *)image
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (string) {
        [sharingItems addObject:string];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
