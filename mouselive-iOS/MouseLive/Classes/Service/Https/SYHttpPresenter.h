//
//  HttpPresenter.h
//  MVP
//
//  Created by baoshan on 17/2/8.
//  Copyright © 2017年 hans. All rights reserved.
//

#import "Presenter.h"
#import "SYHttpResponseHandle.h"

@interface SYHttpPresenter<E> : Presenter<E> <SYHttpResponseHandle>

@property (nonatomic, strong)SYHttpService *httpClient;

@end
