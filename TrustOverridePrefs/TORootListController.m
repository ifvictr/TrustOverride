#import <Foundation/Foundation.h>
#import "TORootListController.h"

@implementation TORootListController
- (NSArray*)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)openGitHubIssues {
	[[UIApplication sharedApplication]
		openURL:[NSURL URLWithString:@"https://github.com/ifvictr/TrustOverride/issues"]
		options:@{}
		completionHandler:nil];
}

- (void)openGitHubRepo {
	[[UIApplication sharedApplication]
		openURL:[NSURL URLWithString:@"https://github.com/ifvictr/TrustOverride"]
		options:@{}
		completionHandler:nil];
}

- (void)openTwitterProfile {
	[[UIApplication sharedApplication]
		openURL:[NSURL URLWithString:@"https://twitter.com/ifvictr"]
		options:@{}
		completionHandler:nil];
}
@end
