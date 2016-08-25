//
//  CVLayoutViewController.m
//  CoreVideo
//
//  Created by admin on 15/9/16.
//  Copyright (c) 2015年 yangyu   QQ：623240480. All rights reserved.
//

#import "CVLayoutViewController.h"
#import "VideoViewController.h"
#import "PlayListViewController.h"
#import "CVWebViewController.h"
#import "CVDisplayViewController.h"
#import "CVModuleProtocol.h"
#import "AppColorManager.h"
#import "GpsViewController.h"

@interface CVLayoutViewController ()<CVModuleProtocol>{
    VideoViewController     *videoVC ;
    CVWebViewController     *webVC ;
    PlayListViewController  *playlistVC;
    CVDisplayViewController *displayVC;
    GpsViewController       *gpsVC;
    
    
    NSRect globalView1Rect;
    NSRect globalView0Rect;
    NSRect globalView2Rect;
    
    NSRect leftView1Rect;
    NSRect leftView0Rect;
    
    NSRect rightView1Rect;
    NSRect rightView0Rect;
    
    BOOL videoZoomStateMAX;
    BOOL mapZoomStateMAX;
    
    CGFloat global_position0;
    CGFloat global_position1;
    
}
@property (weak) IBOutlet NSSplitView *globalSplitView;
@property (weak) IBOutlet NSSplitView *leftSplitView;
@property (weak) IBOutlet NSSplitView *rightSplitView;
@property (weak) IBOutlet NSView *gmapWebView;


@property (weak) IBOutlet NSView *playListView;
@property (weak) IBOutlet NSView *videoView;
@property (weak) IBOutlet NSView *displayView;
@property (weak) IBOutlet NSView *mapInfoView;




@end

