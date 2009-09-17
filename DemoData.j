@import <Foundation/CPObject.j>

@implementation DemoData : CPObject 

+(id)exampleProjects {
    var projects = [
        {
            id: "1",
            __id: "/Project/1",
            name: "Sample Project 1"
        },
        {
            id: "2",
            __id: "/Project/2",
            name: "Sample Project 2"
        },
        {
            id: "3",
            __id: "/Project/3",
            name: "Sample Project 3"
        },
        {
            id: "4",
            __id: "/Project/4",
            name: "Sample Project 4"
        }
    ];
    return projects;
}

+(id)exampleData {
    var data = [
        {
            id:"1",
            __id:"/Data/1",
            source: [],
            project: {'$ref':"/Project/1"},
            description: "",
            metadata: {
                author:"Ryan Heimbuch"
            },
            datafile: {'$ref':"/File/1"}
        },
        {
            id:"2",
            __id:"/Data/2",
            source: [{'$ref':'/Data/1'}],
            project: {'$ref':"/Project/1"},
            description: "Derivative of Data/1",
            metadata: {
                author:"Ryan Heimbuch"
            },
            datafile: {'$ref':"/File/3"}
        },
        {
            id:"3",
            __id:"/Data/3",
            source: [{'$ref':'/Data/1'}],
            project: {'$ref':"/Project/1"},
            description: "Image rendering",
            metadata: {
                author:"Ryan Heimbuch"
            },
            datafile: {'$ref':"/File/5"}
        }
    ];
    return data;
}

@end