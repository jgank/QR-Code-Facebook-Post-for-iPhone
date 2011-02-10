//
//  QRGenerator.m
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

#import "QRGenerator.h"

@implementation QRGenerator

@synthesize facebook = _facebook;
@synthesize appTitle, appCaption, appDescription, appID, tinyURL, QrChartURL, facebookAppID;
@synthesize remoteHostStatus;

-(id)initWithTitle:(NSString*)_title Caption:(NSString*)_caption Description:(NSString*)_description AppID:(NSString*)_appID FacebookAppID:(NSString*)_facebookAppID{
	if ([super init]) {
		appTitle = _title;
		appCaption = _caption;
		appDescription = _description;
		appID = _appID;
		facebookAppID = _facebookAppID;
		_permissions =  [[NSArray arrayWithObjects: @"read_stream", @"offline_access",nil] retain];
		_facebook = [[Facebook alloc] initWithAppId:facebookAppID];
	}
	return self;
}

-(void)generateQR {
	
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	remoteHostStatus = [reachability currentReachabilityStatus];
	
	if (remoteHostStatus == NotReachable) {
		NSLog(@"No internet connection");
	}
	else {
		NSString *linkShareLink = [NSString stringWithFormat:@"http://click.linksynergy.com/fs-bin/stat?id=z1T1SRTtDFU&offerid=146261&type=3&subid=0&tmpid=1826&RD_PARM1=http%%253A%%252F%%252Fitunes.apple.com%%252Fus%%252Fapp%%252Fid%@%%253Fmt%%253D8%%2526uo%%253D4%%2526partnerId%%253D30",self.appID];	
		NSString * encodedUrlString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						  NULL,
																						  (CFStringRef)linkShareLink,
																						  NULL,
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8 );
		linkShareLink = encodedUrlString;
		NSString *requestString = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",linkShareLink];
		NSLog(@"%@",requestString);
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestString]];
		NSString  *responseString = @"";
		[request startSynchronous];
		
		if ([request error]) 
		{
			NSLog(@"%@",[[request error] localizedDescription]);
		} 
		else if ([request responseString]) 
		{
			responseString = [request responseString];
			self.tinyURL = responseString;	 
			QrChartURL = [NSString stringWithFormat:@"http://chart.apis.google.com/chart?cht=qr&chl=%@&chs=120x120",tinyURL];
			[self postToFacebook];
		}
	}
}

-(void)postToFacebook {
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"Time 4 Dinner",@"text",@"http://yougank.com/time4dinner/redirect.php",@"href", nil], nil];
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
	
	
	NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								appTitle, @"name",
								appCaption, @"caption",
								appDescription, @"description",
								tinyURL, @"href",
								[NSArray arrayWithObjects:
								 [NSDictionary dictionaryWithObjectsAndKeys:
								  @"image", @"type",
								  @"http://www.gogle.com/", @"href",
								  QrChartURL, @"src",nil]
								 , nil ]
								,@"media", nil];
	
	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
								   nil];
	[NSMutableDictionary dictionaryWithObjectsAndKeys: facebookAppID, @"api_key", @"Share on Facebook", @"user_message_prompt", actionLinksStr, @"action_links", attachmentStr, @"attachment", nil];
	[_facebook dialog: @"stream.publish" andParams: params andDelegate:self]; 
	
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
	NSLog(@"fb did login");
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	NSLog(@"facebook did logout");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response");
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on the format of the API response.
 * If you need access to the raw response, use
 * (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	if ([result objectForKey:@"owner"]) {
		//[self.label setText:@"Photo upload Success"];
	} else {
		//[self.label setText:[result objectForKey:@"name"]];
	}
};

/**
 * Called when an error prevents the Facebook API request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"fberror");
	UIAlertView *failedAlertView = [[UIAlertView alloc] initWithTitle:@"Could not Connect to Facebook" message:@"Please try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[failedAlertView show];
	[failedAlertView release];
};

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
	NSLog(@"dialog complete");
}

- (void)dealloc {
    [super dealloc];
	[_facebook release]; _facebook = nil;
	[_permissions release]; _permissions = nil;
	[appTitle release]; appTitle = nil;
	[appCaption release]; appCaption = nil;
	[appDescription release]; appDescription = nil;
	[appID release]; appID = nil;
	[tinyURL release]; tinyURL = nil;
	[QrChartURL release]; QrChartURL = nil;
	[facebookAppID release]; facebookAppID = nil;
}

@end
