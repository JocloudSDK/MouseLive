#ifndef HMR_CORE_H
#define HMR_CORE_H

#include "Hummer/Constants.h"


// 业务鉴权token最大数据长度 
const int HMRTokenBufferSize = 1024;

// Hummer在open的过程中会向业务层索取某个uid的鉴权token，由于这种获取行为是一种异步回调操作
// @param uid 向业务索取的token所对应的用户uid，该值由Hummer内部传入Provider回调
// @param outToken App获取到的token内容
// @param tokenType 指定token类型
// @return App业务在获取token时返回的操作码，建议在成功获取时返回HMRCodeSuccess，在失败时返回10000以上的业务自定义错误码
// @discuss 该方法应实现**同步**获取token的语义，否则无法正常工作
typedef HMRCode(*HMRTokenProvider)(uint64_t uid, char outToken[HMRTokenBufferSize], int& tokenType);

// 业务自定义Token
typedef HMRCode(*HMRThirdUserTokenProvider)(uint64_t uid, char outToken[HMRTokenBufferSize]);

// Hummer的当前工作状态，其状态迁移描述如下：
// {
//   default: Unavailable
//   Unavailable -> Closed: HMRInit
//   Closed -> Opening: HMROpen Start
//   Opening -> Opened: HMROpen Success
//   Opening -> Closed: HMROpen Failed
//   Opened -> Closed:  HMRClose
// }
enum HMRState {
	// 如果Hummer处于Unavailable状态，说明SDK没有得到正确的初始化（init），请使用HMRInit方法初始化SDK后
	HMRStateUnavailable = -1,

	// Hummer处于未登录状态，此时几乎所有的Hummer服务都是不可用的
	HMRStateClosed  = 0,

	// 由于HMROpen操作是异步的，因此有一个Opening状态，业务接入时，可以利用该状态来控制UI界面呈现，例如显示（连接中……）
	HMRStateOpening = 1,

	// 当成功执行了用户登陆操作，Hummer会处于HMRStateOpened状态。且仅当处于该状态时，Hummer的用户相关服务才是可用的。
	HMRStateOpened  = 2,
};

/**
* Token 失效类型
*/
enum HMRTokenInvalidCode {
	/** 过期 */
	HMRTokenInvalidCode_Expired = 1,
};

// Hummer状态变更的回调接口
// @param context	请求上下文对象，透传自回调执行时，从listener取出的context
// @param isInitial 请求HMRAddStateListener时会立即触发一次回调，该次回调的isInitial值为true，后续收到实际变更时，其值为false
// @param oldState  当isInitial为false时，状态发生了变更，oldState用于表示变更前的状态值。如果isInitial为true，oldState、newState均为当前状态，任取其一即可
// @param newState  当isInitial为false时，状态发生了变更，newState用于表示变更后的状态值。如果isInitial为true，oldState、newState均为当前状态，任取其一即可
typedef void(*HMRStateCallback)(void *context, bool isInitial, HMRState oldState, HMRState newState);

// Hummer Token失效回调接口
// @param context	请求上下文对象，透传自回调执行时，从listener取出的context
// @param code		Token失效类型
// @param desc		Token失效描述
// @param descsize	Token失效描述字符串长度
typedef void(*HMRTokenInvalidCallback)(void *context, HMRTokenInvalidCode code, const char *desc, int descsize);

// Hummer Token过期回调接口
// @param context	请求上下文对象，透传自回调执行时，从listener取出的context
typedef void(*HMRPreviousTokenExpired)(void *context);

struct HMRStateListener {
	// 异步请求的上下文对象指针，一般为发起异步操作的对象指针
	void *context;

	// 状态变更回调函数指针，在Hummer内部工作状态发生变化时，会通过该方法进行回调
	// 如果是在主线程添加的listener，则该回调也会被调度到主线程，否则会在Hummer工作线程调度执行
	HMRStateCallback onStateCallback;

	// Token失效回调函数指针
	// 如果是在主线程添加的listener，则该回调也会被调度到主线程，否则会在Hummer工作线程调度执行
	HMR_DEPRECATED("Using onTokenExpiredCallback instead") HMRTokenInvalidCallback onTokenInvalidCallback;

	// Token过期回调函数指针
	// 如果是在主线程添加的listener，则该回调也会被调度到主线程，否则会在Hummer工作线程调度执行
	HMRPreviousTokenExpired onPreviousTokenExpiredCallback;

	// Hummer内部辅助数据，业务方请勿修改或使用
	void *preserved;
};

