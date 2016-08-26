//
//  RKCollectionViewStaggeredLayout.h
//  StaggeredCollectionView
//
//  Created by Rahul Khanna on 22/08/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Constants that specify the types of supplementary views that can be presented using the staggered layout
 */
extern NSString *const RKCollectionElementKindSectionHeader;
extern NSString *const RKCollectionElementKindSectionFooter;


/**
 *  This is where the magic lies. This enumerated structure defines the style for each item.
 */
typedef NS_ENUM(NSUInteger, RKStaggeredCollectionViewItemStyle) {
    /**
     *  The item will take up the entire width pretending there is only a single column
     */
    RKStaggeredCollectionViewItemStyleSingleColumned = 1,
    /**
     *  The item shall be layed out in the standard two column style (like the waterfall layout)
     */
    RKStaggeredCollectionViewItemStyleTwinColumned = 2,
};

/**
 *  Enumerated structure to define direction in which items can be rendered.
 */
typedef NS_ENUM(NSUInteger, RKStaggeredCollectionViewRenderDirection) {
    RKStaggeredCollectionViewRenderDirectionShortestFirst = 0,
    RKStaggeredCollectionViewRenderDirectionLeftToRight
};


@protocol RKStaggeredCollectionViewLayoutDelegate;

NS_CLASS_AVAILABLE_IOS(6_0) @interface RKCollectionViewStaggeredLayout : UICollectionViewLayout
/**
 *  @brief The minimum spacing to use between successive columns.
 *  @discussion Default: 10.0
 */
@property (nonatomic, assign) CGFloat minimumColumnSpacing;

/**
 *  @brief The minimum spacing to use between items in the same column.
 *  @discussion Default: 10.0
 *  @note This spacing is not applied to the space between header and columns or between columns and footer.
 */
@property (nonatomic, assign) CGFloat minimumInteritemSpacing; // Default: 10.0

/**
 *  @brief Height for section header
 *  @discussion
 *    If your collectionView's delegate doesn't implement `collectionView:layout:heightForHeaderInSection:`,
 *    then this value will be used.
 *
 *    Default: 0
 */
@property (nonatomic, assign) CGFloat headerHeight;

/**
 *  @brief Height for section footer
 *  @discussion
 *    If your collectionView's delegate doesn't implement `collectionView:layout:heightForFooterInSection:`,
 *    then this value will be used.
 *
 *    Default: 0
 */
@property (nonatomic, assign) CGFloat footerHeight;

/**
 *  @brief The margins that are used to lay out the header for each section.
 *  @discussion
 *    These insets are applied to the headers in each section.
 *    They represent the distance between the top of the collection view and the top of the content items
 *    They also indicate the spacing on either side of the header. They do not affect the size of the headers or footers themselves.
 *
 *    Default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets headerInset;

/**
 *  @brief The margins that are used to lay out the footer for each section.
 *  @discussion
 *    These insets are applied to the footers in each section.
 *    They represent the distance between the top of the collection view and the top of the content items
 *    They also indicate the spacing on either side of the footer. They do not affect the size of the headers or footers themselves.
 *
 *    Default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets footerInset;

/**
 *  @brief The margins that are used to lay out content in each section.
 *  @discussion
 *    Section insets are margins applied only to the items in the section.
 *    They represent the distance between the header view and the columns and between the columns and the footer view.
 *    They also indicate the spacing on either side of columns. They do not affect the size of the headers or footers themselves.
 *
 *    Default: UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;

/**
 *  @brief The minimum height of the collection view's content.
 *  @discussion
 *    The minimum height of the collection view's content. This could be used to allow hidden headers with no content.
 *
 *    Default: 0.f
 */
@property (nonatomic, assign) CGFloat minimumContentHeight;

/**
 *  @brief The style in which item will be layed out
 *  @discussion
 *    Default: RKStaggeredCollectionViewItemStyleTwinColumned
 */
@property (nonatomic, assign) RKStaggeredCollectionViewItemStyle itemStyle;

