#import "ViewController.h"
#import "KP_GoogleDriveModel.h"

static NSString *const kKeychainItemName = @"Google Drive Quickstart";
static NSString *const kClientID = @"706362330085-9sudluc2f0q38g84etjr5p0sv40gts4f.apps.googleusercontent.com";
static NSString *const kClientSecret = @"xYKzYzSZhbxNBtlgmebkv3KB";

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{

    self.kpGoogleDriveChooser = [[KP_GoogleDriveChooser alloc] initWithClientId:kClientID
                                                                andClientSecret:kClientSecret];


    self.kpGoogleDriveChooser.delegate = self;
}



-(IBAction)onGetRootFilesTapped:(id)sender
{
    [self presentViewController:self.kpGoogleDriveChooser
                       animated:YES
                     completion:nil];
}



- (void)KP_GoogleDriveChooser:(KP_GoogleDriveChooser *)kpGoogleDriveChooser fileChoosed:(NSDictionary *)fileInfo
{
    NSLog(@"%@", fileInfo);
    [kpGoogleDriveChooser dismissViewControllerAnimated:YES completion:nil];
}

- (void)KP_GoogleDriverChooserCanceled:(KP_GoogleDriveChooser *)kpGoogleDriveChooser
{
    [kpGoogleDriveChooser dismissViewControllerAnimated:YES completion:nil];
}




@end