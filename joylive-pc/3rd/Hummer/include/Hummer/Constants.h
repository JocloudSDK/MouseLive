#pragma once


#define HMR_DEPRECATED(msg) __declspec(deprecated("Function Deprecated!"##msg))
#ifdef HUMMER_EXPORTS
#define HMR_API __declspec(dllexport)
#define HMR_API_DEPRECATED(msg) __declspec(dllexport, deprecated("Function Deprecated!"##msg))
#else
#define HMR_API __declspec(dllimport)
#define HMR_API_DEPRECATED(msg) __declspec(dllimport, deprecated("Function Deprecated!"##msg))
#endif

#include <stdint.h>   // 定长整数类型定义，如int32_t等，避免不同编译器、指令集下的处理结果不一致 
#include <stdbool.h>  // C99的bool定义


// HMRCode是Hummer用于表示结果的数值类型，具体取值及含义请参照码表
// 一般来说，分为几个类别：
// 0: 操作成功
// [1000, 1999)	客户端产生的异常
// [2000, 9999)	服务器产生的异常
// [10000, +∞)	业务自定义的异常
// -1: 未定义的错误
// 同一个代码只表示一种错误的大致类型，具体的错误含义是和当时的操作上下文息息相关的
typedef int32_t HMRCode;

const HMRCode HMRCodeSuccess					= 0;	// 操作成功
const HMRCode HMRCodeUnknown					= 1;	// 未知错误

const HMRCode HMRCodeClientExceptions			= 1000;	// 通用客户端错误，如果在下面的错误码表中没有更匹配的错误类型，则会使用该错误码进行表示
const HMRCode HMRCodeUninitialized				= 1001;	// 表示Hummer未被正确初始化
const HMRCode HMRCodeInvalidParameters			= 1002;	// 请求Hummer服务时，提供了无效的错误参数
const HMRCode HMRCodeIOError					= 1003;	// 表示遇到了本地IO操作相关的错误，例如数据库访问异常等
const HMRCode HMRCodeNetworkNotFound			= 1004;	// 如果发起需要网络服务，但是请求时网络不可达，则会返回该错误，建议提示用户检查网络连接并重试
const HMRCode HMRCodeOperationTimeout			= 1005;	// 网络操作超时，建议提示用户检查网络连接并重试
const HMRCode HMRCodeConnectionTimeout			= 1006;	// 网络连接超时，通常是由于网络虽然连通，但是因为网络条件比较恶劣导致的，建议提示用户检查网络连接并重试
const HMRCode HMRCodeConnectionFailed			= 1007;	// 无法建立可用的网络连接
const HMRCode HMRCodeThrottling					= 1008;	// 服务请求调用过于频繁，建议业务端需要进行频率控制
const HMRCode HMRCodeUnauthorized				= 1009;	// 操作鉴权失败，通常意味着当前用户鉴权失败
const HMRCode HMRCodeThirdPartyError			= 1010;	// 调用第三方服务发生错误
const HMRCode HMRCodeBadUser					= 1011;	// 如果业务没有正确处理用户上下文切换，例如业务已经注销了用户，但是没有调用Hummer.close，则会产生该错误

const HMRCode HMRCodeProtocolError				= 2000;	// 传输协议异常，例如协议版本错误等
const HMRCode HMRCodeInvalidContent				= 2001;	// 协议内容校验失败，例如消息内容过长等
const HMRCode HMRCodeTokenInvalid				= 2002;	// 用于进行权限验证的Token无效
const HMRCode HMRCodeTokenExpired				= 2003;	// 用于进行权限验证的Token已经失效
const HMRCode HMRCodeResourceNotFound			= 2004;	// 请求访问的资源不存在
const HMRCode HMRCodeResourceAlreadyExist		= 2005;	// 请求访问的资源已存在，通常在创建房间等场景出现
const HMRCode HMRCodeLimitExceeded				= 2006;	// 资源、关系数量超出了限定值
const HMRCode HMRCodeMessageSizeLimitExceeded	= 2007;	// 消息长度超出了上限

const HMRCode HMRCodeAccessDenied				= 3000;	// 访问被拒绝，经常出现在通信通道协议uid和实际请求业务uid不匹配的情况下
const HMRCode HMRCodeBlacklisted				= 3001;	// 用户被列入黑名单，无法获得CIM服务
const HMRCode HMRCodeTemporarilyDenied			= 3002;	// 暂时没有权限
const HMRCode HMRCodeForbidden					= 3003;	// 操作被禁止
const HMRCode HMRCodeUserForbidden				= 3004;	// 用户操作被禁止
const HMRCode HMRCodeBanned						= 3005; // 操作被封禁
const HMRCode HMRCodeChallengeNeeded			= 3006; // 需要输入参数进行验证
const HMRCode HMRCodeInspectionFailed			= 3007; //审查失败

const HMRCode HMRCodeInternalServerError		= 4000; // 服务器内部异常
const HMRCode HMRCodeServiceUnavailable			= 4001; // 暂时无法提供IM服务，一般为服务器进程重启等原因导致
const HMRCode HMRCodeBusinessServerError		= 4002; // 业务服务异常
const HMRCode HMRCodeServiceThrottling			= 4003; // 服务请求调用过于频繁，建议业务端需要进行频率控制

const HMRCode HMRCodeUndefinedExceptions		= -1;   // 其它未定义异常类型

static const char* HMRMultiJoinFlag				= "join_props_multijoin_by_instanceId"; //当加入频道时，在joinProps中加入该key设置互踢模式， value '0'表示不互踢，'1'表示互踢

// Hummer中，用于表示操作结果的通用结构，包括同步操作、异步操作
struct HMRResult {
	// 请查看上面的错误码表定义
	HMRCode code;

