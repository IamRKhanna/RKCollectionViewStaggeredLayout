//
//  RKViewController.m
//  RKCollectionViewStaggeredLayout
//
//  Created by Rahul Khanna on 08/26/2016.
//  Copyright (c) 2016 Rahul Khanna. All rights reserved.
//

#import "RKViewController.h"
#import <RKCollectionViewStaggeredLayout/RKCollectionViewStaggeredLayout.h>
#import "RKCollectionViewCell.h"
#import "RKCollectionViewHeaderView.h"

@interface RKViewController () <UICollectionViewDataSource, RKStaggeredCollectionViewLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation RKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    RKCollectionViewStaggeredLayout *staggerLayout = [[RKCollectionViewStaggeredLayout alloc] init];
    staggerLayout.itemStyle = RKStaggeredCollectionViewItemStyleTwinColumned;
    staggerLayout.renderDirection = RKStaggeredCollectionViewRenderDirectionShortestFirst;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:staggerLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RKCollectionViewCell class])
                                                    bundle:nil]
          forCellWithReuseIdentifier:NSStringFromClass([RKCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RKCollectionViewHeaderView class])
                                                    bundle:nil]
          forSupplementaryViewOfKind:RKCollectionElementKindSectionHeader
                 withReuseIdentifier:NSStringFromClass([RKCollectionViewHeaderView class])];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RKCollectionViewHeaderView class])
                                                    bundle:nil]
          forSupplementaryViewOfKind:RKCollectionElementKindSectionFooter
                 withReuseIdentifier:NSStringFromClass([RKCollectionViewHeaderView class])];
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 40;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RKCollectionViewCell class])
                                                                           forIndexPath:indexPath];
    
    cell.label.textAlignment = NSTextAlignmentCenter;
    if ([self itemStyleForIndexPath:indexPath] == RKStaggeredCollectionViewItemStyleSingleColumned) {
        cell.label.text = [NSString stringWithFormat:@"Single styled item at index %ld", (long)indexPath.item];
        cell.contentView.backgroundColor = [UIColor blueColor];
        cell.label.textColor = [UIColor whiteColor];
    }
    else {
        cell.label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        cell.label.textColor = [UIColor blackColor];
    }
    
    
    return cell;
}

#pragma mark - RKStaggeredCollectionViewLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width, height;
    width = collectionView.frame.size.width;
    if ([self itemStyleForIndexPath:indexPath] == RKStaggeredCollectionViewItemStyleSingleColumned)
        height = 40;
    else
        height = [self randomNumberBetween:100 maxNumber:200];
    
    return CGSizeMake(width, height);
}

- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random_uniform(max - min + 1);
}

- (RKStaggeredCollectionViewItemStyle)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout itemStyleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemStyleForIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:RKCollectionElementKindSectionHeader]) {
        RKCollectionViewHeaderView *headerView = (RKCollectionViewHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                  withReuseIdentifier:NSStringFromClass([RKCollectionViewHeaderView class])
                                                                                                                         forIndexPath:indexPath];
        headerView.infoLabel.text = @"This is a header";
        return headerView;
    }
    else if ([kind isEqualToString:RKCollectionElementKindSectionFooter]) {
        RKCollectionViewHeaderView *headerView = (RKCollectionViewHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                  withReuseIdentifier:NSStringFromClass([RKCollectionViewHeaderView class])
                                                                                                                         forIndexPath:indexPath];
        headerView.infoLabel.text = @"This is a footer";
        return headerView;
    }
    return nil;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return 20.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section {
    return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section {
    return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
}

- (RKStaggeredCollectionViewItemStyle)itemStyleForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 10) {
        return RKStaggeredCollectionViewItemStyleTwinColumned;
    }
    return RKStaggeredCollectionViewItemStyleSingleColumned;
}

@end
