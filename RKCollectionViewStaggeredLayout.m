//
//  RKCollectionViewStaggeredLayout.m
//  StaggeredCollectionView
//
//  Created by Rahul Khanna on 22/08/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCollectionViewStaggeredLayout.h"

NSString *const RKCollectionElementKindSectionHeader = @"RKCollectionElementKindSectionHeader";
NSString *const RKCollectionElementKindSectionFooter = @"RKCollectionElementKindSectionFooter";

@interface RKCollectionViewStaggeredLayout()

/// The delegate will point to collection view's delegate automatically.
@property (nonatomic, weak) id<RKStaggeredCollectionViewLayoutDelegate> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *allItemAttributes;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *sectionItemAttributes;
/// Dictionary to store section headers' attribute
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// Dictionary to store section footers' attribute
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;

@end

@implementation RKCollectionViewStaggeredLayout {
    NSInteger _nextColumnIndex;
}

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

static CGFloat RKFloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _minimumColumnSpacing = 10;
    _minimumInteritemSpacing = 10;
    _headerHeight = 0;
    _footerHeight = 0;
    _sectionInset = UIEdgeInsetsZero;
    _headerInset  = UIEdgeInsetsZero;
    _footerInset  = UIEdgeInsetsZero;
    _itemStyle = RKStaggeredCollectionViewItemStyleTwinColumned;
    _renderDirection = RKStaggeredCollectionViewRenderDirectionShortestFirst;
}

#pragma mark - Private Accessors

- (NSMutableDictionary *)headersAttribute {
    if (!_headersAttribute) {
        _headersAttribute = [NSMutableDictionary dictionary];
    }
    return _headersAttribute;
}