/**
 *  @brief The direction in which items will be rendered in subsequent rows.
 *  @discussion
 *    The direction in which each item is rendered. This could be left to right (RKStaggeredCollectionViewRenderDirectionLeftToRight) or shortest column fills first (RKStaggeredCollectionViewRenderDirectionShortestFirst).
 *
 *    Default: RKStaggeredCollectionViewRenderDirectionShortestFirst
 */
@property (nonatomic, assign) RKStaggeredCollectionViewRenderDirection renderDirection;

@end


@protocol RKStaggeredCollectionViewLayoutDelegate <UICollectionViewDelegate>
@required
/**
 *  Asks the delegate for the size of the specified item’s cell.
 *
 *  @param collectionView
 *    The collection view object displaying the staggered layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param indexPath
 *    The index path of the item.
 *
 *  @return
 *    The original size of the specified item. Both width and height must be greater than 0.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
/**
 *  Asks the delegate for the style of the next item at the specified index path
 *
 *  @param collectionView      
 *    The collection view object displaying the staggered layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param indexPath        
 *    The index path for which item style is needed
 *
 *  @return
 *    Item style
 *
 *  @discussion
 *    If you do not implement this method, the staggered layout uses the value in its itemStyle property to set the style of items.
 */
- (RKStaggeredCollectionViewItemStyle)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout itemStyleForItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Asks the delegate for the height of the header view in the specified section.
 *
 *  @param collectionView
 *    The collection view object displaying the staggered layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param section
 *    The index of the section whose header size is being requested.
 *
 *  @return
 *    The height of the header. If you return 0, no header is added.
 *
 *  @discussion
 *    If you do not implement this method, the staggered layout uses the value in its headerHeight property to set the size of the header.
 *
 *  @see
 *    headerHeight
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;

/**
 *  Asks the delegate for the height of the footer view in the specified section.
 *
 *  @param collectionView
 *    The collection view object displaying the staggered layout.
 *  @param collectionViewLayout
 *    The layout object requesting the information.
 *  @param section
 *    The index of the section whose header size is being requested.
 *
 *  @return
 *    The height of the footer. If you return 0, no footer is added.
 *
 *  @discussion
 *    If you do not implement this method, the staggered layout uses the value in its footerHeight property to set the size of the footer.
 *
 *  @see
 *    footerHeight
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;

/**
 * Asks the delegate for the insets in the specified section.
 *
 * @param collectionView
 *   The collection view object displaying the staggered layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose insets are being requested.
 *
 * @discussion
 *   If you do not implement this method, the staggered layout uses the value in its sectionInset property.
 *
 * @return
 *   The insets for the section.
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the header insets in the specified section.
 *
 * @param collectionView
 *   The collection view object displaying the staggered layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose header insets are being requested.
 *
 * @discussion
 *   If you do not implement this method, the staggered layout uses the value in its headerInset property.
 *
 * @return
 *   The headerInsets for the section.
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section;

/**
 * Asks the delegate for the footer insets in the specified section.
 *
 * @param collectionView
 *   The collection view object displaying the staggered layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose footer insets are being requested.
 *
 * @discussion
 *   If you do not implement this method, the staggered layout uses the value in its footerInset property.
 *
 * @return
 *   The footerInsets for the section.
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section;

/**
 * Asks the delegate for the minimum spacing between two items in the same column
 * in the specified section. If this method is not implemented, the
 * minimumInteritemSpacing property is used for all sections.
 *
 * @param collectionView
 *   The collection view object displaying the staggered layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose minimum interitem spacing is being requested.
 *
 * @discussion
 *   If you do not implement this method, the staggered layout uses the value in its minimumInteritemSpacing property to determine the amount of space between items in the same column.
 *
 * @return
 *   The minimum interitem spacing.
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the minimum spacing between colums in a secified section. If this method is not implemented, the
 * minimumColumnSpacing property is used for all sections.
 *
 * @param collectionView
 *   The collection view object displaying the staggered layout.
 * @param collectionViewLayout
 *   The layout object requesting the information.
 * @param section
 *   The index of the section whose minimum interitem spacing is being requested.
 *
 * @discussion
 *   If you do not implement this method, the staggered layout uses the value in its minimumColumnSpacing property to determine the amount of space between columns in each section.
 *
 * @return
 *   The minimum spacing between each column.
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section;

@end