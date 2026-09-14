#ifndef __CONTAINERS_H__
#define __CONTAINERS_H__
#pragma once

#include <deque>
#include <mutex>

// A queue shared between one reader thread and one writer thread.
//
// This used to be a lock-free queue over a std::list, using a dummy element and
// a reader-owned iterator. It had no atomics and no barriers: the writer read
// the reader's iterator in order to reclaim consumed nodes, and the reader
// walked links the writer was rewriting. That is a data race by the standard
// and only worked because a pointer-sized load is atomic in practice on x86.
// These queues hold a handful of packets per client, so a mutex costs nothing
// worth having a memory model argument about.
template<class T>
class ThreadSafeQueue
{
private:
	std::deque<T> m_queue;
	mutable std::mutex m_mutex;

public:
	ThreadSafeQueue() { }

private:
	ThreadSafeQueue(const ThreadSafeQueue& copy);
	ThreadSafeQueue& operator=(const ThreadSafeQueue& other);

public:
	// Append an element to the end of the queue (writer)
	void push(const T& value)
	{
		std::lock_guard<std::mutex> lock(m_mutex);
		m_queue.push_back(value);
	}

	// Retrieve the number of elements in the queue (reader/writer)
	size_t size(void) const
	{
		std::lock_guard<std::mutex> lock(m_mutex);
		return m_queue.size();
	}

	// Determine if the queue is empty (reader/writer)
	bool empty(void) const
	{
		std::lock_guard<std::mutex> lock(m_mutex);
		return m_queue.empty();
	}

	// Remove the first element from the queue (reader)
	void pop(void)
	{
		std::lock_guard<std::mutex> lock(m_mutex);
		if (m_queue.empty())
			throw CException(LOGL_ERROR, 0, "No elements to read from queue.");

		m_queue.pop_front();
	}

	// Retrieve the first element in the queue (reader)
	T front(void) const
	{
		std::lock_guard<std::mutex> lock(m_mutex);
		if (m_queue.empty())
			throw CException(LOGL_ERROR, 0, "No elements to read from queue.");

		return m_queue.front();
	}
};

#endif
