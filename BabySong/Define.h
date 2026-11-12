//
//  Define.h
//  BabySong
//
//  Created by qianfeng on 15/7/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#ifndef BabySong_Define_h
#define BabySong_Define_h

////首页url
//#define kRecommendUrl @"http://api.yuerbang.me/audio/phone/v1/recommend?page=%ld&pageSize=%ld"
//
////分类url
//#define kSortUrl @"http://api.yuerbang.me/audio/phone/v1/category"
////首页详情url
//#define kHomeDisplaylUrl @"http://api.yuerbang.me/audio/phone/v1/audio/%@?"
////分类详情页url
//#define kSortDisplayUrl @"http://api.yuerbang.me/audio/phone/v1/category/%@?"
////搜索url
//#define kSearchUrl @"http://api.yuerbang.me/audio/phone/v1/search?name=%@&"
//#define kDetailUrl @"http://api.yuerbang.me/audio/phone/v1/audio/%@?"

#define list @"list"

//首页url
#define kRecommendUrl @"http://subapp.ximalaya.com/index/821?page_id=%ld&pageSize=%ld"

//分类url
#define kSortUrl @"http://api.yuerbang.me/audio/phone/v1/category"
//首页详情url
#define kHomeDisplaylUrl @"http://subapp.ximalaya.com/821/bozhus/%ld"
//分类详情页url
#define kSortDisplayUrl @"http://api.yuerbang.me/audio/phone/v1/category/%@?"
//搜索url
#define kSearchUrl @"http://api.yuerbang.me/audio/phone/v1/search?name=%@&"
#define kDetailUrl @"http://api.yuerbang.me/audio/phone/v1/audio/%@?"


#define kScreenSize [UIScreen mainScreen].bounds.size


/* ============================================================
 *  喜马拉雅开放平台凭证 —— ⚠️ 使用前必须替换成你自己的
 *
 *  这四个占位符不能原样跑起来，需要按下面步骤换成真实值：
 *    1. 到 https://open.ximalaya.com/ 注册开发者、创建应用，拿到 AppKey 和 Secret
 *    2. sig 是用 Secret 对 app_key + nonce + timestamp + 其他参数串算出来的
 *       签名，不是固定字符串，参数一变签名就跟着变，不能复制一个别处的值
 *    3. 专辑 ID 在 DisplayViewController 里（album_id=14501623），
 *       换成你要拉取的专辑
 *
 *  改完这四项，DisplayViewController 里的专辑列表接口才能拉到数据；
 *  不换的话接口会返回签名校验失败。
 * ============================================================ */
#define kXimalayaAppKey     @"YOUR_APP_KEY"
#define kXimalayaNonce      @"YOUR_NONCE"
#define kXimalayaTimestamp  @"YOUR_TIMESTAMP"
#define kXimalayaSig        @"YOUR_SIG"

#endif
