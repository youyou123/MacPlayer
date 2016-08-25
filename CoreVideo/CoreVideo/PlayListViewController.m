//
//  PlayListViewController.m
//  CoreVideo
//
//  Created by admin on 15/9/14.
//  Copyright (c) 2015年 yangyu   QQ：623240480. All rights reserved.
//

#import "PlayListViewController.h"
#import "MyCache.h"
#import "AppUtils.h"
#import "AppDelegate.h"
#import "AppColorManager.h"
@interface PlayListViewController (){
    NSInteger selectIndex;
    //gps
    NSMutableArray *currentVideoGpsDataArr;
    NSString       *currentPlayVideoPath;
    Float64         totalTime;
    //gps
    //spd
    NSMutableArray *currentSpeedDataArr;
    //spd
}

@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)addVideoPlay:(id)sender;
- (IBAction)removeVideoPlay:(id)sender;

@property (weak) IBOutlet NSTableHeaderView *headerView;

@property (weak) IBOutlet NSButton *buttonAdd;
@property (weak) IBOutlet NSButton *buttonRemove;

@property(nonatomic,strong) NSMutableArray *playlist;
//==================north  lal
@property (weak) IBOutlet NSImageView *northAngleImageViews;
//@property (weak) IBOutlet NSTextField *stillImageViews;
@property (weak) IBOutlet NSImageView *stillImageViewss;

@property (weak) IBOutlet NSTextField *latitudeLabels;
@property (weak) IBOutlet NSTextField *latitudeUnitLabels;
@property (weak) IBOutlet NSTextField *longitudeUnitLabels;
@property (weak) IBOutlet NSTextField *longitudeLabels;

//==================north  lal
//spd
@property (weak) IBOutlet NSImageView *spdArrowChange;
@property (weak) IBOutlet NSTextField *spdshow;
@property (weak) IBOutlet NSImageView *spdImage;

//spd

@end

@implementation PlayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    [self.buttonAdd  setTitle:@"ADD"];
    [self.buttonRemove  setTitle:@"REMOVE"];
    [self setButtonColor:_buttonAdd andColor:[NSColor greenColor]];
    [self setButtonColor:_buttonRemove andColor:[NSColor redColor]];
    
    self.latitudeLabels.hidden=YES;
    self.latitudeUnitLabels.hidden=YES;
    self.longitudeLabels.hidden=YES;
    self.longitudeUnitLabels.hidden=YES;
    
    
    [self.tableView setBackgroundColor:[NSColor blackColor
                                        ]];
    
    [self.tableView.headerView setFrame:NSZeroRect];
    [self.tableView setHeaderView:nil];
    
    
    [self.tableView setFocusRingType:NSFocusRingTypeNone];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    
    
    [self.tableView setRowSizeStyle:NSTableViewRowSizeStyleCustom];
    
    
    
    if(_tableView.headerView==_headerView){
        NSLog(@"YES");
        
        
    }else{
        NSLog(@"NO");
    }
    
    
    
    AppDelegate *delegate=[[NSApplication sharedApplication] delegate];
    delegate.playlistVC=self;
    self.playlist=[NSMutableArray new];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    
    selectIndex=-1;
   
    
}

