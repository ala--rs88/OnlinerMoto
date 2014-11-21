//
//  HTMLNode+Swift.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 20.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

#import "HTMLNode+Swift.h"

@implementation HTMLNode (Swift)

- (HTMLNodeType_Swift)nodetype_Swift
{
    HTMLNodeType_Swift swiftType = (self.nodetype == HTMLPNode)
        ? HTMLPNode_Swift
        : HTMLUnknown_Swift;
    return swiftType;
}

@end
