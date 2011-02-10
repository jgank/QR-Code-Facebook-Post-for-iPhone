//
//  QRGenerator.h
//  QRGeneration
//
//  Created by Justin Knag on 2/7/11.
//  Copyright 2011 Knag Enterprises. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"

@interface QRGenerator : NSObject <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
	Facebook* _facebook;
	NSArray* _permissions;
	NSString *appTitle;
	NSString *appCaption;
	NSString *appDescription;
	NSString *appID;
	NSString *tinyURL;
	NSString *QrChartURL;
	NSString *facebookAppID;
	NetworkStatus internetConnectionStatus;
}

@property (readonly) Facebook *facebook;
@property (nonatomic,retain) NSString *appTitle;
@property (nonatomic,retain) NSString *appCaption;
@property (nonatomic,retain) NSString *appDescription;
@property (nonatomic,retain) NSString *appID;
@property (nonatomic,retain) NSString *tinyURL;
@property (nonatomic,retain) NSString *QrChartURL;
@property (nonatomic,retain) NSString *facebookAppID;
@property NetworkStatus remoteHostStatus;


-(id)initWithTitle:(NSString*)_title Caption:(NSString*)_caption Description:(NSString*)_description AppID:(NSString*)_appID FacebookAppID:(NSString*)_facebookAppID;
-(void)generateQR;
-(void)postToFacebook;

@end
