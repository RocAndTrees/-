//
//  GCD.m
//  ThreadDemo
//
//  Created by pxl on 2017/5/2.
//  Copyright © 2017年 pxl. All rights reserved.
//

#import "GCD.h"

@implementation GCD

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
//写在这个中间的代码,都不会被编译器提示-Wdeprecated-declarations类型的警告


+(void)createQueue{
    //创建队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    //OBJECTIVE-C
    //串行队列
    dispatch_queue_t queue0 = dispatch_queue_create("tk.bourne.testQueue", NULL);
    dispatch_queue_t queue1 = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_SERIAL);
    //并行队列
    dispatch_queue_t queue2 = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //全局并行队列
    dispatch_queue_t queue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+(void)sync_async{
    //1. example Default
    //创建队列
    dispatch_queue_t queue = dispatch_get_main_queue();

    //同步任务： 会阻塞当前线程 (SYNC)
    
    dispatch_sync(queue, ^{
        //code here
        NSLog(@"%@", [NSThread currentThread]);
    });
    //异步任务：不会阻塞当前线程 (ASYNC)
    dispatch_async(queue, ^{
        NSLog(@"%@", [NSThread currentThread]);
    });

    //2. example About sync
    NSLog(@"之前 - %@", NSThread.currentThread);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"sync - %@", NSThread.currentThread);
    });
    NSLog(@"之后 - %@", NSThread.currentThread);

    //3. example about async
    dispatch_queue_t queue3 = dispatch_queue_create("MyQueue", DISPATCH_QUEUE_SERIAL);
    
    
    NSLog(@"之前 - %@", NSThread.currentThread);
    
    dispatch_async(queue3, ^{
        NSLog(@"sync之前 - %@", NSThread.currentThread);
        
        //queue 是一个串行队列，一次执行一个任务，所以 sync 的 Block 必须等到前一个任务执行完毕，可万万没想到的是 queue 正在执行async的任务就是被 sync 阻塞了的那个。于是又发生了死锁。所以 sync 所在的线程被卡死了。
        dispatch_sync(queue, ^{
            NSLog(@"sync - %@", NSThread.currentThread);
        });
        NSLog(@"sync之后 - %@", NSThread.currentThread);

    });
    
    NSLog(@"之后 - %@", NSThread.currentThread);
}


/**
 队列组
 
 队列组可以将很多队列添加到一个组里，这样做的好处是，当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们。下面是使用方法，这是一个很实用的功能。
 */
+(void)threadGroup{
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //3.多次使用队列组的方法执行任务, 只有异步方法
    //3.1.执行3次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 3; i++) {
            NSLog(@"group-01 - %@", [NSThread currentThread]);
        }
    });
    
    //3.2.主队列执行8次循环
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 8; i++) {
            NSLog(@"group-02 - %@", [NSThread currentThread]);
        }
    });
    
    //3.3.执行5次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"group-03 - %@", [NSThread currentThread]);
        }
    });
    
    //4.都完成后会自动通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 - %@", [NSThread currentThread]);
    });
}


+(void)exampleBarrier{
    dispatch_queue_t queue2 = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);

        NSLog(@"主前 - %@", [NSThread currentThread]);
    dispatch_barrier_sync(queue2, ^{
        NSLog(@"dispatch_barrier_sync - %@", [NSThread currentThread]);
    });
    dispatch_barrier_async(queue2, ^{
        NSLog(@"dispatch_barrier_async - %@", [NSThread currentThread]);
    });

    NSLog(@"主后 - %@", [NSThread currentThread]);
    
}

+(void)example{

    [GCD exampleBarrier];
}

/**
 func dispatch_barrier_async(_ queue: dispatch_queue_t, _ block: dispatch_block_t):
 这个方法重点是你传入的 queue，当你传入的 queue 是通过 DISPATCH_QUEUE_CONCURRENT 参数自己创建的 queue 时，这个方法会阻塞这个 queue（注意是阻塞 queue ，而不是阻塞当前线程），一直等到这个 queue 中排在它前面的任务都执行完成后才会开始执行自己，自己执行完毕后，再会取消阻塞，使这个 queue 中排在它后面的任务继续执行。
 如果你传入的是其他的 queue, 那么它就和 dispatch_async 一样了。
 func dispatch_barrier_sync(_ queue: dispatch_queue_t, _ block: dispatch_block_t):
 这个方法的使用和上一个一样，传入 自定义的并发队列（DISPATCH_QUEUE_CONCURRENT），它和上一个方法一样的阻塞 queue，不同的是 这个方法还会 阻塞当前线程。
 如果你传入的是其他的 queue, 那么它就和 dispatch_sync 一样了。
 */



#pragma clang diagnostic pop



@end
