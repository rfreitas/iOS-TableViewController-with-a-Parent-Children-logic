//
//  ExperimentViewController.m
//  cambridge.teste2
//
//  Created by Ricardo Freitas on 07/04/12.
//  Copyright (c) 2012 Zimbora. All rights reserved.
//

#import "TableParentChildViewController.h"

//Enumerator that defines the type of a row
typedef enum _indexType {
ITparent = 1,
ITchild = 2,
ITaddParent = 3,
ITaddChild = 4
} IndexPathType;

static NSString* parentCellId = @"parentCellId";
static NSString* childCellId = @"childCellId";
static NSString* addParentCellId = @"addParentCellId";
static NSString* addChildCellId = @"addChildCellId";

@interface TableParentChildViewController ()
@end

@implementation TableParentChildViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Abstract TableParentChild";
    
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - concrete methods

#pragma mark Data Model
-(BOOL) canParentAddChild:(NSUInteger)parentIndex
{
    return NO;
}

-(NSUInteger) numberOfParents
{
    return 0;
}

-(NSUInteger) numberOfChildrenFromParent:(NSUInteger)parentIndex
{
    return 0;
}

-(void)selectedParentAtIndex:(NSUInteger)parentIndex
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForParent:parentIndex] animated:YES];
}

-(void)selectedChildAtIndex:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForChild:childIndex ofParent:parentIndex] animated:YES];
}


-(void)configureCell:(UITableViewCell*)cell ofParentAtIndex:(NSUInteger)parentIndex
{
    cell.textLabel.text = @"Unamed parent cell";
}

-(void)configureCell:(UITableViewCell*)cell ofChildAtIndex:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex
{
    cell.textLabel.text = @"Unamed child cell";
}


#pragma mark Data Model Editing methods
-(BOOL) selectedAddParent
{
    return NO;
}

-(BOOL) selectedAddChildFromParent:(NSUInteger)parentIndex
{
    return NO;
}

-(BOOL) moveParent:(NSUInteger)parentIndex ToIndex:(NSUInteger)targetIndex
{
    return NO;
}

-(BOOL) moveChild:(NSUInteger)childIndex ToIndex:(NSUInteger)targetIndex FromParent:(NSUInteger)parentIndex
{
    return NO;
}

-(BOOL) removeParentAtIndex:(NSUInteger)parentIndex
{
    return NO;
}

-(BOOL) removeChildAtIndex:(NSUInteger)childIndex FromParent:(NSUInteger)parentIndex
{
    return NO;
}


#pragma mark other concrete methods
-(NSString*) titleForAddParentCell
{
    return @"Add Parent";
}

-(NSString*) titleForAddChildCellFromParent:(NSUInteger)parentIndex
{
    return @"Add Child";
}

-(NSString*) headerTitleForParentSection:(NSUInteger)section
{
    return nil;
}

-(void) save
{
    NSLog(@"Not saving anything");
}

-(UITableViewCell*) tableCellForParentAtIndex:(NSUInteger)parentIndex
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:parentCellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:parentCellId];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
-(UITableViewCell*) tableCellForChildAtIndex:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:childCellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:childCellId];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
#pragma mark -




#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger outN = [self numberOfParents];
    if (self.editing) {
        outN++;
    }
    
    //NSLog(@"Number of sections:%d",outN);
    return outN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [self numberOfParents])
    {//id editing and last section
        NSAssert(self.editing,@"state should be editing");
        //NSLog(@"Numbers of rows:%d in last section",1);
        return 1;
    }
    
    NSUInteger outN = [self numberOfChildrenFromParent:section]+1;//children + parent
    if (self.editing && [self canParentAddChild:section]) {
        outN++;//row for add child
    }
    
    //NSLog(@"Numbers of rows:%d in section:%d editing %d",outN,section,self.editing);
    return outN;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self headerTitleForParentSection:section];
}


