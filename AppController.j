/*
 * AppController.j
 * CercalNG
 *
 * Created by You on September 10, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "DataController.j"


@implementation AppController : CPObject
{
    IBOutlet    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    IBOutlet    CPTableView dataTableView;
    
                DataController  dataStore;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [[theWindow contentView] setBackgroundColor: [CPColor grayColor]];
    dataStore = [DataController withExampleData];
    [dataTableView reloadData];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
}

// datasource delegate methods for dataTableView
-(int)numberOfRowsInTableView: (CPTableView)aTableView {
    var num = [[dataStore data] count];
    console.debug([dataStore data]);
    console.debug("numberOfRowsInTableView = " + num);
    return num;
}

-(id)tableView: (CPTableView)aTableView
     objectValueForTableColumn: (CPTableColumn)aTableColumn
     row: (int)rowIndex {

    var obj = nil;
    obj = [[[dataStore data] objectAtIndex: rowIndex] identifier];
    
    console.debug("Getting data for row " + rowIndex);
    console.debug("Data: " + obj);
    return obj;
}

// delegate methods for dataTableView
-(void)tableViewSelectionDidChange: (CPNotification)notification {
    console.debug("Table selection changed");
    var row = [[dataTableView selectedRowIndexes] firstIndex];
    
    if(row == -1) return;
    var selectedData = [[dataStore data] objectAtIndex: row];
    console.debug("Data selected:");
    console.debug(selectedData);
}

@end
