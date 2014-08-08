//
// Created by Kirill on 07.08.14.
// Copyright (c) 2014 Kirill Pyulzyu. All rights reserved.
//

#import "KP_GoogleDriveModel.h"


#define KP_GOOGLE_DRIVE_KEYCHAIN_KEY @"KP_GOOGLE_DRIVE_KEYCHAIN_KEY6"

@implementation KP_GoogleDriveModel
{
}



- (instancetype)initWithClientId:(NSString *)clientId clientSecretKey:(NSString *)clientSecretKey vcContext:(UIViewController *)vcContext {
    self = [super init];
    if (self) {
        self.clientId = clientId;
        self.clientSecretKey = clientSecretKey;
        self.vcContext = vcContext;


        // Initialize the drive service & load existing credentials from the keychain if available
        self.driveService = [[GTLServiceDrive alloc] init];
        self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:KP_GOOGLE_DRIVE_KEYCHAIN_KEY
                                                                                             clientID:self.clientId
                                                                                         clientSecret:self.clientSecretKey];


        if (![self isAuthorized])
        {
            // Not yet authorized, request authorization and push the login UI onto the navigation stack.
            [self.vcContext presentViewController:[self createAuthController]
                                         animated:YES completion:nil];
        }
        else
        {
            [self getRootFolder];
        }
    }

    return self;
}



// Helper to check if user is authorized
- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}



// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                clientID:self.clientId
                                                            clientSecret:self.clientSecretKey
                                                        keychainItemName:KP_GOOGLE_DRIVE_KEYCHAIN_KEY
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}


// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.driveService.authorizer = nil;
        [self.delegate authOrOperationCanceled];
    }
    else
    {
        [viewController dismissViewControllerAnimated:YES completion:nil];
        self.driveService.authorizer = authResult;
        [self getRootFolder];
    }
}



// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}



-(void)getRootFolder
{
    [self getFolderWithId:nil];
}


- (void)getFolderWithId:(NSString *)folderId
{
    [self.delegate willLoadData];

    NSString *parentId = folderId;
    if (!parentId)
        parentId = @"root";

    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];

    query.q = [NSString stringWithFormat:@"'%@' in parents", parentId];

    __weak KP_GoogleDriveModel *tempSelf = self;

    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error)
    {
        [tempSelf.delegate didLoadData];

        if (error == nil)
        {
            NSMutableArray *arrData = [NSMutableArray new];
            for (GTLDriveFile *file in files.items)
            {
                NSString *type = @"file";
                if([[[file.mimeType componentsSeparatedByString:@"."] lastObject] isEqualToString:@"folder"])
                    type = @"folder";


                NSNumber *fileSize = [NSNumber numberWithInt:0];
                if (file.fileSize)
                    fileSize = file.fileSize;


                [arrData addObject:@{
                        @"name":file.title,
                        @"size": fileSize,
                        @"type":type,
                        @"id":file.identifier,
                        @"publicLink":file.alternateLink
                }];
            }


            [arrData sortUsingComparator:^NSComparisonResult(NSDictionary * obj1, NSDictionary * obj2) {
                if ([obj1[@"type"] isEqual:@"folder"] && [obj2[@"type"] isEqual:@"file"])
                {
                    return NSOrderedAscending;
                }
                else if ([obj1[@"type"] isEqual:@"file"] && [obj2[@"type"] isEqual:@"folder"])
                {
                    return NSOrderedDescending;
                }
                else
                {
                    NSString *title1 = obj1[@"name"];
                    NSString *title2 = obj2[@"name"];

                    return [title1 compare:title2];
                }
            }];

            if (!folderId)
                [tempSelf.delegate didLoadRootFolderData:arrData];
            else
                [tempSelf.delegate didlLoadFolderWithId:folderId data:arrData];


        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
}



-(void)makeFilePublic:(NSString *)fileId
{
    [self.delegate willLoadData];


    __weak KP_GoogleDriveModel *tempSelf = self;


    [self insertPermissionWithService:self.driveService
                               fileId:fileId
                                value:@""
                                 type:@"anyone"
                                 role:@"reader"
                      completionBlock:^(GTLDrivePermission *permission, NSError *error)
                      {
                          if (!error)
                          {
                              [tempSelf.delegate didLoadData];
                              [tempSelf.delegate didMakeFilePublic:fileId];
                          }
                          else
                          {
                              [tempSelf.delegate authOrOperationCanceled];
                          }
                      }];
}



- (void)insertPermissionWithService:(GTLServiceDrive *)service
                             fileId:(NSString *)fileId
                              value:(NSString *)value
                               type:(NSString *)type
                               role:(NSString *)role
                    completionBlock:(void (^)(GTLDrivePermission* , NSError *))completionBlock {
    GTLDrivePermission *newPermission = [GTLDrivePermission object];
    // User or group e-mail address, domain name or nil for @"default" type.
    newPermission.value = value;
    // The value @"user", @"group", @"domain" or @"default".
    newPermission.type = type;
    // The value @"owner", @"writer" or @"reader".
    newPermission.role = role;

    GTLQueryDrive *query =
            [GTLQueryDrive queryForPermissionsInsertWithObject:newPermission
                                                        fileId:fileId];
    // queryTicket can be used to track the status of the request.
    GTLServiceTicket *queryTicket =
            [service executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                        GTLDrivePermission *permission, NSError *error) {
                    if (error == nil) {
                        completionBlock(permission, nil);
                    } else {
                        NSLog(@"An error occurred: %@", error);
                        completionBlock(nil, error);
                    }
                }];
}

@end