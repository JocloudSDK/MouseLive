#include "Status.h"

void Status::InitStatus(int initStatus, StatusProc initFunction) {
	m_iStatus = initStatus;
	if (initFunction)
		initFunction();
}

void Status::Register(int currentStatus, int nextStatus, int failedStatus, StatusProc next, StatusProc failed) {
	m_oStatusMap.insert(std::pair<int, StatusPair>(currentStatus, StatusPair(StatusKeyPair(nextStatus, next), StatusKeyPair(failedStatus, failed))));
}

void Status::Do() {
	auto p = m_oStatusMap[m_iStatus];
	m_iStatus = p.first.first;
	if (p.first.second)
		p.first.second();
}

void Status::Failed() {
	auto p = m_oStatusMap[m_iStatus];
	m_iStatus = p.second.first;
	if (p.second.second)
		p.second.second();
}

void Status::Complete() {
	m_iStatus = m_iCompleteStatus;
	if (m_pComplete)
		m_pComplete();
}