- (IBAction)addVideoPlay:(id)sender {
    
    [[NSDocumentController sharedDocumentController] beginOpenPanelWithCompletionHandler:^(NSArray *fileList) {
        NSLog(@"%@",fileList);
        if(fileList!=nil&&[fileList count]>0){
            [MyCache playPathArrCache:fileList block:^{
                [self reloadPlayListData];
                //如果有数据，默认选中第一行并请求第一行的数据
                [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
                [self selectIndexPlay:0];
                
            }];
        }
        
    }];
    
    
    
}

- (IBAction)removeVideoPlay:(id)sender {
    NSLog(@"selectIndex : %ld",selectIndex);
    if(_playlist!=nil){
        if(selectIndex>=0&&selectIndex<[_playlist count]){
            [_playlist removeObjectAtIndex:selectIndex];
            [MyCache syncPlayList:_playlist];
            
            AppDelegate *delegate=[[NSApplication sharedApplication] delegate];
            [delegate.videoVC close];
        }
        if (selectIndex<0) {
            [MyCache  playPathClear];
        }
        [self reloadPlayListData];
        [_tableView deselectAll:self];
    }
    selectIndex=-1;
}


-(void)reloadPlayListData{
    self.playlist=[[MyCache playList] mutableCopy];
    [_tableView reloadData];
    
    
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(_playlist!=nil){
        return [_playlist count];
    }else{
        return 0;
    }
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(_playlist!=nil){
        NSString *abbrev=[NSString stringWithFormat:@"%ld:%@",row,[self abbreviationFile:[[_playlist objectAtIndex:row] objectForKey:keyPATH]]];
        
        NSNumber *activeYN=[[_playlist objectAtIndex:row] objectForKey:keyActiveYN];
        
        
        if(activeYN!=nil&&[activeYN boolValue]==YES){
            [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            selectIndex=row;
//            [_tableView.cell setBackgroundColor:[NSColor redColor
//                                                 ]];
            
        }
        
        return [abbrev stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        return @"";
    }
    
}

-(NSString *)abbreviationFile:(NSString *)path{
    
    return [path lastPathComponent];
}


- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes NS_AVAILABLE_MAC(10_5){
    
    
    selectIndex=proposedSelectionIndexes.firstIndex;
    
    
    [self selectIndexPlay:selectIndex];
    
    return proposedSelectionIndexes;
}

-(void)playNext:(BOOL)isNext{
    if(isNext){
        selectIndex++;
    }else{
        selectIndex--;
    }
    
    [self selectIndexPlay:selectIndex];
    
}
-(void)selectIndexPlay:(NSInteger)index{
    NSLog(@"weishrrnmnmrnm--------------");
    if(index<[_playlist count]){
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [self playCurrentItem:[[_playlist objectAtIndex:index] objectForKey:keyPATH]];
        
        AppDelegate *delegate=[[NSApplication sharedApplication] delegate];
        [delegate activeCurrentPlayIndex:index];
    }else{
        selectIndex=-1;
    }
    
    [self reloadPlayListData];
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    NSLog(@"%@",tableColumn);
}


-(void)playCurrentItem:(NSString *)path{
    AppDelegate *delegate=[[NSApplication sharedApplication] delegate];
    [delegate.videoVC close];
    
    [delegate.videoVC initAssetData:[NSURL URLWithString:path]];
}
- (void)setButtonColor:(NSButton *)button andColor:(NSColor *)color {
    if (color == nil) {
        color = [NSColor redColor];
    }
    
    int fontSize = 16;
    NSFont *font = [NSFont systemFontOfSize:fontSize];
    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:font,
                            NSFontAttributeName,
                            color,
                            NSForegroundColorAttributeName,
                            
                            nil];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[button title] attributes:attrs];
    [attributedString setAlignment:NSRightTextAlignment range:NSMakeRange(0, [attributedString length])];
    
    [button setAttributedTitle:attributedString];
    
}

-(void)videoEnd{
    NSLog(@"video over...");
    
    [self selectIndexPlay:(++selectIndex)];
    
}
//add gps
-(void)updateDataByCurrentTime:(Float64)time{
    float m_ratio=1.0;
    float spd_ratio=1.0;
    if(totalTime>0){
        m_ratio= [currentVideoGpsDataArr count]/totalTime;
        spd_ratio=[currentSpeedDataArr count]/totalTime;//spd change/time
    }
    
    int index=(int)time*m_ratio;
    int index1=(int)time*spd_ratio;
    
    if(currentVideoGpsDataArr!=nil&&[currentVideoGpsDataArr count]>0){
        if(index<[currentVideoGpsDataArr count]){
            NSArray *xyItem=currentVideoGpsDataArr[index];
            
            if ([xyItem[0] floatValue]<0) {
                _longitudeUnitLabels.stringValue=@"W";
            }else{
                _longitudeUnitLabels.stringValue=@"E";
            }
            if ([xyItem[1] floatValue]<0) {
                _latitudeUnitLabels.stringValue=@"S";
            }else{
                _latitudeUnitLabels.stringValue=@"N";
            }
            
            _longitudeLabels.stringValue=[self convertLatLngToDFM:[xyItem[0] floatValue]<0?-[xyItem[0] floatValue]:[xyItem[0] floatValue]];
            
            _latitudeLabels.stringValue=[self convertLatLngToDFM:[xyItem[1] floatValue]<0?-[xyItem[1] floatValue]:[xyItem[1] floatValue]];
            
            
            [self  rotateAngle:[xyItem[2] floatValue]/180*M_PI];///180*M_PI
            
        }
    }
    if(currentSpeedDataArr!=nil&&[currentSpeedDataArr count]>0){
        if(index<[currentSpeedDataArr  count]){
            NSArray *xyItem=currentSpeedDataArr[index];
            
            if(xyItem[0]>0){
                
                [self.spdshow setStringValue:[AppUtils convertSpeedUnit:([xyItem[0] floatValue])]];
                NSString  *spdSouce=self.spdshow.stringValue;
                
                
                if ([spdSouce rangeOfString:@"KM/H"].location == NSNotFound) {
                    NSString *spdString = [spdSouce stringByReplacingOccurrencesOfString:@"MPH" withString:@""];//字符串替换
                    [self  rotateSpd:[spdString floatValue]/95*M_PI];
                    NSLog(@"---------------------------mph-");
                    [ self.spdImage  setImage:[NSImage imageNamed:@"spdimage"]];
                    [self.spdArrowChange setImage:[NSImage imageNamed:@"spdarrow"]];
                    
                }
                if ([spdSouce rangeOfString:@"MPH"].location == NSNotFound) {
                    NSString *spdString = [spdSouce stringByReplacingOccurrencesOfString:@"KM/H" withString:@""];//字符串替换
                    [self  rotateSpd:[spdString floatValue]/150*M_PI];
                         NSLog(@"----------------/////-----------kmh-");
                    [ self.spdImage  setImage:[NSImage imageNamed:@"speedbackset"]];
                        [self.spdArrowChange setImage:[NSImage imageNamed:@"3"]];
                }
                
                
            }else{
                
                [self.spdshow setStringValue:[AppUtils convertSpeedUnit:(0.0)]];
            }
            
            
        }
    }
    
    
    
    
}
static float val=0.0;

-(void)rotateAngle:(float)angle{
    
    
    float xval=self.stillImageViewss.frame.origin.x+self.stillImageViewss.frame.size.width/2;
    float yval=self.stillImageViewss.frame.origin.y+self.stillImageViewss.frame.size.height/2;
    
    self.stillImageViewss.layer.position=CGPointMake(xval, yval);
    
    CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    self.stillImageViewss.layer.anchorPoint=CGPointMake(0.5, 0.5);
    self.stillImageViewss.layer.transform=transform;
    
    
    
}
-(void)rotateSpd:(float)angle{
    
    
    float xval=self.spdArrowChange.frame.origin.x+self.spdArrowChange.frame.size.width/2;
    float yval=self.spdArrowChange.frame.origin.y+self.spdArrowChange.frame.size.height/2;
    
    self.spdArrowChange.layer.position=CGPointMake(xval, yval);
    
    CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, -1);
    self.spdArrowChange.layer.anchorPoint=CGPointMake(0.5, 0.5);
    self.spdArrowChange.layer.transform=transform;
    
    
    
}