#pragma mark editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing == self.editing) {
        return;
    }
    [self.tableView beginUpdates];
    if (editing) {
        //NSLog(@"starting editing");
        int lastSection = [self.tableView numberOfSections];
        for (int i=0; i<lastSection; i++) {
            int lastRow = [self.tableView numberOfRowsInSection:i];
            if (lastRow>0 && [self canParentAddChild:i]) {
                NSIndexPath* path = [NSIndexPath indexPathForRow:lastRow inSection:i];
                //NSLog(@"inserting editing add child at section %d row %d",path.section,path.row);
                
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path ]  withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:lastSection];
        //NSLog(@"inserting add parent at section %d row %d",path.section,path.row); 
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:lastSection] withRowAnimation:UITableViewRowAnimationTop];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path ]  withRowAnimation:UITableViewRowAnimationTop];
    }
    else {
        //NSLog(@"ending editing");
        int lastSection = [self.tableView numberOfSections]-1;
        
        for (int i=0; i<lastSection; i++) {
            int lastRow = [self.tableView numberOfRowsInSection:i]-1;
            if (lastRow>0 && [self canParentAddChild:i]) {
                NSIndexPath* path = [NSIndexPath indexPathForRow:lastRow inSection:i];
                //NSLog(@"deleting add child at section %d row %d",path.section,path.row);
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path ]  withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:lastSection];
        //NSLog(@"deleting add parent at section %d row %d",path.section,path.row);
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path ]  withRowAnimation:UITableViewRowAnimationTop];
        
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:lastSection] withRowAnimation:UITableViewRowAnimationTop];
    }
    [super setEditing:editing animated:animated];
    [self.tableView endUpdates];
}



//Commiting editing
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    //NSLog(@"commit editing for section %d row %d",indexPath.section,indexPath.row);
    IndexPathType pathType = [self whatTypeIsIndexPath:indexPath];
    switch (pathType) {
        case ITparent:
            NSAssert(editingStyle == UITableViewCellEditingStyleDelete,@"wrong state");
            if ([self removeParentAtIndex:indexPath.section]){
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];
            }
            else {
                NSLog(@"Failed to remove parent.");
                self.editing = NO;
            }
            break;
            
        case ITchild:
            NSAssert(editingStyle == UITableViewCellEditingStyleDelete,@"wrong state");
            if ([self removeChildAtIndex:(indexPath.child) FromParent:indexPath.section]) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            }
            else {
                NSLog(@"Failed to remove child.");
                self.editing = NO;
            }
            break;
            
        case ITaddParent:
            NSAssert(editingStyle == UITableViewCellEditingStyleInsert,@"wrong state");
            [self addParent];
            break;
            
        case ITaddChild:
            NSAssert(editingStyle == UITableViewCellEditingStyleInsert,@"wrong state");
            [self addChildToParent:indexPath.section];
            break;
    }
    [self save];
    //NSLog(@"updates about to end");
    [tableView endUpdates];
    if ([self isIndexPathTypeOfParentType:pathType]) {
        //NSLog(@"reloading section titles");
        [tableView reloadSectionIndexTitles];
    }
}


-(void) addParent
{
    NSUInteger parentCount = [self numberOfParents];
    if ([self selectedAddParent]) {
        if (parentCount+1 == [self numberOfParents]) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self numberOfParents]-1] withRowAnimation:YES];
        }
        else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"AddParentSelected did not create a new parent. Selector:%@", NSStringFromSelector(_cmd)]
                                         userInfo:nil];
        }
    }
}

-(void) addChildToParent:(NSUInteger)parentIndex
{
    NSUInteger childCount = [self numberOfChildrenFromParent:parentIndex];
    if ([self selectedAddChildFromParent:parentIndex])
    {
        if (childCount+1==[self numberOfChildrenFromParent:parentIndex]) {
            [self.tableView insertRow:[NSIndexPath indexPathForChild:childCount ofParent:parentIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"AddChildSelected did not create a new child in parent %d. Selector:%@",parentIndex, NSStringFromSelector(_cmd)]
                                         userInfo:nil];
        }
    }
}

