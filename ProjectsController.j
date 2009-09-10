@import <Foundation/CPObject.j>
@import "DemoData.j"

@implementation ProjectsController : CPObject {
    CPArray projects;
}

-(void)setProjects: (CPArray)someProjects {
    projects = someProjects;
}

-(CPArray)projects {
    return projects;
}

-(void)loadExampleProjects {
    [self setProjects: [DemoData exampleProjects]];
}

@end