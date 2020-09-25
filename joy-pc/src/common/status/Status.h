#pragma once
#include <functional>
#include <map>

class Status
{
public:
	using StatusProc = std::function<void()>;
	using StatusKeyPair = std::pair<int, StatusProc>;
	using StatusPair = std::pair<StatusKeyPair, StatusKeyPair>;
	Status() = default;
	~Status() = default;

	// invoke the InitStatus function, will call the input initFunction
	void InitStatus(int initStatus, StatusProc initFunction);
	void Register(int currentStatus, int nextStatus, int failedStatus, StatusProc next, StatusProc failed);
	void RegisterComplete(int completeStatus, StatusProc complete) { m_iCompleteStatus = completeStatus; m_pComplete = complete; }
	void Do();
	void Failed();
	void Complete();
	int GetCurrentStatus() { return m_iStatus; }

private:
	std::map<int,  StatusPair>m_oStatusMap;  // status, next, failed
	int m_iStatus;
	int m_iCompleteStatus;
	StatusProc m_pComplete = nullptr;
};

