#ifndef HMR_MESSAGE_SERVICE_H
#define HMR_MESSAGE_SERVICE_H

#include <Hummer/Constants.h>
#include <set>

// 消息内容数据的最大字节数，内容中一般包括内容类型、内容负载两部分
// 应谨慎处理消息最大长度问题，避免访问越界
const int32_t HMRMessageContentSize = 64*1024+1;

// 消息内容结构，每个消息携带的内容是多态的，有可能是文本、信令等。
// 应尽可能使用内容定义模块（如ContentText, ContentSignal)的构造、解析方法来进行内容的处理，而不是手动解析和构造
// 虽然data是char数组，但并不意味它一定是一个ANSI文本“字符串”。很多时候，它可能存放utf-8编码的字符串，例如HMRTextContent
struct HMRMessageContent {
	char data[HMRMessageContentSize];	// 消息内容缓冲区
	uint16_t availableSize;				// 缓冲区中有效数据的数量
};

const int32_t HMRMessageExtraSize = 64*1024+1; // 消息业务携带数据的缓冲区大小

// 每条消息都可能携带业务透传的额外信息，以便实现如“消息发送方头像”等信息的业务信息传递
struct HMRMessageExtra {
	// Extra数据缓冲区
	char data[HMRMessageExtraSize];

	// Extra数据的有效字节数
	uint16_t availableSize;
};

// 消息的状态会随着相关消息请求的处理而发生变化，它可以帮助业务进行恰当的渲染，例如失败警示灯。状态迁移如下：
// default: Init
// Init -> Delivering: Start Sending
// Delivering -> Arcivhed: Send Success
// Delivering -> Failed:   Send Failed
// 
// @discuss
// 如果state值不属于(Init, Delivering, Archrived)状态之一，则意味着是一个失败状态，取值和HMRCode值相同

const int32_t HMRMessageStateInit       = 0;	// 初始化状态，该状态下的消息可被发送
const int32_t HRMMessageStateDelivering = 2;	// 发送中，该状态下的消息当前不可再被发送、转发
const int32_t HMRMessageStateArchived   = 3;	// 归档状态，表示该消息已被成功发送，或者是一条接收自其它端的消息，可以被重发、转发

// Hummer的核心消息概念，所有的端到端消息都是经由这个结构来承载的。需要注意，HMRMessage
// 对象的资源管理使用引用计数方式来实现。因此，对于发送的消息来说，业务应自行管理其释放
// 而如果希望持有Hummer接收到的消息，应该通过调用HMRRetainMessage来保持其引用
struct HMRMessage {
	// if (state <= HMRMessageStateArchived && state >= 0) 
	// 表示确定的非失败状态，否则state值应表示发送失败，具体值为HMRCode的错误码一致
	int32_t state;

	// 消息的唯一标识符，该标识符通常是由消息发送方产生的，可帮助进行消息去重、定位等
	HMRUUID uuid;

	// 消息时间戳，对聊天室消息来说，取值都以本地时间为准。则意味着需要避免用它来进行
	// 严格的消息排序，否则可能因为恶意篡改导致排序异常
	uint64_t timestamp;		

	// 消息发送方标识，大部分情况下是一个User，也可能是业务自定义的类型，如系统服务官方号等
	HMRIdentity sender;

	// 消息接收目标标识，虽然是当前设备接收到消息，但也有可能是ChatRoom等群关系消息
	HMRIdentity receiver;		

	// 消息内容的完整负载，在实际处理时，应该通过不同的Content类型提供的来进行
	// 动态判别（例如HMRIsTextContent)。除非是业务自身拓展的类型，否则应避免直接手工解析和构造
	HMRMessageContent content;	

	// 每条消息都可以携带一定的业务透传信息，以便实现如“消息发送方头像、昵称”等数据的传递，帮助
	// 降低业务服务器的访问压力
	HMRMessageExtra extra;

	// Hummer SDK 内部使用的保留字段，业务方应禁止访问、修改该数据
	void *reserved;
};

// 消息回调函数指针类型，消息回调可能用在消息发送、接收行为上，通过提供特定回调，可以处理消息
// 的不同生命周期
// @param context 对于消息发送回调来说，context是Completion中携带的上下文对象指针透传。对
//                对接收到的消息回调来说，context为listener中携带的上下文对象指针透传
// @param message 回调对应的消息对象
typedef void (*HMRMessageCallback)(void *context, HMRMessage *message);

