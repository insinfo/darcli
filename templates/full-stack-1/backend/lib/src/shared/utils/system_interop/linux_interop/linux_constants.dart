class LinuxConst {
  static const SC_AIO_LISTIO_MAX = 0x17;
  static const SC_AIO_MAX = 0x18;
  static const SC_AIO_PRIO_DELTA_MAX = 0x19;
  static const SC_ARG_MAX = 0x0;
  static const SC_ATEXIT_MAX = 0x57;
  static const SC_BC_BASE_MAX = 0x24;
  static const SC_BC_DIM_MAX = 0x25;
  static const SC_BC_SCALE_MAX = 0x26;
  static const SC_BC_STRING_MAX = 0x27;
  static const SC_CHILD_MAX = 0x1;

  ///cpu-clock-ticks
  /// número de "clock ticks" por segundo do sistema
  /// Inquire about the number of clock ticks per second; see CPU Time Inquiry. The corresponding parameter CLK_TCK is obsolete.
  /// https://www.gnu.org/software/libc/manual/html_node/Constants-for-Sysconf.html
  static const SC_CLK_TCK = 0x2;
  static const SC_COLL_WEIGHTS_MAX = 0x28;
  static const SC_DELAYTIMER_MAX = 0x1a;
  static const SC_EXPR_NEST_MAX = 0x2a;
  static const SC_GETGR_R_SIZE_MAX = 0x45;
  static const SC_GETPW_R_SIZE_MAX = 0x46;
  static const SC_HOST_NAME_MAX = 0xb4;
  static const SC_IOV_MAX = 0x3c;
  static const SC_LINE_MAX = 0x2b;
  static const SC_LOGIN_NAME_MAX = 0x47;
  static const SC_MQ_OPEN_MAX = 0x1b;
  static const SC_MQ_PRIO_MAX = 0x1c;
  static const SC_NGROUPS_MAX = 0x3;
  static const SC_OPEN_MAX = 0x4;
  static const SC_PAGE_SIZE = 0x1e;
  static const SC_PAGESIZE = 0x1e;
  static const SC_THREAD_DESTRUCTOR_ITERATIONS = 0x49;
  static const SC_THREAD_KEYS_MAX = 0x4a;
  static const SC_THREAD_STACK_MIN = 0x4b;
  static const SC_THREAD_THREADS_MAX = 0x4c;
  static const SC_RE_DUP_MAX = 0x2c;
  static const SC_RTSIG_MAX = 0x1f;
  static const SC_SEM_NSEMS_MAX = 0x20;
  static const SC_SEM_VALUE_MAX = 0x21;
  static const SC_SIGQUEUE_MAX = 0x22;
  static const SC_STREAM_MAX = 0x5;
  static const SC_SYMLOOP_MAX = 0xad;
  static const SC_TIMER_MAX = 0x23;
  static const SC_TTY_NAME_MAX = 0x48;
  static const SC_TZNAME_MAX = 0x6;
  static const SC_ADVISORY_INFO = 0x84;
  static const SC_ASYNCHRONOUS_IO = 0xc;
  static const SC_BARRIERS = 0x85;
  static const SC_CLOCK_SELECTION = 0x89;
  static const SC_CPUTIME = 0x8a;
  static const SC_FSYNC = 0xf;
  static const SC_IPV6 = 0xeb;
  static const SC_JOB_CONTROL = 0x7;
  static const SC_MAPPED_FILES = 0x10;
  static const SC_MEMLOCK = 0x11;
  static const SC_MEMLOCK_RANGE = 0x12;
  static const SC_MEMORY_PROTECTION = 0x13;
  static const SC_MESSAGE_PASSING = 0x14;
  static const SC_MONOTONIC_CLOCK = 0x95;
  static const SC_PRIORITIZED_IO = 0xd;
  static const SC_PRIORITY_SCHEDULING = 0xa;
  static const SC_RAW_SOCKETS = 0xec;
  static const SC_READER_WRITER_LOCKS = 0x99;
  static const SC_REALTIME_SIGNALS = 0x9;
  static const SC_REGEXP = 0x9b;
  static const SC_SAVED_IDS = 0x8;
  static const SC_SEMAPHORES = 0x15;
  static const SC_SHARED_MEMORY_OBJECTS = 0x16;
  static const SC_SHELL = 0x9d;
  static const SC_SPAWN = 0x9f;
  static const SC_SPIN_LOCKS = 0x9a;
  static const SC_SPORADIC_SERVER = 0xa0;
  static const SC_SS_REPL_MAX = 0xf1;
  static const SC_SYNCHRONIZED_IO = 0xe;
  static const SC_THREAD_ATTR_STACKADDR = 0x4d;
  static const SC_THREAD_ATTR_STACKSIZE = 0x4e;
  static const SC_THREAD_CPUTIME = 0x8b;
  static const SC_THREAD_PRIO_INHERIT = 0x50;
  static const SC_THREAD_PRIO_PROTECT = 0x51;
  static const SC_THREAD_PRIORITY_SCHEDULING = 0x4f;
  static const SC_THREAD_PROCESS_SHARED = 0x52;
  static const SC_THREAD_ROBUST_PRIO_INHERIT = 0xf7;
  static const SC_THREAD_ROBUST_PRIO_PROTECT = 0xf8;
  static const SC_THREAD_SAFE_FUNCTIONS = 0x44;
  static const SC_THREAD_SPORADIC_SERVER = 0xa1;
  static const SC_THREADS = 0x43;
  static const SC_TIMEOUTS = 0xa4;
  static const SC_TIMERS = 0xb;
  static const SC_TRACE = 0xb5;
  static const SC_TRACE_EVENT_FILTER = 0xb6;
  static const SC_TRACE_EVENT_NAME_MAX = 0xf2;
  static const SC_TRACE_INHERIT = 0xb7;
  static const SC_TRACE_LOG = 0xb8;
  static const SC_TRACE_NAME_MAX = 0xf3;
  static const SC_TRACE_SYS_MAX = 0xf4;
  static const SC_TRACE_USER_EVENT_MAX = 0xf5;
  static const SC_TYPED_MEMORY_OBJECTS = 0xa5;
  static const SC_VERSION = 0x1d;
  static const SC_V7_ILP32_OFF32 = 0xed;
  static const SC_V7_ILP32_OFFBIG = 0xee;
  static const SC_V7_LP64_OFF64 = 0xef;
  static const SC_V7_LPBIG_OFFBIG = 0xf0;
  static const SC_V6_ILP32_OFF32 = 0xb0;
  static const SC_V6_ILP32_OFFBIG = 0xb1;
  static const SC_V6_LP64_OFF64 = 0xb2;
  static const SC_V6_LPBIG_OFFBIG = 0xb3;
  static const SC_2_C_BIND = 0x2f;
  static const SC_2_C_DEV = 0x30;
  static const SC_2_C_VERSION = 0x60;
  static const SC_2_CHAR_TERM = 0x5f;
  static const SC_2_FORT_DEV = 0x31;
  static const SC_2_FORT_RUN = 0x32;
  static const SC_2_LOCALEDEF = 0x34;
  static const SC_2_PBS = 0xa8;
  static const SC_2_PBS_ACCOUNTING = 0xa9;
  static const SC_2_PBS_CHECKPOINT = 0xaf;
  static const SC_2_PBS_LOCATE = 0xaa;
  static const SC_2_PBS_MESSAGE = 0xab;
  static const SC_2_PBS_TRACK = 0xac;
  static const SC_2_SW_DEV = 0x33;
  static const SC_2_UPE = 0x61;
  static const SC_2_VERSION = 0x2e;
  static const SC_XOPEN_CRYPT = 0x5c;
  static const SC_XOPEN_ENH_I18N = 0x5d;
  static const SC_XOPEN_REALTIME = 0x82;
  static const SC_XOPEN_REALTIME_THREADS = 0x83;
  static const SC_XOPEN_SHM = 0x5e;
  static const SC_XOPEN_STREAMS = 0xf6;
  static const SC_XOPEN_UNIX = 0x5b;
  static const SC_XOPEN_VERSION = 0x59;
  static const SC_XOPEN_XCU_VERSION = 0x5a;
  static const SC_PHYS_PAGES = 0x55;
  static const SC_AVPHYS_PAGES = 0x56;
  static const SC_NPROCESSORS_CONF = 0x53;
  static const SC_NPROCESSORS_ONLN = 0x54;
  static const SC_UIO_MAXIOV = 0x3c;
}
