//
//  ExperimentViewController.h
//  cambridge.teste2
//
//  Created by Ricardo Freitas on 07/04/12.
//  Copyright (c) 2012 Zimbora. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This is an abstract class (subclass of UITableViewController) by implementation that does not fail when instanciated, but its rather empty of functionality.
 It can be used concretely, but it will only display an empty table.
 In order to use it, it has to be subclassed and the methods in the protocol implemented.
 */

/*
 The protocol to implement when subclassing.
 All methods are optional to implement, since they are implemented by the abstract class. Therefore, they should be implemented on a need-to-have basis.
 This are the methods that are safe to override when subclassing, all the others can be, but a close code inspection should be done for those.
 */
@protocol TableParentChild <NSObject>
#pragma mark - concrete methods
@optional
#pragma mark Data Model
-(BOOL) canParentAddChild:(NSUInteger)parentIndex;
-(NSUInteger) numberOfParents;
-(NSUInteger) numberOfChildrenFromParent:(NSUInteger)parentIndex;
-(void)configureCell:(UITableViewCell*)cell ofParentAtIndex:(NSUInteger)parentIndex;
-(void)configureCell:(UITableViewCell*)cell ofChildAtIndex:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex;

-(void)selectedParentAtIndex:(NSUInteger)parentIndex;
-(void)selectedChildAtIndex:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex;

#pragma mark Data Model Editing methods
-(BOOL) selectedAddParent;
-(BOOL) selectedAddChildFromParent:(NSUInteger)parentIndex;

-(BOOL) moveParent:(NSUInteger)parentIndex ToIndex:(NSUInteger)targetIndex;
-(BOOL) moveChild:(NSUInteger)childIndex ToIndex:(NSUInteger)targetIndex FromParent:(NSUInteger)parentIndex;

-(BOOL) removeParentAtIndex:(NSUInteger)parentIndex;
-(BOOL) removeChildAtIndex:(NSUInteger)childIndex FromParent:(NSUInteger)parentIndex;

#pragma mark other concrete methods
-(NSString*) titleForAddParentCell;
-(NSString*) titleForAddChildCellFromParent:(NSUInteger)parentIndex;
-(NSString*) headerTitleForParentSection:(NSUInteger)section;
-(void) save;//This method is called everytime one of the Data Model Editing methods is called

-(UITableViewCell*) tableCellForParentAtIndex:(NSUInteger)parentIndex;
-(UITableViewCell*) tableCellForChildAtIndex:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex;
@end


@interface TableParentChildViewController : UITableViewController<TableParentChild>
-(void) reloadRowOfChild:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex;
-(void) reloadRowOfParent:(NSUInteger)parentIndex;
@end



/*
 Categories
 */
#pragma mark categories

/*
 This categorie adds a method to the UITableView, so that it can return an array of all the rows, as NSIndexPaths, in a particular section.
 */
@interface UITableView (ArrayRowPath)
-(NSMutableArray*) arrayOfRowPathsOfSection:(NSUInteger)section;
@end
@implementation UITableView (ArrayRowPath)
-(NSMutableArray*) arrayOfRowPathsOfSection:(NSUInteger)section
{
    int numOfRows = [self numberOfRowsInSection:section];
    
    NSMutableArray* outRows = [NSMutableArray arrayWithCapacity:numOfRows];
    for (int i=0; i<numOfRows; i++) {
        [outRows addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    return outRows;
}
@end

/*
 This categorie does little more than to add methods for operations to individual rows, by extending the previous grouped ones that require to pass the rows inside an array, even if it's only one row. Therefore, the methods only wrap the row, represented as an NSIndexPath, and call the corresponding method to handle it.
 */
@interface UITableView (IndividualRowOperation)
-(void)insertRow:(NSIndexPath *)rowIndexPath withRowAnimation:(UITableViewRowAnimation)animation;
-(void)reloadRow:(NSIndexPath *)rowIndexPath withRowAnimation:(UITableViewRowAnimation)animation;
@end
@implementation UITableView (IndividualRowOperation)
-(void)insertRow:(NSIndexPath *)rowIndexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    [self insertRowsAtIndexPaths:[NSArray arrayWithObject:rowIndexPath] withRowAnimation:animation];
}
-(void)reloadRow:(NSIndexPath *)rowIndexPath withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:rowIndexPath] withRowAnimation:animation];
}
@end



/*
 Categorie that adds functionality to an NSMutableArray in order to perform operations on all of the NSIndexPath objects in it.
 */
@interface NSMutableArray (NSIndexPaths)
-(void) addRowValue:(NSInteger)addValue;
-(void) replaceIndexPathsSectionWith:(NSUInteger)newSection;
@end

@implementation NSMutableArray (NSIndexPaths)

/*
 Replaces every NSIndexPath with a copy, but with an increment to its row value. The increment is passed as a parameter.
 */
-(void) addRowValue:(NSInteger)addValue 
{
    for (int i=0; i<[self count]; i++)
    {
        NSIndexPath* indexPath = [self objectAtIndex:i];
        if ([indexPath isKindOfClass:[NSIndexPath class]]) {
            [self replaceObjectAtIndex:i withObject:[NSIndexPath indexPathForRow:(indexPath.row +addValue) inSection:indexPath.section]];
        }
    }
}

/*
 Replaces every NSIndexPath with a copy, but with a new section instead, which is passed as a parameter.
 */
-(void) replaceIndexPathsSectionWith:(NSUInteger)newSection
{
    for (int i=0; i<[self count]; i++)
    {   
        NSIndexPath* indexPath = [self objectAtIndex:i];
        if ([indexPath isKindOfClass:[NSIndexPath class]]) {
            [self replaceObjectAtIndex:i withObject:[NSIndexPath indexPathForRow:indexPath.row inSection:newSection]];
        }
    }
}
@end


/*
 Categorie that adds two properties to an NSIndexPath, child and parent. Even though a parent is also a row, of always value 0 (since it's always the first in the section), what determines the parent is in fact its section, therefore parent = section; a child is equal to its row +1, since the first row is reserved for the parent.
 This category is useful to map the section:row pair of the Table to the parent:child pair of data model. However, bear in mind that you might not always be dealing with a concrete parent or child, but addParent or addChild rows instead.
 It also has two class constructors, following the pattern of Apple's own categorie, the NSIndexPath UIKit Additions.
 */
@interface NSIndexPath (ParentChild)

@property (readonly) NSInteger child;
@property (readonly) NSInteger parent;

+(NSIndexPath*) indexPathForChild:(NSUInteger)childIndex ofParent:(NSUInteger)parentIndex;
+(NSIndexPath*) indexPathForParent:(NSUInteger)parentIndex;

@end

@implementation NSIndexPath (ParentChild)

-(NSInteger) child
{
    return (self.row - 1);
}
-(NSInteger) parent
{
    return (self.section);
}

+(NSIndexPath*) indexPathForChild:(NSUInteger)childIndex ofParent:(NSUInteger)parentIndex
{
    return [NSIndexPath indexPathForRow:(childIndex+1) inSection:parentIndex];
}

+(NSIndexPath*) indexPathForParent:(NSUInteger)parentIndex
{
    return [NSIndexPath indexPathForRow:0 inSection:parentIndex];
}

@end
