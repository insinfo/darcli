import 'dart:ffi';

class ProcessInfo {
  List<ThreadInfo> threadInfoList = [];
  int basePriority;
  String processName = '';
  int processId;
  int poolPagedBytes;
  int poolNonPagedBytes;

  /// process_virtual_memory_bytes 
  /// virtualMemorySize64
  int virtualBytes;
  int virtualBytesPeak;
  int workingSetPeak;

  /// workingSet64
  int workingSet;
  int pageFileBytesPeak;
  int pageFileBytes;

  /// PrivateMemorySize64
  int privateBytes;
  int sessionId;
  int handleCount;

  /// Threads.Count int count = _processInfo!._threadInfoList.Count;
  int numberOfThreads;

  ProcessInfo({
    required this.numberOfThreads,
    required this.basePriority,
    required this.processName,
    required this.processId,
    required this.poolPagedBytes,
    required this.poolNonPagedBytes,
    required this.virtualBytes,
    required this.virtualBytesPeak,
    required this.workingSetPeak,
    required this.workingSet,
    required this.pageFileBytesPeak,
    required this.pageFileBytes,
    required this.privateBytes,
    required this.sessionId,
    required this.handleCount,
  });
}

class ThreadInfo {
  int threadId;
  int processId;
  int basePriority;
  int currentPriority;
  Pointer<Void> startAddress;
  ThreadState threadState;
  ThreadWaitReason threadWaitReason;
  ThreadInfo({
    required this.threadId,
    required this.processId,
    required this.basePriority,
    required this.currentPriority,
    required this.startAddress,
    required this.threadState,
    required this.threadWaitReason,
  });
}

/// Constants for thread states.
enum ThreadState {
  // Running(0),
  // StopRequested(1),
  // SuspendRequested(2),
  // Background(4),
  // Unstarted(8),
  // Stopped(16),
  // WaitSleepJoin(32),
  // Suspended(64),
  // AbortRequested(128),
  // Aborted(256),

  ///Initialized — It is recognized by the microkernel.
  Initialized(0),

  /// Ready — It is prepared to run on the next available processor.
  Ready(1),

  /// Running — It is executing.
  Running(2),

  /// Standby — It is about to run, only one thread may be in this state at a time.
  Standby(3),

  /// Terminated — It is finished executing.
  Terminated(4),

  /// Waiting — It is not ready for the processor, when ready, it will be rescheduled.
  Waiting(5),

  /// Transition — The thread is waiting for resources other than the processor
  Transition(6),

  /// Unknown — The thread state is unknown.
  Unknown(7),
  //isaque
  None(-1);

  const ThreadState(this.val);
  final int val;

  // Factory constructor to create ThreadState from int
  factory ThreadState.fromInt(int value) {
    for (var state in ThreadState.values) {
      if (state.val == value) {
        return state;
      }
    }
    // If the value doesn't match any enum, you can handle the error or return a default state.
    //throw ArgumentError('Invalid ThreadState value: $value');
    return None;
  }
}

///  Specifies the reason a thread is waiting.
enum ThreadWaitReason {
  /// Thread is waiting for the scheduler.
  Executive,

  /// Thread is waiting for a free virtual memory page.
  FreePage,

  /// Thread is waiting for a virtual memory page to arrive in memory.
  PageIn,

  /// Thread is waiting for a system allocation.
  SystemAllocation,

  /// Thread execution is delayed.
  ExecutionDelay,

  /// Thread execution is suspended.
  Suspended,

  /// Thread is waiting for a user request.
  UserRequest,

  /// Thread is waiting for event pair high.
  EventPairHigh,

  /// Thread is waiting for event pair low.
  EventPairLow,

  /// Thread is waiting for a local procedure call to arrive.
  LpcReceive,

  /// Thread is waiting for reply to a local procedure call to arrive.
  LpcReply,

  /// Thread is waiting for virtual memory.
  VirtualMemory,

  /// Thread is waiting for a virtual memory page to be written to disk.
  PageOut,

  /// Thread is waiting for an unknown reason.
  Unknown
}