- (NSMutableDictionary *)footersAttribute {
    if (!_footersAttribute) {
        _footersAttribute = [NSMutableDictionary dictionary];
    }
    return _footersAttribute;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (id<RKStaggeredCollectionViewLayoutDelegate>)delegate {
    return (id <RKStaggeredCollectionViewLayoutDelegate> )self.collectionView.delegate;
}

- (NSMutableArray *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

#pragma mark - Public Accessors
- (void)setMinimumColumnSpacing:(CGFloat)minimumColumnSpacing {
    if (_minimumColumnSpacing != minimumColumnSpacing) {
        _minimumColumnSpacing = minimumColumnSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    if (_minimumInteritemSpacing != minimumInteritemSpacing) {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight {
    if (_footerHeight != footerHeight) {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_headerInset, headerInset)) {
        _headerInset = headerInset;
        [self invalidateLayout];
    }
}

- (void)setFooterInset:(UIEdgeInsets)footerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_footerInset, footerInset)) {
        _footerInset = footerInset;
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

-(void)setItemStyle:(RKStaggeredCollectionViewItemStyle)itemStyle {
    if (_itemStyle != itemStyle) {
        _itemStyle = itemStyle;
        [self invalidateLayout];
    }
}

#pragma mark - Overriden layout methods

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.columnHeights removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];

    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    NSAssert([self.delegate conformsToProtocol:@protocol(RKStaggeredCollectionViewLayoutDelegate)], @"UICollectionView's delegate should conform to RKStaggeredCollectionViewLayoutDelegate protocol");
    
    // Initialize variables
    NSInteger idx = 0;

    // Create attributes
    CGFloat top = 0;
    UICollectionViewLayoutAttributes *attributes;
    for (NSInteger section = 0; section < numberOfSections; section++) {
        
        // Add another object to columnHeights for the new section
        [self.columnHeights addObject:[NSMutableArray arrayWithObject:@(0)]];
        _nextColumnIndex = 0;
        
        /*
         * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
         */
        CGFloat minimumInteritemSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
        } else {
            minimumInteritemSpacing = self.minimumInteritemSpacing;
        }
        
        CGFloat columnSpacing = self.minimumColumnSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumColumnSpacingForSectionAtIndex:)]) {
            columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumColumnSpacingForSectionAtIndex:section];
        }
        
        UIEdgeInsets sectionInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        } else {
            sectionInset = self.sectionInset;
        }
        
        // Total available width
        CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
        
        /*
         * 2. Section header
         */
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
        } else {
            headerHeight = self.headerHeight;
        }
        
        UIEdgeInsets headerInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
            headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
        } else {
            headerInset = self.headerInset;
        }
        
        top += headerInset.top;
        
        if (headerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:RKCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (headerInset.left + headerInset.right),
                                          headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
        }
        
        top += sectionInset.top;
        self.columnHeights[section][0] = @(top);
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        for (idx = 0; idx < itemCount; idx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            
            if (itemSize.width > 0 && itemSize.height > 0) {
                CGFloat itemWidth, itemHeight;
                CGFloat xOffset, yOffset;
                RKStaggeredCollectionViewItemStyle itemStyle;
                attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:itemStyleForItemAtIndexPath:)])
                    itemStyle = [self.delegate collectionView:self.collectionView layout:self itemStyleForItemAtIndexPath:indexPath];
                else
                    itemStyle = self.itemStyle;
                
                switch (itemStyle) {
                    case RKStaggeredCollectionViewItemStyleSingleColumned: {
                        itemWidth = width;
                        itemHeight = RKFloorCGFloat(itemSize.height * itemWidth / itemSize.width);
                        
                        xOffset = sectionInset.left;
                        yOffset = [self contentHeightForSection:section];
                        
                        attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
                        
                        NSMutableArray *sectionColumnHeights = self.columnHeights[section];
                        for (NSInteger sectionColumnHeightIdx = 0; sectionColumnHeightIdx < sectionColumnHeights.count; sectionColumnHeightIdx++) {
                            sectionColumnHeights[sectionColumnHeightIdx] = @(CGRectGetMaxY(attributes.frame) + minimumInteritemSpacing);
                        }
                        top = CGRectGetMaxY(attributes.frame) + minimumInteritemSpacing;
                        break;
                    }
                    default: {
                        
                        // Make sure columnHeights has sufficient data
                        NSMutableArray *sectionColumnHeights = self.columnHeights[section];
                        if (sectionColumnHeights.count != itemStyle) {
                            for (NSInteger sectionColumnHeightIdx = sectionColumnHeights.count; sectionColumnHeightIdx < itemStyle; sectionColumnHeightIdx++) {
                                [sectionColumnHeights addObject:@(top)];
                            }
                        }
                        
                        itemWidth = RKFloorCGFloat((width - (itemStyle - 1) * columnSpacing) / itemStyle);
                        itemHeight = RKFloorCGFloat(itemSize.height * itemWidth / itemSize.width);
                        xOffset = sectionInset.left + (itemWidth + columnSpacing) * _nextColumnIndex;
                        yOffset = [self.columnHeights[section][_nextColumnIndex] floatValue];
                        
                        attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
                        self.columnHeights[section][_nextColumnIndex] = @(CGRectGetMaxY(attributes.frame) + minimumInteritemSpacing);
                        break;
                    }
                }
                [self updateNextColumnIndexForSection:section itemStyle:itemStyle];
                
                [itemAttributes addObject:attributes];
                [self.allItemAttributes addObject:attributes];
            }
        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        /*
         * 4. Section footer
         */
        CGFloat footerHeight;
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        top = [self.columnHeights[section][columnIndex] floatValue] - minimumInteritemSpacing + sectionInset.bottom;
        
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
        } else {
            footerHeight = self.footerHeight;
        }
        
        UIEdgeInsets footerInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
            footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
        } else {
            footerInset = self.footerInset;
        }
        
        top += footerInset.top;
        
        if (footerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:RKCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (footerInset.left + footerInset.right),
                                          footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
        }
        
        for (idx = 0; idx < [self.columnHeights[section] count]; idx++) {
            self.columnHeights[section][idx] = @(top);
        }
    }
    
    // Build union rects
    idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = [[[self.columnHeights lastObject] firstObject] floatValue];
    
    if (contentSize.height < self.minimumContentHeight) {
        contentSize.height = self.minimumContentHeight;
    }
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count]) {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:RKCollectionElementKindSectionHeader]) {
        attribute = self.headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:RKCollectionElementKindSectionFooter]) {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

#pragma mark - Private helper methods
- (CGFloat)contentHeightForSection:(NSInteger)section {
    __block CGFloat sectionContentHeight = 0;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat height = [obj floatValue];
        if (height > sectionContentHeight) {
            sectionContentHeight = height;
        }
    }];
    
    return sectionContentHeight;
}

- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

- (void)updateNextColumnIndexForSection:(NSInteger)section itemStyle:(RKStaggeredCollectionViewItemStyle)itemStyle {
    switch (itemStyle) {
        case RKStaggeredCollectionViewItemStyleSingleColumned: {
            _nextColumnIndex = 0;
            break;
        }
        default: {
            switch (self.renderDirection) {
                case RKStaggeredCollectionViewRenderDirectionLeftToRight:
                    _nextColumnIndex = ++_nextColumnIndex % [self.columnHeights[section] count];
                    break;
                default:
                    _nextColumnIndex = [self shortestColumnIndexInSection:section];
                    break;
            }
            break;
        }
    }
}

@end