// 消息通道的监听器结构，通过注册该类型的监听器，可以实现消息发送、接收的生命周期监控
// 消息发送时，经常需要在发送前将消息加入UI消息列表，并在完成后更新其状态，因此发送回
// 调由before/after两个。但是消息接收本质上只有一个“已接收”的过程，因此只有一个onReceive回调
struct HMRMessageListener {
	// 异步请求的上下文对象指针，一般为发起异步操作的对象指针
	void *context;

	// target 对象用于进行消息过滤。当使用EmptyIdentity时，该监听器会接收所有消息。否则仅会
	// 接收该 target 匹配的消息
	HMRIdentity target;

	// 消息发送前的回调，收到该回调意味着消息已经经过了合法性校验，并将立即尝试将其发送到接收方
	HMRMessageCallback beforeSending;

	// 消息发送后的回调，不论成功或失败，收到该回调意味着消息已经走完了发送流程。发送的成功或失败
	// 可以通过消息对象的state字段来判断
	HMRMessageCallback afterSending;

	// 消息接收回调，当Hummer收到属于当前用户的消息时，会通过该回调进行处理
	HMRMessageCallback onReceive;

	// Hummer 内部使用的保留字段，业务方应禁止访问、修改该数据
	void *reserved;
};

extern "C" {

	/* ---- 消息对象管理 ---- */

	// 判断消息状态是否是为失败状态
	// @param 待判定失败状态的消息对象
	// @return 当消息指针为空的话，返回值的具体取值未定义，所以传参应保证message不为空指针。
	//         否则，当其状态为init, delivering, archived状态时，认为是非失败状态，并且返
	//         回false, 否则返回true，表示其为处理失败的消息
	HMR_API bool HMRIsMessageFailed(HMRMessage *message);

	// 根据消息对象获取其对应的会话目标，目前的规则为：
	// P2P Message:
	//   > sender: me,     receiver: user      target = receiver
	//   > sender: fellow, receiver: me        target = sender
	//   > sender: fellow, receiver: fellow    N/A
	// ChatRoom message:
	//   > sender: user,   receiver: chatroom		target = chatroom < broadcast
	//   > sender: user,   receiver: chatroom/user  target = chatroom < unicast
	HMR_API HMRIdentity HMRGetConversationTarget(HMRMessage *message);

	// 构造一个消息对象携带的业务透传数据实例
	HMR_API HMRMessageExtra HMRMakeMessageExtra(const char *extra, int32_t length);

	// 创建一条消息，该方法创建的消息，通常是用于HMRSendMessage方法的。它对消息结构进行必要的
	// 初始化操作，例如初始状态, uuid, timestamp等
	HMR_API HMRMessage *HMRCreateMessage(HMRIdentity receiver, HMRMessageContent content, HMRMessageExtra extra);

	// 主动增加消息对象的引用计数，以便在业务上长期持有该消息。如果不再需要使用，应调用
	// HMRReleaseMessage来解除对该消息的引用
	HMR_API void HMRRetainMessage(HMRMessage *message);

	// 释放消息对象的引用，如果所有持有者的引用都被释放，则该消息会被释放
	HMR_API void HMRReleaseMessage(HMRMessage *message);


	/* ---- 消息发送、接收 ---- */

	// 消息通道的消息发送方法
	// @param message 待发送的消息对象，仅当消息对象有效时，才会被发送。下述消息无法被发送
	//                1. state 为 Delivering的消息
	//                2. receiver无效的消息
	//                3. content为空的消息
	//                4. uuid无效的消息
	// @param completion 消息发送的异步回调
	// @discuss send请求果是在主线程发起的，则回调也会在主线程中执行，否则会在Hummer的独立工作线程执行
	HMR_API void HMRSendMessasge(HMRMessage *message, HMRCompletion completion);

	/**
	 * 监听者模式，添加消息监听器
	 * 根据谁申请谁释放的原则，业务添加监听器后，要管理好资源释放
	 * 释放监听器的同时需调用 HMRRemoveMessageListener 移除sdk的监听器引用
	 */
	HMR_API void HMRAddMessageListener(HMRMessageListener *listener);

	/**
	 * 监听者模式，移除消息监听器
	 * 根据谁申请谁释放的原则，业务移除监听器后，应自行处理资源释放
	 */
	HMR_API void HMRRemoveMessageListener(HMRMessageListener *listener);
}

#endif // !HMR_MESSAGE_SERVICE_H
