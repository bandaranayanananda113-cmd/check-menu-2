//
//  PubgLoad.mm
//  pubg
//

#import "PubgLoad.h"
#import <UIKit/UIKit.h>

#import "JHPP.h"
#import "JHDragView.h"
#import "ImGuiLoad.h"
#import "ImGuiDrawView.h"

#include <iostream>
#include <string>
#include <dobby.h> // Dobby Library එක

// Original fopen එක hold කරගන්න pointer එක
static FILE *(*orig_fopen)(const char *path, const char *mode) = NULL;

// File path එක හොරෙන්ම වෙනස් කරන අපේ අලුත් fopen function එක
FILE *my_fopen(const char *path, const char *mode) {
    if (path != NULL) {
        std::string filePath(path);
        
        // Game එක FreeFire.app/Data කියවනවද බලනවා
        if (filePath.find("FreeFire.app/Data") != std::string::npos) {
            
            // App එකේ Documents folder එකේ path එක dynamic විදිහට ලබා ගැනීම
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            
            // monite.zip එක extract වුණු folder එකේ path එක සකස් කිරීම
            // (උදාහරණයක් ලෙස Documents folder එක ඇතුළේ 'monite' කියලා folder එකක් හැදෙනවා නම්)
            NSString *cleanDataPath = [documentsDirectory stringByAppendingPathComponent:@"monite"];
            
            std::string redirectedPath([cleanDataPath UTF8String]);
            
            // Clean path එකට redirect කිරීම
            return orig_fopen(redirectedPath.c_str(), mode);
        }
    }
    return orig_fopen(path, mode);
}

// Game එක open වෙද්දීම මේ constructor එක ඇතුළේදී hook එක active වෙනවා
__attribute__((constructor)) static void initializeBypass() {
    DobbyHook((void *)fopen, (void *)my_fopen, (void **)&orig_fopen);
}

@interface PubgLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@end

@implementation PubgLoad

static PubgLoad *extraInfo;
UIWindow *mainWindow;

+ (void)load
{
    [super load];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         mainWindow = [UIApplication sharedApplication].keyWindow;
        extraInfo =  [PubgLoad new];
        [extraInfo initTapGes];
        [extraInfo tapIconView];
        [extraInfo initTapGes2];
        [extraInfo tapIconView2];
    });
}

-(void)initTapGes
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 3;
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView)];
}

-(void)initTapGes2
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 2;
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView2)];
}

-(void)tapIconView2
{
     if (!_vna) {
         ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
         _vna = vc;
     }
     [ImGuiDrawView showChange:false];
     [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
}

-(void)tapIconView
{
     if (!_vna) {
         ImGuiDrawView *vc = [[ImGuiDrawView alloc] init];
         _vna = vc;
     }
     [ImGuiDrawView showChange:true];
     [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
}
@end