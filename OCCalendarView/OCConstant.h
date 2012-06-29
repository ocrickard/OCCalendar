//
//  OCConstant.h
//  OCCalendar
//
//  Created by Lin Robi on 12-6-29.
//  Copyright (c) 2012年 UC Berkeley. All rights reserved.
//

#ifndef OCCalendar_OCConstant_h
#define OCCalendar_OCConstant_h
    
#define MARGIN_TOP                          10
#define MARGIN_BOTTOM                       10
#define MARGIN_LEFT                         15
#define MARGIN_RIGHT                        15

#define ANCHOR_HEIGHT                       12

#define DEFAULT_GRID_WIDTH                  35
#define DEFAULT_GRID_HEIGHT                 25
#define DEFAULT_ARROWBOX_WIDTH              30
#define DEFAULT_ARROWBOX_HEIGHT             35
#define DEFAULT_MON_TITLE_WIDTH             200
#define DEFAULT_MON_TITLE_HEIGHT            18
#define DEFAULT_WEEK_TITLE_HEIGHT           24

#define DEFAULT_WEEK_TITLE_Y                MARGIN_TOP + DEFAULT_MON_TITLE_HEIGHT + ANCHOR_HEIGHT
#define DEFAULT_DAYS_VIEW_Y                 MARGIN_TOP + DEFAULT_MON_TITLE_HEIGHT + DEFAULT_WEEK_TITLE_HEIGHT + ANCHOR_HEIGHT

#define DEFAULT_PAD_WIDTH                   380
#define DEFAULT_PAD_HEIGHT                  250
#define DEFAULT_PHONE_WIDTH                 260
#define DEFAULT_PHONE_HEIGHT                230

#define UI_USER_INTERFACE_IDIOM() \
([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
    [[UIDevice currentDevice] userInterfaceIdiom] : UIUserInterfaceIdiomPhone)

#endif
