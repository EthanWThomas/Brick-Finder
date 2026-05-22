#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"Edu.dixietech.mad.ethanthomas-gmail.com.Brick-Finder";

/// The "TabbarColor" asset catalog color resource.
static NSString * const ACColorNameTabbarColor AC_SWIFT_PRIVATE = @"TabbarColor";

/// The "mainBackgroundColor" asset catalog color resource.
static NSString * const ACColorNameMainBackgroundColor AC_SWIFT_PRIVATE = @"mainBackgroundColor";

/// The "mainBackgroundColor2" asset catalog color resource.
static NSString * const ACColorNameMainBackgroundColor2 AC_SWIFT_PRIVATE = @"mainBackgroundColor2";

/// The "Gemini_Generated_Image_7vf8eq7vf8eq7vf8" asset catalog image resource.
static NSString * const ACImageNameGeminiGeneratedImage7Vf8Eq7Vf8Eq7Vf8 AC_SWIFT_PRIVATE = @"Gemini_Generated_Image_7vf8eq7vf8eq7vf8";

/// The "RedLegoBrick" asset catalog image resource.
static NSString * const ACImageNameRedLegoBrick AC_SWIFT_PRIVATE = @"RedLegoBrick";

/// The "legoMinifigure" asset catalog image resource.
static NSString * const ACImageNameLegoMinifigure AC_SWIFT_PRIVATE = @"legoMinifigure";

/// The "legoRedBrick" asset catalog image resource.
static NSString * const ACImageNameLegoRedBrick AC_SWIFT_PRIVATE = @"legoRedBrick";

/// The "minifigure" asset catalog image resource.
static NSString * const ACImageNameMinifigure AC_SWIFT_PRIVATE = @"minifigure";

/// The "setImage" asset catalog image resource.
static NSString * const ACImageNameSetImage AC_SWIFT_PRIVATE = @"setImage";

#undef AC_SWIFT_PRIVATE