-(NSString *)convertLatLngToDFM:(float)latlng{
    int d_int=(int)latlng;
    float f_float=(latlng-d_int)*60;
    int f_int=(int)f_float;
    float m_float=(f_float-f_int)*60;
    return [NSString stringWithFormat:@"%3d°%3d'    %.2f",d_int,f_int,m_float];
}

-(void)videoAllTime:(Float64)allTime{
    totalTime=allTime;
}


-(void)dataLogicProcessOfViodePath:(NSString *)playVideoPath{
    
    currentPlayVideoPath=playVideoPath;
    
    
    
    NSArray *gpsDataArr=[MyCache findGpsDatas:currentPlayVideoPath];
    
    currentVideoGpsDataArr=[NSMutableArray new];
    currentSpeedDataArr=[NSMutableArray new];
    [gpsDataArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *spd=[obj objectForKey:@"spd"];
        
        //  [self  rotateAngle:[xyItem[2] floatValue]/140*M_PI];///180*M_PI
        
        NSString *gps_lat=[obj objectForKey:@"gps_lat"];
        NSString *gps_lgt=[obj objectForKey:@"gps_lgt"];
        
        NSNumber *north_angle=[obj objectForKey:@"north_angle"];
        
        
        if(gps_lat.floatValue!=0&&gps_lgt.floatValue!=0){
            
            [currentVideoGpsDataArr addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:gps_lgt.floatValue],[NSNumber numberWithFloat:gps_lat.floatValue],north_angle, nil]];
            
            
        }
        
        [currentSpeedDataArr addObject:[NSArray arrayWithObjects:spd, nil]];
        
        
        
        
        
    }];
    
}

//add gps location
//键盘监听事件===========
- (BOOL)tableView:(NSTableView *)tableView shouldTypeSelectForEvent:(NSEvent *)event withCurrentSearchString:(nullable NSString *)searchString NS_AVAILABLE_MAC(10_5){
    NSLog(@"play event***** %@",event);
    return NO;
}
-(void)keyDown:(NSEvent *)theEvent{
    NSLog(@"play list***** %@",theEvent);
    
    AppDelegate *delegate=[[NSApplication sharedApplication] delegate];
    [delegate.videoVC keyDown:theEvent];
    if([theEvent modifierFlags] & NSCommandKeyMask)
    {
        NSString* theString = [theEvent charactersIgnoringModifiers];
        if([theString characterAtIndex:0] == 'A' || [theString characterAtIndex:0] == 'a')
        {
            
            [self.tableView selectAll:self];
            
        }
    
}
}
//键盘监听事件==============

@end