//Row editing style determination
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"what editing style for section %d row %d",indexPath.section,indexPath.row);
    if ([self isIndexPathOfAddType:indexPath]) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}


#pragma mark cell configuration
//configuring cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"configuring cell section %d row %d",indexPath.section,indexPath.row);
    UITableViewCell* cell;
    switch ([self whatTypeIsIndexPath:indexPath])
    {
        case ITparent:
            //NSLog(@"configuring parent");
            cell = [self tableCellForParentAtIndex:indexPath.section];
            [self configureCell:cell ofParentAtIndex:indexPath.section];
            break;
            
        case ITchild:
        {
            NSUInteger childIndex = indexPath.child;
            cell = [self tableCellForChildAtIndex:childIndex fromParent:indexPath.section];
            [self configureCell:cell ofChildAtIndex:childIndex fromParent:indexPath.section];
            break;
        }
        case ITaddParent:
            //NSLog(@"configuring add parent");
            cell = [tableView dequeueReusableCellWithIdentifier:addParentCellId];
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addParentCellId];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.textLabel.text = [self titleForAddParentCell];
            }
            return cell;
            
        case ITaddChild:
            //NSLog(@"configuring add child");
            cell = [tableView dequeueReusableCellWithIdentifier:addChildCellId];
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addChildCellId];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = [self titleForAddChildCellFromParent:indexPath.parent];
            }
            return cell;
    }
    return cell;
}


#pragma mark Row movement
// Commiting row move
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([fromIndexPath isEqual:toIndexPath]) {
        //NSLog(@"Row did not move.");
        return;
    }
    BOOL moveSuccess = NO;
    switch ([self whatTypeIsIndexPath:fromIndexPath]) {
        case ITparent:
        {
            //NSLog(@"move confirmation of parent");
            
            if ([self moveParent:fromIndexPath.section ToIndex:toIndexPath.section])
            {
                [tableView beginUpdates];
                NSMutableArray* targetRows = [tableView arrayOfRowPathsOfSection:toIndexPath.section];
                [targetRows removeObjectAtIndex:0];//exclude the moved row
                [tableView deleteRowsAtIndexPaths:targetRows withRowAnimation:UITableViewRowAnimationAutomatic];//delete the previous rows in the target section
                
                NSMutableArray* sourceRows = [tableView arrayOfRowPathsOfSection:fromIndexPath.section];
                [tableView deleteRowsAtIndexPaths:sourceRows withRowAnimation:UITableViewRowAnimationAutomatic];//deletes the rows in the source section
                
                //prepare the previous rows of the target section for insertion into the source section
                [targetRows addRowValue:(-1)];//normalize the array, so that the row starts at 0
                [targetRows replaceIndexPathsSectionWith:fromIndexPath.section];//make the section the source section
                [tableView insertRowsAtIndexPaths:targetRows withRowAnimation:UITableViewRowAnimationAutomatic];
                
                //prepare
                [sourceRows addRowValue:(1)];//move the rows index by one, in order to give space to the already moved parent
                [sourceRows replaceIndexPathsSectionWith:toIndexPath.section];
                [tableView insertRowsAtIndexPaths:sourceRows withRowAnimation:UITableViewRowAnimationAutomatic];
                
                
                
                //NSLog(@"ending update");
                [tableView endUpdates];
                moveSuccess = YES;
            }
        }
            break;
            
        case ITchild:
            if ([self moveChild:(fromIndexPath.row-1) ToIndex:(toIndexPath.row-1) FromParent:fromIndexPath.section]) {
                moveSuccess = YES;
            }
            break;
            
        default:
            abort();
            break;
    }
    if (moveSuccess) {
        [tableView reloadData];
        [self save];
    }
    else {
        [tableView moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
        [tableView reloadData];
    }
    
}


// Contional row movement authorization
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isIndexPathOfAddType:indexPath]) {
        return NO;
    }
    return YES;
}