	// 对code的可读文本解释，ANSI编码
	char msg[256];
};

struct HMRIdArray {
	uint32_t len;
	uint64_t* ids;
};

struct HMRStrArray {
	uint32_t len;
	const char** strs;
};

struct HMRKvItem {
	const char* key;
	const char* value;
};

struct HMRKvArray {
	uint32_t len;
	HMRKvItem *items;
};

// 一个多态的简单数据结构，其取值视不同的异步API而不同，该值有不同的解释，具体解读，应参照对应上下文的API文档
union HMRVariant {
	void     *ptrValue;
	char     *stringValue;
	uint32_t intValue;
	uint64_t longValue;
};

// Hummer中异步操作回调的函数指针，该技术会被用在类似频道加入（JoinChatRoom），消息发送（SendMessage）等异步操作中
//
// @param context 操作上下文对象指针，一般表示发起异步操作的对象指针
// @param requestId 业务在构造completion时自行传入的请求id标示。该id的唯一性由业务自行保证。通常用于帮助业务进行异步请求上下文映射和恢复
// @param result Hummer执行异步操作的操作结果对象，一般用于表示该操作是否成功，以及具体的错误原因等
// @param var 一个多态的简单数据结构，其取值视不同的异步API而不同，该值有不同的解释
typedef void (*HMROnComplete)(void* context, uint64_t requestId, HMRResult result, HMRVariant var);

// Hummer中用于处理异步完成回调的结构，它持有一些帮助异步API产生回调的数据，以便在操作完成时更方便地进行回调处理
// !!应使用SDK提供的HMRMakeCompletion系列方法来构造completion实例，而不是直接使用{}initializer构造使用该对象，否则可能导致访问异常。
struct HMRCompletion {
	// 异步请求的上下文对象指针，一般为发起异步操作的对象指针
	void *context;

	// 业务在构造completion时自行传入的请求id标示。该id的唯一性由业务自行保证。通常用于帮助业务进行异步请求上下文映射和恢复
	uint64_t requestId;

	// 用于实际执行回调的函数指针
	HMROnComplete onComplete;

	// Hummer内部辅助数据，业务方请勿修改或使用
	void *reserved;
};

// 每个消息都有一个唯一标识符，以便进行消息去重，查询定位等操作
struct HMRUUID {
	// 有效长度为36字节：16 * 2 (bytes) + 4 (delimiters) + 1 (terminator)，但考虑到内存对齐问题，使用40字节
	char string[40];
};

// 用于表示一个Id类型的协议结构，该类型的实例会被用在Hummer所有
// 需要区分实体唯一性的场合，例如用户、聊天室、群组等
struct HMRIdentity {
	// string用于存放多种id类型的字符串表示
	// 例如表示：
	//    用户1234：  user_1234
	//    聊天室8876: chatroom_8876
	// 具体內容的构造、解析，应始终使用HMRMakeXXXIdentity系列/HMRExtractXXXId类型的工厂方法，而不是认为直接生成。例如HMRMakeUserIdentity
	char string[128];
};

extern "C" {
	// 检测两个HMRIdentity实例是否相等
	//
	// @param lhs 待检测的id对象
	// @param rhs 待检测的id对象
	// @return 如果lhs或者rhs为空指针，则认为一定是不相等的。否则当在它们的type和id值均相等时，认为二者时相等的。
	//         如果相等，则返回1，否则返回0
	HMR_API bool HMRIdentityEquals(HMRIdentity lhs, HMRIdentity rhs);

	// 检查一个identity对象是否为“空的”
	// 在MessageListener中会持有一个Identity对象以便进行消息过滤，但由于持有的是对象实体，而不是对象的指针，后者有
	// 资源生命周期的问题。而为了支持监听“所有会话目标”消息的语义，需要一个“空”identity的概念。
	// @return 如果id.idString 
	HMR_API bool HMRIsEmptyIdentity(HMRIdentity id);

	// 构造一个空Identity实例，空实例一般用于表示没有identity，并实现如“不过滤消息”等语义
	HMR_API HMRIdentity HMREmptyIdentity();

	// 构造一个用户Identity对象
	//
	// @param uid 用户uid
	// @return 用于表示传入uid的Hummer使用的Identity实例
	HMR_API HMRIdentity HMRMakeUserIdentity(uint64_t uid);

	// 从一个Identity实例中抽取用户uid，以便进行例如UI显示等操作
	//
	// @param identity 用户分析、抽取uid的Identity实例对象
	// @param outUID [输出] 如果identity实例中包含的确实是一个User对象，则outUID会写入返回其对应的uid值，否则无意义
	// @return 如果identity对象确实是一个User对象，则返回HMRCodeSuccess, 否则返回HMRCodeInvalidParamters
	HMR_API HMRCode HMRExtractUserId(HMRIdentity identity, uint64_t *outUID);

	// 判断identity实例是否是一个User Identity
	//
	// @return 如果identity是用户实例，则返回true，否则返回false
	HMR_API bool HMRIsUser(HMRIdentity identity);

	// 判断identity实例是否是一个匿名用户实例
	//
	// @return 如果identity是用户实例，且其uid为0，则返回true，否则返回false
	HMR_API bool HMRIsAnonymousUser(HMRIdentity identity);

	// 构造一个标准的Hummer异步回调对象
	// @param context 在执行completion方法时会回传的上下文对象，一般用于帮助业务找回请求发起时的操作上下文对象
	// @param requestId 业务决议的请求id，可以帮助业务映射、找回请求上下文的更多信息
	// @param onComplete 异步回调方法指针
	// @return 将context, requestId, onComplete等参数打包到一起，并返回该数据集合
	HMR_API HMRCompletion HMRMakeCompletion(void *context, uint64_t requestId, HMROnComplete onComplete);
}