extern "C" {

	/* ---- 核心生命周期管理 ---- */

	// 获取Hummer当前的工作状态，状态的详细解释清参照HMRState的具体定义和说明
	// @return Hummer当前的工作状态
	HMR_API HMRState HMRGetState();

	// 增加Hummer工作状态监听器，同一个监听器的多次添加操作（未被移除前）会被忽略
	HMR_API void HMRAddStateListener(HMRStateListener *listener);

	// 移除Hummer工作状态监听器，移除不存在的监听器操作会被忽略
	HMR_API void HMRRemoveStateListener(HMRStateListener *listener);

	// 初始化Hummer，仅当初始化完成后，Hummer才具备业务唯一标示（appid），且Hummer进入Closed状态。具体参见HMRState定义。
	// appId的具体取值，应向Hummer服务提供方申请，**目前仅支持人工申请和审核**
	HMR_API void HMRInit(uint64_t appId);

	// Hummer用户登录
	//
	// @param uid 用户uid
	// @param region 接入的Hummer服务区域，该值应该是业务登录后，由业务服务器返回给客户端的，并应该由业务代码透传给Hummer，不可为空
	// @param tokenProvder 用于获取用户识别token的同步回调方法指针，不可为空
	// 
	// @discuss open和close操作是匹配使用的。仅在HMRStateClosed状态时，open才会正常工作，否则open请求会被忽略
	HMR_API_DEPRECATED("Using HMROpenWithStringToken instead")
	void HMROpen(uint64_t uid, const char *region, HMRThirdUserTokenProvider tokenProvider, HMRCompletion completion);
	
	HMR_API_DEPRECATED("Using HMROpenWithStringToken instead") 
	void HMROpenWithCustomToken(uint64_t uid, const char *region, HMRTokenProvider tokenProvider, HMRCompletion completion);

	// Hummer用户登录
	//
	// @param uid 用户uid
	// @param region 接入的Hummer服务区域，该值应该是业务登录后，由业务服务器返回给客户端的，并应该由业务代码透传给Hummer，不可为空
	// @param token 用于服务初始化时所需的token
	// @param completion 请求的异步回调
	// 
	// @discuss open和close操作是匹配使用的。仅在HMRStateClosed状态时，open才会正常工作，否则open请求会被忽略
	HMR_API void HMROpenWithStringToken(uint64_t uid, const char *region, const char *token, HMRCompletion completion);

	// Hummer用户注销
	// @discuss 仅在HMRStateOpened状态时，close才会正常工作，否则close请求会被忽略
	HMR_API void HMRClose();

	// 刷新用户凭证
	// @param token 待刷新用户凭证
	//
	// @remark 对于使用TokenProvider的模式，SDK会在需要的时候主动回调刷新Token，
	// 这种模式下，无需使用refreshToken接口来刷新Token；
	// 
	// 如果当前为TokenProvider的模式，调用refreshToken接口，将会立即触发一次Token校验流程，
	// 且该Token仅会被消费一次，后续SDK会在需要的时候主动回调TokenProvider刷新Token
	HMR_API_DEPRECATED("Using HMRRefreshTokenWithCompletion instead") 
	void HMRRefreshToken(const char *token);

	// 刷新用户凭证，并返回校验结果
	// @param token 待刷新用户凭证
	// @param completion 请求的异步回调
	//
	// @remark 对于使用TokenProvider的模式，SDK会在需要的时候主动回调刷新Token，
	// 这种模式下，无需使用refreshToken接口来刷新Token；
	// 
	// 如果当前为TokenProvider的模式，调用refreshToken接口，将会立即触发一次Token校验流程，
	// 且该Token仅会被消费一次，后续SDK会在需要的时候主动回调TokenProvider刷新Token
	HMR_API void HMRRefreshTokenWithCompletion(const char *token, HMRCompletion completion);


	/* ---- 用户上下文信息 ---- */

	// 获取当前用户的uid
	// @return 如果用户已登录，则返回当前用户uid，否则返回的数据无意义
	HMR_API uint64_t HMRGetOwnUID();

	
	// 获取Hummer的版本号
	HMR_API const char *HMRGetVersion();

	// Hummer的日志回调方法指针，业务可通过实现该日志回调来接管Hummer的日志记录事宜
	typedef void(*HMRLogFunction)(const char *message);
	
	// 设置Hummer日志记录回调
	// @discuss
	// Hummer的统一日志格式为：
	//     <level>/HMR (thread_name) [TAG] method | message { detail_key1: detail_value1, ... }
	// 1. 日志信息中没有包含时间信息，该部分信息由业务来进行补充（主要是考虑到如iOS之类的平台一定会强行加上时间信息，导致冗余）
	// 2. 目前来说，日志等级过滤的控制放在了Hummer内部，暂时没有提供业务控制的能力
	HMR_API void HMRSetLogger(HMRLogFunction logFunction);
}

#endif // !HMR_CORE_H
