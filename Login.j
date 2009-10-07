@import <Foundation/CPObject.j>
@import <AppKit/CPApplication.j>
@import <AppKit/CPPanel.j>


@implementation Login : CPObject {
    IBOutlet    CPPanel             loginPanel;
    IBOutlet    CPTextField         connectionField;
    IBOutlet    CPTextField         userField;
    IBOutlet    CPSecureTextField   passwordField;
    
                id                  delegate        @accessors;
}

-(id)init {
    self = [super init];
    
    if(self){
        if(![CPBundle loadCibNamed: "LoginPanel" owner: self]){
            CPLog("Error loading Cib for LoginPanel");
        }
        else {
            console.debug(loginPanel);
        }
    }
    
    return self;
}

-(void)runModal {
    [CPApp runModalForWindow: loginPanel];
}

-(void)login:(id)sender {
    var url = [connectionField objectValue];
    var user = [userField objectValue];
    var password = [passwordField objectValue];
    
    if(url) {
        if([delegate respondsToSelector:@selector(connectToServer:withUser:andPassword:)]) 
                            [delegate connectToServer: url withUser: user andPassword: password];
    }
    else {
        alert("Server URL must be provided.");
    }
    [CPApp abortModal];
    [loginPanel close];
}


-(void)cancel: (id)sender {
    [CPApp abortModal];
    [loginPanel close];
}


@end