#import <Foundation/Foundation.h>
#import <Foundation/NSUserDefaults+Private.h>
#import <SpringBoard/SBApplicationInfo.h>
#import <SpringBoard/SBLeafIcon.h>
#import <UIKit/UIKit.h>

@interface FBSSignatureValidationService
- (NSInteger)trustStateForApplication:(SBApplicationInfo*)info;
@end

@interface SBApplication
- (NSString*)displayName;
- (SBApplicationInfo*)info;
@end

typedef NS_ENUM(NSInteger, TOAppPermission) {
	TOAppPermissionNever = 0,
	TOAppPermissionAllowOnce,
	TOAppPermissionAllow
};

static FBSSignatureValidationService* validationService = nil;
static NSInteger (*orig_trustStateForApplication)(FBSSignatureValidationService*, SEL, SBApplicationInfo*) = nil;

NSInteger trustStateForApplication(SBApplicationInfo* info) {
	return orig_trustStateForApplication(validationService, @selector(trustStateForApplication:), info);
}

NSInteger* getPermissionForApp(NSString* bundleId) {
	// TODO: get from preferences

	NSInteger* permission = malloc(sizeof(NSInteger));
	*permission = TOAppPermissionAllowOnce;
	return permission;

}

BOOL shouldAppAskToRun(NSString* bundleId) {
	NSInteger* permission = getPermissionForApp(bundleId);
	return permission == nil || *permission == TOAppPermissionAllowOnce;
}

BOOL isAppAllowedToRun(NSString* bundleId) {
	NSInteger* permission = getPermissionForApp(bundleId);
	return permission != nil && permission != TOAppPermissionNever;
}

%hook SBApplication
- (void)didActivateWithTransactionID:(id)arg1  {
	NSLog(@"Intercepted didActivateWithTransactionID call arg1=%@", arg1);
	%orig;
}
%end

// TODO: find a better class to hook that covers launches from notifications or siri
%hook SBLeafIcon
- (void)launchFromLocation:(id)location context:(id)context {
	NSLog(@"Intercepted launchFromLocation call location=%@, context=%@", location, context);

	if (trustStateForApplication([self.application info]) == 8 || !shouldAppAskToRun([self applicationBundleID])) {
		%orig;
		return;
	}

	// BUG: app is null when launched from spotlight search
	UIAlertController* alert = [UIAlertController
		alertControllerWithTitle:[NSString stringWithFormat:@"Allow “%@” to run?", [self.application displayName]]
		message:@"This app is not trusted because its provisioning profile has expired." // TODO: different message depending on trust state
		preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* alwaysAllowButton = [UIAlertAction
		actionWithTitle:@"Always Allow"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction* action) {
			// TODO: save preference
			%orig;
		}];
	UIAlertAction* allowOnceButton = [UIAlertAction
		actionWithTitle:@"Allow Once"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction* action) {
			// TODO: save preference
			%orig;
		}];
	UIAlertAction* disallowButton = [UIAlertAction
		actionWithTitle:@"Don’t Allow"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction* action) {
			// TODO: save preference
		}];
	[alert addAction:alwaysAllowButton];
	[alert addAction:allowOnceButton];
	[alert addAction:disallowButton];
	alert.preferredAction = disallowButton;

	// BUG: no scene is found the first time this is called after a respring
	// BUG: can't swipe down to access notification center after first launch
	NSSet* connectedScenes = [UIApplication sharedApplication].connectedScenes;
	int i = 1;
	for (UIScene* scene in connectedScenes) {
		NSLog(@">>>> scene %i", i++);
		if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
			UIWindowScene* windowScene = (UIWindowScene*)scene;
			int j = 1;
			for (UIWindow* window in windowScene.windows) {
				NSLog(@">>>> window %i", j++);
				UIViewController* viewController = [window rootViewController];
				[viewController presentViewController:alert animated:YES completion:nil];

				[window makeKeyAndVisible];
				break;
			}
		}
	}
}
%end

%hook FBSSignatureValidationService
- (NSInteger)trustStateForApplication:(SBApplicationInfo*)info {
	NSLog(@"Intercepted trustStateForApplication call info=%@", info);

	// TODO: i don't like how there's colocated logic here
	if (orig_trustStateForApplication == nil && info == nil) {
		orig_trustStateForApplication = &%orig;
		return 1;
	}

	NSInteger trustState = %orig;
	return trustState == 8 || isAppAllowedToRun([info bundleIdentifier])
		? 8
		: trustState;
}
%end

%ctor {
	%init;

	// TODO: move this into its own function?
	// also, maybe look for a better dummy value to pass that's not nil. perhaps
	// the info for an app that's always there, like settings
	validationService = [[%c(FBSSignatureValidationService) alloc] init];
	[validationService trustStateForApplication:nil];
}
