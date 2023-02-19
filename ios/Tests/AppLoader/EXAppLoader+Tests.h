#import "EXHomeLoader.h"
#import <EXManifests/EXManifests-Swift.h>

#pragma mark - private/internal methods in App Loader & App Fetchers

@interface EXHomeLoader (EXAppLoaderTests)

@property (nonatomic, readonly) EXAppFetcher * _Nullable appFetcher;

- (BOOL)_fetchBundleWithManifest:(EXManifestsManifest *)manifest;

@end