//Row movement logic
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath* outIndexPath=sourceIndexPath;
    //NSLog(@"proposed move to section %d and row %d from section %d and row %d",proposedDestinationIndexPath.section,proposedDestinationIndexPath.row,sourceIndexPath.section,sourceIndexPath.row);
    switch ([self whatTypeIsIndexPath:sourceIndexPath]) {
        case ITparent:
            if (proposedDestinationIndexPath.section != sourceIndexPath.section && proposedDestinationIndexPath.section != [self numberOfParents]) 
            {//move parent always to the head, first row, of the proposed section
                //NSLog(@"sending proposal");
                outIndexPath = [NSIndexPath indexPathForRow:0 inSection:proposedDestinationIndexPath.section];
            }
            break;
            
        case ITchild:
            if (proposedDestinationIndexPath.section == sourceIndexPath.section) 
            {//for now children cannot switch parents (parents)
                NSUInteger outRow = proposedDestinationIndexPath.row;
                NSUInteger outSection = proposedDestinationIndexPath.section;
                //NSLog(@"number of children %d from parent %d",[self numberOfChildrenFromParent:outSection], [self numberOfParents]);
                if (outRow == 0)
                {// children cannot go to the head of a section, that position is reserverd for his parent
                    outRow = 1;
                }
                else if (outRow == [self numberOfChildrenFromParent:outSection]+1) {
                    outRow--;
                }
                //NSLog(@"sending proposal row %d section %d",outRow,outSection);
                outIndexPath = [NSIndexPath indexPathForRow:outRow inSection:outSection];
                return outIndexPath;
            }
            break;
            
        default:
            abort();
            break;
    }
    return outIndexPath;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self whatTypeIsIndexPath:indexPath]) {
        case ITaddChild:
            [self addChildToParent:indexPath.parent];
            break;
        case ITaddParent:
            [self addParent];
            break;
        case ITchild:
            [self selectedChildAtIndex:indexPath.child fromParent:indexPath.parent];
            break;
        case ITparent:
            [self selectedParentAtIndex:indexPath.parent];
            break;
            
        default:
            abort();
            break;
    }
}


#pragma mark - handy methods
-(void) reloadRowOfChild:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex
{
    NSIndexPath* childPath = [NSIndexPath indexPathForChild:childIndex ofParent:parentIndex];
    [self.tableView reloadRow:childPath withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) reloadRowOfParent:(NSUInteger)parentIndex
{
    [self.tableView reloadRow:[NSIndexPath indexPathForParent:parentIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(UITableViewCell*) cellOfChild:(NSUInteger)childIndex fromParent:(NSUInteger)parentIndex
{
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForChild:childIndex ofParent:parentIndex]];
}

-(UITableViewCell*) cellOfParent:(NSUInteger)parentIndex
{
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForParent:parentIndex]];
}

#pragma mark type row checking
//type row checking methods
-(BOOL) isIndexPathOfAddType:(NSIndexPath*)indexPath
{
    return [self isIndexPathTypeOfAddType:[self whatTypeIsIndexPath:indexPath]];
}

-(BOOL) isIndexPathTypeOfAddType:(IndexPathType)indexType
{
    if (indexType == ITaddChild || indexType == ITaddParent) {
        return YES;
    }
    return NO;
}

-(BOOL) isIndexPathTypeOfParentType:(IndexPathType)indexType
{
    if (indexType == ITparent || indexType == ITaddParent) {
        return YES;
    }
    return NO;
}


-(IndexPathType) whatTypeIsIndexPath:(NSIndexPath*)indexPath
{
    int row = indexPath.row;
    int section = indexPath.section;
    IndexPathType outType;
    if (self.editing && section == [self numberOfParents] && row==0) {
        outType= ITaddParent;
    }
    else if (self.editing && row == [self numberOfChildrenFromParent:section]+1 ) {
        outType= ITaddChild;
    }
    else if (row==0 && section < [self numberOfParents] ) {
        outType= ITparent;
    }
    else if (row>0) {
        outType= ITchild;
    }
    else {
        NSLog(@"invalid state");
        abort();
    }
    return outType;
}

@end
