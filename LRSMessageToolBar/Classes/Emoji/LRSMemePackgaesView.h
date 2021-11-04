
#import <UIKit/UIKit.h>
#import "LRSMemePackageViewDefines.h"

@class LRSMemePackageConfigureItem;
@class LRSMemePackageConfigure;
@class LRSMemePackgaesView;
NS_ASSUME_NONNULL_BEGIN
@interface LRSMemePackgaesView : UIView <NSObject>
- (instancetype)initWithFrame:(CGRect)frame configures:(NSArray<LRSMemePackageConfigure *> *)configures;

+ (CGFloat)boardHeight;

@property (nonatomic, copy) LRSMemePackageItemsHandler itemHandler;
@property (nonatomic, copy) LRSMemePackageBackspaceHandler backspaceHandler;
@property (nonatomic, copy) LRSMemePackageSendOutHandler sendOutHandler;

- (void)buildUI;
@end
NS_ASSUME_NONNULL_END
