//
//  I33CollectionsComplexConfigurationViewController.m
//  BetweenKit
//
//  Created by Stephen Fortune on 18/12/2014.
//  Copyright (c) 2014 stephen fortune. All rights reserved.
//

#import "I33CollectionsComplexConfigurationViewController.h"
#import "I3SimpleData.h"
#import "I3SubtitleCell.h"
#import "I3SubtitleCollectionViewCell.h"
#import <BetweenKit/I3GestureCoordinator.h>
#import <BetweenKit/I3BasicRenderDelegate.h>


static NSString* DequeueReusableCell = @"DequeueReusableCell";


@interface I33CollectionsComplexConfigurationViewController ()

@property (nonatomic, strong) I3GestureCoordinator *dragCoordinator;

@property (nonatomic, strong) NSMutableArray *tlData;

@property (nonatomic, strong) NSMutableArray *trData;

@property (nonatomic, strong) NSMutableArray *bData;

@end


@implementation I33CollectionsComplexConfigurationViewController


-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    
    NSArray *data = @[
      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Item 1" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Item 2" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Item 3" withSubtitle:@"I'm just normal, you can do anything with me" withCanDelete:YES withCanMove:YES],
      [[I3SimpleData alloc] initWithColor:[UIColor greenColor] withTitle:@"Item 4" withSubtitle:@"I'm a bit precious, you can't delete me but you can move me about" withCanDelete:NO withCanMove:YES],
      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Item 5" withSubtitle:@"Yup, I'm normal too" withCanDelete:YES withCanMove:YES],
      [[I3SimpleData alloc] initWithColor:nil withTitle:@"Item 6" withSubtitle:@"Oh hey there, I'm also normal" withCanDelete:YES withCanMove:YES],
      [[I3SimpleData alloc] initWithColor:[UIColor redColor] withTitle:@"Item 7" withSubtitle:@"Back OFF." withCanDelete:NO withCanMove:NO],
      ];
    
    self.tlData = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
    self.trData = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
    self.bData = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
    
    [self.tlTable registerClass:[I3SubtitleCell class] forCellReuseIdentifier:DequeueReusableCell];
    [self.trCollection registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];
    [self.bCollection registerNib:[UINib nibWithNibName:I3SubtitleCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier];

    self.dragCoordinator = [I3GestureCoordinator basicGestureCoordinatorFromViewController:self withCollections:@[self.tlTable, self.trCollection, self.bCollection] withRecognizer:[[UILongPressGestureRecognizer alloc] init]];
    
}


-(void) didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    return [[self dataForCollectionView:tableView] count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DequeueReusableCell forIndexPath:indexPath];
    NSArray *data = [self dataForCollectionView:tableView];
    I3SimpleData *datum = [data objectAtIndex:indexPath.row];
    
    cell.textLabel.text = datum.title;
    cell.detailTextLabel.text = datum.subtitle;
    cell.backgroundColor = datum.colour;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate


-(NSMutableArray *)dataForCollectionView:(UIView *)collectionView{
    
    NSMutableArray *data = nil;
    
    if(collectionView == self.trCollection){
        data = self.trData;
    }
    else if(collectionView == self.tlTable){
        data = self.tlData;
    }
    else if(collectionView == self.bCollection){
        data = self.bData;
    }
    
    return data;
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section{
    return [[self dataForCollectionView:collectionView] count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    I3SubtitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:I3SubtitleCollectionViewCellIdentifier forIndexPath:indexPath];
    NSArray *data = [self dataForCollectionView:collectionView];
    I3SimpleData *datum = [data objectAtIndex:indexPath.row];
    
    cell.title.text = datum.title;
    cell.subtitle.text = datum.subtitle;
    cell.backgroundColor = datum.colour;
    
    return cell;

}


#pragma mark - Helpers


-(BOOL) isPointInDeletionArea:(CGPoint) point fromView:(UIView *)view{
    
    CGPoint localPoint = [self.deleteArea convertPoint:point fromView:view];
    return [self.deleteArea pointInside:localPoint withEvent:nil];
}


-(void) logUpdatedData{
    NSLog(@"Top Left: %@, Top Right: %@, Bottom %@", self.tlData, self.trData, self.bData);
}


#pragma mark - I3DragDataSource


-(BOOL) canItemBeDraggedAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    NSArray *fromData = [self dataForCollectionView:collection];
    
    I3SimpleData *fromDatum = [fromData objectAtIndex:at.row];
    
    return fromDatum.canMove;
}