@implementation CVLayoutViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowFullScreenChange:) name:notification_full_screen object:nil];
    
    
    [self.view setWantsLayer:YES];
    
    
    [self.view.layer setBackgroundColor:[[AppColorManager appBackgroundColor] CGColor]];
    
    videoZoomStateMAX=NO;
    mapZoomStateMAX=NO;
    
    // Do view setup here.
    
    displayVC =[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"displayVC"];
    
    webVC      =[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"webVC"];
    webVC.distanceDelegate=displayVC;
    webVC.zoomInOutDelegate=self;
    
    gpsVC=[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"gpsVC"];
    
    playlistVC =[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"playlistVC"];
    
    videoVC    =[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"videoVC"];
    
    videoVC.zoomInDelegate=self;
    videoVC.gpsDelegate=webVC;
    videoVC.speedDelegate=displayVC;
    videoVC.gpsInfoDelegate=playlistVC;       //gpsVC;
    videoVC.videoEndDelegate=playlistVC;
    
    
    
    //leftRect0:x:0.000000 y:0.000000 w:1013.000000 h:422.000000 leftRect1:x:0.000000 y:0.000000 w:1013.000000 h:328.000000 rightRect0:x:0.000000 y:0.000000 w:266.000000 h:423.000000 rightRect1:x:0.000000 y:0.000000 w:266.000000 h:327.000000
    
    
    
    
    
    [self.videoView addSubview:videoVC.view];
    [self.playListView addSubview:playlistVC.view];
    [self.mapInfoView addSubview:webVC.view];//gps
    [self.displayView addSubview:displayVC.view];
   // [self.gmapWebView addSubview:webVC.view];
    // self.displayView.hidden=YES;
     self.gmapWebView.hidden=YES;
    
    
    
    //[self updateViewLetfView0:_videoView view1:_displayView rightView0:_mapView view1:_playListView];
    [[[_globalSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1280,760)];//1014，760//840//1600,900//800
    [[[_globalSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,640,460)];//266
    [[[_globalSplitView subviews] objectAtIndex:2] setFrame:NSMakeRect(0,0,640,460)];
    
    [[[_leftSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1280,600)];
    [[[_leftSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,1280,160)];//220
    
    [[[_rightSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,680,320)];//460
    [[[_rightSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,600,440)];
    
    
    
    
    
    [_globalSplitView  setDelegate:self];
    [_leftSplitView    setDelegate:self];
    [_rightSplitView   setDelegate:self];
    
    
    
    
}

-(NSString *)currentSplitView:(NSSplitView *)splitview{
    if(splitview==_globalSplitView){
        return @"_globalSplitView";
    }else if(splitview==_leftSplitView){
        return @"_leftSplitView";
    }else if(splitview==_rightSplitView){
        return @"_rightSplitView";
    }
    return nil;
}
-(void)windowFullScreenChange:(NSNotification *)notification{
    global_position0=0;
    global_position1=0;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
    
    //NSLog(@"splitView %@ proposedMinimumPosition %f  dividerIndex %ld",[self currentSplitView:splitView],proposedMinimumPosition,dividerIndex);
    if(splitView==_globalSplitView){
        if(dividerIndex==1){
            if(global_position0>0){
                return global_position0;
            }
            global_position0=proposedMinimumPosition;
        }
    }
    
    return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    //NSLog(@"splitView %@ proposedMaximumPosition %f  dividerIndex %ld",[self currentSplitView:splitView],proposedMaximumPosition,dividerIndex);
    if(splitView==_globalSplitView){
        if(dividerIndex==0){
            if(global_position1>0){
                return global_position1;
            }
            global_position1=proposedMaximumPosition;
        }
    }
    
    return proposedMaximumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex{
    //NSLog(@"splitView %@ proposedPosition %f  dividerIndex %ld",[self currentSplitView:splitView],proposedPosition,dividerIndex);
    if(splitView==_globalSplitView){
        if(dividerIndex==0){
            return global_position0;
        }else if(dividerIndex==1){
            return global_position1;
        }
    }
    
    return proposedPosition;
}


- (void)splitViewWillResizeSubviews:(NSNotification *)notification{
    // NSLog(@"splitViewWillResizeSubviews %@",notification.userInfo);
    
}
- (void)splitViewDidResizeSubviews:(NSNotification *)notification{
    // NSArray *splitViews = [self.globalSplitView subviews];
    
    NSArray *leftViews  = [self.leftSplitView subviews];
    NSArray *rightViews = [self.rightSplitView subviews];
    
    NSView *map_webView=[[_globalSplitView subviews] objectAtIndex:2];
    
    
    
    NSView *leftView0=[leftViews objectAtIndex:0];
    NSView *leftView1=[leftViews objectAtIndex:1];
    
    NSView *rightView0=[rightViews objectAtIndex:0];
    NSView *rightView1=[rightViews objectAtIndex:1];
    
    
    [self updateViewLetfView0:leftView0 view1:leftView1 rightView0:rightView0 view1:rightView1 webView:map_webView];
    
    
    
    
}


-(void)updateViewLetfView0:(NSView *)leftView0 view1:(NSView *)leftView1 rightView0:(NSView *)rightView0 view1:(NSView *)rightView1 webView:(NSView *)map_webView{
    
    [self updateViewLetfRect0:leftView0.bounds rect1:leftView1.bounds rightRect0:rightView0.bounds rect1:rightView1.bounds mapRect:map_webView.bounds];
}

-(void)updateViewLetfRect0:(NSRect)leftRect0 rect1:(NSRect)leftRect1 rightRect0:(NSRect)rightRect0 rect1:(NSRect)rightRect1 mapRect:(NSRect)mRect{
    
    //NSLog(@"leftRect0:%@ leftRect1:%@ rightRect0:%@ rightRect1:%@",[self nsRectToString:leftRect0],[self nsRectToString:leftRect1],[self nsRectToString:rightRect0],[self nsRectToString:rightRect1]);
    
    
    [videoVC.view setFrame:leftRect0];
    [displayVC.view setFrame:leftRect1];
    
    [playlistVC.view setFrame:rightRect1];
    [gpsVC.view setFrame:rightRect0];
    
    
    
    [webVC.view setFrame:mRect];
    
    [webVC.webview setFrame:webVC.view.bounds];
    
}

-(NSString *)nsRectToString:(NSRect)rect{
    return [NSString stringWithFormat:@"x:%f y:%f w:%f h:%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view NS_AVAILABLE_MAC(10_6){
    return YES;
}


#pragma mark delegate Window Zoom IN Out

-(NSInteger)zoomInMapWindow:(NSInteger)state{
    if(videoZoomStateMAX||(!mapZoomStateMAX&&state==1)){
        state=0;
    }
    
    if(state==0){
        
        [[[_globalSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1014,760)];
        [[[_globalSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,0,0)];
        [[[_globalSplitView subviews] objectAtIndex:2] setFrame:NSMakeRect(0,0,532,760)];
        
        [[[_leftSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1014,540)];
        [[[_leftSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,1014,220)];
        
        [[[_rightSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,0,0)];
        [[[_rightSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,0,0)];
        mapZoomStateMAX=YES;
        videoZoomStateMAX=NO;
    }else{
        [[[_globalSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1014,760)];
        [[[_globalSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,266,760)];
        [[[_globalSplitView subviews] objectAtIndex:2] setFrame:NSMakeRect(0,0,266,760)];
        
        [[[_leftSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1014,540)];
        [[[_leftSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,1014,220)];
        
        [[[_rightSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,266,360)];
        [[[_rightSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,266,400)];
        mapZoomStateMAX=NO;
    }
    
    
    return state==0?1:0;
}
-(NSInteger)zoomInVideoPlayWindow:(NSInteger)state{
    
    if(mapZoomStateMAX||(!videoZoomStateMAX&&state==1)){
        state=0;
        [webVC reloadHtmlData];
    }
    
    if(state==0){
        
        [[[_globalSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1280,760)];
        [[[_globalSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,0,0)];
        [[[_globalSplitView subviews] objectAtIndex:2] setFrame:NSMakeRect(0,0,266,760)];
        
        [[[_leftSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1280,760)];
        [[[_leftSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,0,0)];
        
        [[[_rightSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,0,0)];
        [[[_rightSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,0,0)];
        videoZoomStateMAX=YES;
        mapZoomStateMAX=NO;
        
    }else{
//        [[[_globalSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1014,760)];
//        [[[_globalSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,266,760)];
//        [[[_globalSplitView subviews] objectAtIndex:2] setFrame:NSMakeRect(0,0,266,760)];
//        
//        [[[_leftSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1014,540)];
//        [[[_leftSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,1014,220)];
//        
//        [[[_rightSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,266,323)];
//        [[[_rightSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,266,437)];
        [[[_globalSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1280,760)];//1014，760//840//1600,900//800
        [[[_globalSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,640,460)];//266
        [[[_globalSplitView subviews] objectAtIndex:2] setFrame:NSMakeRect(0,0,640,460)];
        
        [[[_leftSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,1280,500)];
        [[[_leftSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,1280,160)];//220
        
        [[[_rightSplitView subviews] objectAtIndex:0] setFrame:NSMakeRect(0,0,680,460)];//460
        [[[_rightSplitView subviews] objectAtIndex:1] setFrame:NSMakeRect(0,0,600,400)];
        videoZoomStateMAX=NO;
        
    }
    
    return state==0?1:0;
}


@end


