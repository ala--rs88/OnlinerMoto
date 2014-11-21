//
//  HTMLNode+Swift.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 20.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNode.h"

@interface HTMLNode (Swift)

typedef NS_ENUM(NSInteger, HTMLNodeType_Swift)
{
    HTMLUnknown_Swift,
    HTMLPNode_Swift
};

- (HTMLNodeType_Swift)nodetype_Swift;

@end
