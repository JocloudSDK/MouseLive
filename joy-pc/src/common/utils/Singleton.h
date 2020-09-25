#ifndef _SINGLETON_H_
#define _SINGLETON_H_

#include <list>
#include <algorithm>

using namespace std;

//class SingletonBase
//{
//protected:
//	//////////////////////////////////////////////////////
//	//nested class
//	class InstanceTable : public list<SingletonBase *>
//	{
//	public:
//		InstanceTable()
//		{
//			bIsClearing = false;
//		};
//
//		virtual ~InstanceTable()
//		{
//			bIsClearing = true;
//			for_each(begin(), end(), DeleteInstance);
//		}
//
//	public:
//		static void DeleteInstance(SingletonBase * instance)
//		{
//			delete instance;
//		}
//
//	public:
//		bool bIsClearing;
//	};
//	//end of nested class
//	///////////////////////////////////////////////////////////
//
//public:
//	SingletonBase()
//	{
//		if (!instanceTbl) {
//			instanceTbl = new InstanceTable();
//		}
//
//		SingletonBase::instanceTbl->push_back(this);
//	}
//
//	virtual ~SingletonBase()
//	{
//		if (instanceTbl) {
//			if (!instanceTbl->bIsClearing)
//				instanceTbl->remove(this);
//
//			delete instanceTbl;
//		}
//	}
//
//public:
//	//static member
//	static InstanceTable *instanceTbl;
//};
//
//SingletonBase::InstanceTable *SingletonBase::instanceTbl = NULL;

template <typename T>
class Singleton // : public SingletonBase
{
public:
	// double check lock pattern.
	static T * GetInstance()
	{
		if (!pInstance)
		{
			// use sync
			if (!pInstance) //must check again!
			{
				pInstance = new T;
			}
		}

		return pInstance;
	}

	static void ReleaseInstance() {
		if (pInstance)
			delete pInstance;
		pInstance = nullptr;
	}

protected:
	Singleton()
	{
		//if(m_pInstance)
		//	throw runtime_error("More than one Instance!");
	}

	virtual ~Singleton()
	{
		pInstance = NULL;
	}

private:
	static T *pInstance;
};

//must defined here.
//if defined in singleton.cpp there will be a link error.
template<typename T> T * Singleton<T>::pInstance = NULL;

/*
usage:
class YourClass : public Singleton<YourClass>
{
protected://or private:  this will prevent programmer creating object directly
friend class Singleton<YourClass>;
YourClass(){};
public:
virtual ~YourClass() {};
//and your class's specific members below:
...
}
*/

#endif  //_TAII_SINGLETON_H_