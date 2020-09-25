//
//  CCService.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/10.
//  Copyright © 2020 sy. All rights reserved.
//

#include "CCService.h"
#include "CSWSService.h"

CCService::CCService() {
	_pCSWSService.reset(new CSWSService);
}

CCService::~CCService() {
}

void CCService::joinRoom() {
	_pCSWSService->joinRoom();
}

void CCService::leaveRoom() {
	_pCSWSService->leaveRoom();
}

void CCService::setUseWS(bool ws) {
	if (_pCSWSService) {
		_pCSWSService->addObserver(_pCCServiceObserver);
	}
}

bool CCService::sendApply(const std::string& body) {
	return _pCSWSService->sendApply(body);
}

bool CCService::sendAccept(const std::string& body) {
	return _pCSWSService->sendAccept(body);
}

bool CCService::sendReject(const std::string& body) {
	return _pCSWSService->sendReject(body);
}

bool CCService::sendCancel(const std::string& body) {
	return _pCSWSService->sendCancel(body);
}

bool CCService::sendHangup(const std::string& body) {
	return _pCSWSService->sendHangup(body);
}

bool CCService::sendMicEnable(const std::string& body) {
	return _pCSWSService->sendMicEnable(body);
}

bool CCService::sendJoinRoom(const std::string& body) {
	return _pCSWSService->sendJoinRoom(body);
}

bool CCService::sendLeaveRoom(const std::string& body) {
	return _pCSWSService->sendLeaveRoom(body);
}