-(BOOL) canItemFrom:(NSIndexPath *)from beRearrangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    NSArray *data = [self dataForCollectionView:collection];
    
    I3SimpleData *fromDatum = [data objectAtIndex:from.row];
    I3SimpleData *toDatum = [data objectAtIndex:to.row];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beAppendedToCollection:(UIView<I3Collection> *)toCollection atPoint:(CGPoint)to{
    
    NSArray *fromData = [self dataForCollectionView:fromCollection];
    
    I3SimpleData *fromDatum = [fromData objectAtIndex:from.row];

    return fromDatum.canMove && ![self isPointInDeletionArea:to fromView:toCollection];
}


-(BOOL) canItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection beExchangedWithItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)toCollection{
    
    NSArray *fromData = [self dataForCollectionView:fromCollection];
    NSArray *toData = [self dataForCollectionView:toCollection];
    
    I3SimpleData *fromDatum = [fromData objectAtIndex:from.row];
    I3SimpleData *toDatum = [toData objectAtIndex:to.row];
    
    return fromDatum.canMove && toDatum.canMove;
}


-(BOOL) canItemAt:(NSIndexPath *)from beDeletedFromCollection:(UIView<I3Collection> *)collection atPoint:(CGPoint)to{
    
    NSArray *fromData = [self dataForCollectionView:collection];
    
    I3SimpleData *fromDatum = [fromData objectAtIndex:from.row];
    
    return fromDatum.canDelete && [self isPointInDeletionArea:to fromView:self.view];
}


-(void) deleteItemAt:(NSIndexPath *)at inCollection:(UIView<I3Collection> *)collection{
    
    NSMutableArray *fromData = [self dataForCollectionView:collection];
    
    [fromData removeObjectAtIndex:at.row];
    [collection deleteItemsAtIndexPaths:@[at]];
    
    [self logUpdatedData];
}


-(void) rearrangeItemAt:(NSIndexPath *)from withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)collection{
    
    NSMutableArray *targetData = [self dataForCollectionView:collection];
    
    [targetData exchangeObjectAtIndex:to.row withObjectAtIndex:from.row];
    [collection reloadItemsAtIndexPaths:@[to, from]];
    
    [self logUpdatedData];
}


-(void) appendItemAt:(NSIndexPath *)from fromCollection:(UIView<I3Collection> *)fromCollection toPoint:(CGPoint)to onCollection:(UIView<I3Collection> *)onCollection{
    
    NSMutableArray *fromData = [self dataForCollectionView:fromCollection];
    NSMutableArray *toData = [self dataForCollectionView:onCollection];
    
    NSUInteger toIndex = [toData count];
    NSIndexPath *toIndexPath = [onCollection isKindOfClass:[UITableView class]] ? [NSIndexPath indexPathForRow:toIndex inSection:0] : [NSIndexPath indexPathForItem:toIndex inSection:0];
    
    I3SimpleData *exchangingDatum = [fromData objectAtIndex:from.row];

    [fromData removeObjectAtIndex:from.row];
    [toData insertObject:exchangingDatum atIndex:toIndex];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [onCollection insertItemsAtIndexPaths:@[toIndexPath]];

    [self logUpdatedData];
}


-(void) exchangeItemAt:(NSIndexPath *)from inCollection:(UIView<I3Collection> *)fromCollection withItemAt:(NSIndexPath *)to inCollection:(UIView<I3Collection> *)toCollection{
    
    NSMutableArray *fromData = [self dataForCollectionView:fromCollection];
    NSMutableArray *toData = [self dataForCollectionView:toCollection];
    
    I3SimpleData *exchangingDatum = [fromData objectAtIndex:from.row];
    
    [fromData removeObjectAtIndex:from.row];
    [toData insertObject:exchangingDatum atIndex:to.row];
    
    [fromCollection deleteItemsAtIndexPaths:@[from]];
    [toCollection insertItemsAtIndexPaths:@[to]];
    
    [self logUpdatedData];

}


@end
