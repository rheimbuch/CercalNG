/*
 * AppController.j
 * CercalNG
 *
 * Created by You on September 10, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "DataController.j"
@import "DataView.j"
@import "Login.j"


@implementation AppController : CPObject
{
    IBOutlet    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    IBOutlet    CPTableView dataTableView;
    IBOutlet    CPTextField dataTableSearchField;
    IBOutlet    DataView    dataView;
    IBOutlet    CPTextField locationLabel;
    
                Login       loginPanel;

    
                DataController  dataStore;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [[theWindow contentView] setBackgroundColor: [CPColor grayColor]];
    //dataStore = [DataController withExampleData];
    dataStore = [[DataController alloc] init];
    [dataStore setDelegate: self];
    //[dataTableView reloadData];
    [dataView setDataStore: [dataStore dataStore]];
    
    // Setup location label observing
    [locationLabel setStringValue: [dataStore urlPath]];
    [dataStore addObserver: self forKeyPath:"urlPath" options: CPKeyValueObservingOptionNew context: nil];
    
    loginPanel = [[Login alloc] init];
    [loginPanel setDelegate: self];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
    
}

// Handle observing
-(void)observeValueForKeyPath:(CPString)keyPath
        ofObject:(id)object
        change:(CPDictionary)change
        context:(id)context {

    console.debug("location changed");
    [locationLabel setStringValue: [dataStore urlPath]];

}

-(void)queryDataWith: (id)sender {
    console.debug(sender);
    var query = [sender stringValue];
    if(query){
        var fullQuery = "?metadata." + query;
        [dataStore setQuery: fullQuery];
    }
    else {
        [dataStore setQuery: ""];
    }
}

// datacontroller delegate methods
-(void)dataStore:(DataController)ds didReceiveData:(CPArray)data {
    [dataTableView reloadData];
}

// datasource delegate methods for dataTableView
-(int)numberOfRowsInTableView: (CPTableView)aTableView {
    var num = [[dataStore data] count];
    console.debug("numberOfRowsInTableView = " + num);
    return num;
}

-(id)tableView: (CPTableView)aTableView
     objectValueForTableColumn: (CPTableColumn)aTableColumn
     row: (int)rowIndex {

    if(aTableView === dataTableView){
        var obj = nil;
        obj = [[dataStore data] objectAtIndex: rowIndex].id;
    
        console.debug("Getting data for row " + rowIndex);
        console.debug("Data: " + obj);
        return obj;
    }

}

// delegate methods for dataTableView
-(void)tableViewSelectionDidChange: (CPNotification)notification {
    console.debug("Table selection changed");
    var row = [[dataTableView selectedRowIndexes] firstIndex];
    
    if(row == -1) return;
    console.debug([dataStore data]);
    TESTDATA = [dataStore data];
    var selectedData = [[dataStore data] objectAtIndex: row];
    console.debug("Data selected:");
    console.debug(selectedData);
    
    console.debug("Setting dataView dataItem");
    [dataView setDataItem: selectedData];
}


-(void)connectTo:(id)sender {
    [loginPanel runModal];
}

// Login delegate method
-(void)connectToServer: (CPString)url {
    console.debug("Connecting to: " + url);
    [dataStore setUrlPath: url];
}


-(void)showAboutDialog:(id)sender {
    var dialog = [[CPAlert alloc] init];
    [dialog setAlertStyle: CPInformationalAlertStyle];
    [dialog setTitle: "About"];
    [dialog setMessageText: "Designed by the Yogo development team."];
    [dialog addButtonWithTitle:"Close"];
    [dialog runModal];
    console.debug(dialog);
}

@end
