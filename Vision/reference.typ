  #let prio = math.op("Prio")

#set page (
  paper: "us-letter"
)

#set heading(
  numbering: "1.", 
)

#show heading: set text(rgb("#8B0000"))


#set text( 
  font: "San Francisco Text",
  size: 7pt,
)

#set terms(
  separator: ". ", 
  indent: 12pt, 
)

#set page( 
  numbering: "1",
  columns: 2, 
  // margin: (
  // top: 1.25cm,
  // bottom: 1.25cm,
  // x: 1.5cm, y: 1.5cm,)
  margin: .635cm
  // should be safe but i'll test the printing
  // ^https://stackoverflow.com/questions/3503615/what-are-the-minimum-margins-most-printers-can-handle#:~:text=Every%20printer%20is%20different%20but%200.25%22,%286.35%20mm%29%20is%20a%20safe%20bet.
  


)

#set enum(
  indent: 16pt,

)

#[
  #align(center, text(12pt)[
    *343 Cheatsheet*])
] 

#line(length: 100%)

= Scheduling
#image("Screenshot 2024-04-24 101249.png", width: 50%)
== Definitions
/ Batch Scheduling: For systems with a set of provided tasks with predictable runtimes & no direct interaction with users (eg. network servers).
/ Interactive Scheduling: For systems where jobs have no predefined duration & humans are often "in-the-loop" (eg. laptops). 
/ Real-Time Scheduling: Guaranteed performance for systems where deadlines _must_ be met (eg. Mars rover). Two types: *hard* declines an incoming job if it would cause even a single missed deadline, *soft* only meets deadlines with high prob.
== Turnaround Time Formula  
- let $j$ be a job 
- let $T_j$  be the turnaround time of job $j$
#align(center, $ T_j = T_#[complete]_j - T_#[arrival]_j$)
== Response Time Formula 
- let $j$ be a job 
- let $R_j$ be the response time of job $j$

#align(center, $ R_j = T_#[start]_j - T_#[arrival]_j$)
== Batch Scheduling 
- Metrics: throughput (\#completed/total_duration), turnaround.
=== Sched 1. FIFO 
- Scheduled according to earliest arrival.
=== Sched 2. Shortest Job First 
- Scheduled according to smallest duration.
- Minimizes the number of waiting jobs #sym.arrow.r.double Minimizes average turnaround, but fails when short jobs arrive after long ones.
=== Sched 3. Shortest Remaining Processing Time First 
- _Preemptive_ - scheduled according to smallest remaining duration, but stop execution whenever new jobs arrive and schedule the job with shortest duration in the queue. _Note_: Context switches on arrival take nonzero time.
- Causes starvation when constantly arriving short jobs prevent a long job from being scheduled.

== Interactive Scheduling
- Metrics: Response time (scheduler needs to show quick reactions to user input).
=== Sched 1. Round Robin 
- FIFO scheduled, but only runs each job for a specific *quanta* (timeslice) - if a job can't finish within the quanta, it runs as much as it can and is then placed back into the job queue. If it can, the next job is scheduled immediately after for a full quanta.
- Smaller quanta #sym.arrow.r.double shorter response time.
=== Sched 1. Multi-Level Feedback Queue 
- Achieves good response for interactive and good turnaround for batch jobs by prioritizing I/O bound jobs (high prio) over CPU bound (low prio).
- Round robin for jobs at the highest prio level - when all jobs at a level are I/O blocked, start the same scheduling process 1 prio level down. Long running jobs also lose priority over time.
- _Rules_: If $prio(J_1) > prio(J_2)$, run $J_1$. If $prio(J_1) = prio(J_2)$, run $J_1 \& J_2$ in Round Robin. Start jobs at top priority. When a job exceeds its timeslice, demote it one level. Every $S$ seconds, reset all jobs to top prio (this prevents starvation).
- _Adjustable parameters_: Number of prio levels, when a job gets demoted, how often to reset prio, size of RR timeslice at each level.
  - Examples: Increasing timeslice at lower levels means CPU-bound jobs get to run for longer (reducing context switch overhead since these jobs don't need to be responsive).
== Real-Time Scheduling 
=== Earliest Deadline First
- *Intuition.* Greedy scheduling based on period
  - Consider all jobs along a single timeline, labelling their periods. The job with the soonest deadline according to its period gets scheduled first.
- *Schedulability Test*
  - For $n$ tasks with a computation time $C$ and deadline *period* $D$ (you'll be given period as well as computation time)
  - a feasible schedule exists iff utilization $UU <= 1$
  $
  UU = sum_(i=1)^(n)(C_i/D_i) <= 1 
  $
  - Rejects incoming sporadic jobs which would exceed the current utilization. 
    - Example: $UU = 3/4$, incoming Job A has computation 1 & period 3 #sym.arrow.r.double Reject.
- *Tradeoffs.* 100% CPU utilization & a simple schedulability test, but requires constant recalculation of task priorities and even more time/work to find which specific jobs will miss deadlines.
=== Rate Monotonic
- *Intuition.* Simple/stable, this is essentially a static priority scheduler (higher priority == first) where only the lowest level prio jobs might miss deadlines. 
  - Priority $PP$ of job $i$ is simply represented as the following:
    - let $D$ be period 
    $
      PP_i = 1/D_i
    $
- *Schedulability Test.* 
  - For $n$ tasks with computation time $C$ and deadline period $D$
  - Utilization $UU$ must be at most $n * (2^(1/n) -1)$, or 
  $
    UU = sum_(i=1)^(n)(C_i/D_i) <= n * (2^(1/n) -1)
  $
  + $(UU <= n * (...))=>$ Schedulable 
  + $(n(...) < UU <= 1) =>$ Maybe schedulable (try and make a valid schedule to verify)
  + $(1< UU) => $ Not schedulable 
== Modern OS Schedulers
=== Linux $O(1)$ Scheduling 
- Minimize runtime by avoiding $O(n)$ algorithms $=>$ only adjust single jobs 
  - Active + Expired Run Queues
  - Calculates job priority, puts it in a table of priority buckets
=== Lottery and Stride Scheduling (Proportional-Share)
- Lottery $<=>$ Randomly schedule jobs (probability based on priority)
- *Better.* Stride scheduling, tracks a dynamic priority for each job equal to the number of _strides_ it has taken so far. 
  - Schedule job with lowest cum. strides (highest dynamic prio)$->$ Increment strides of that job.
  $
    SS_i = N / P_(i) text("for large") N text("and static priority") P. 
  $
=== Linux Completely Fair (Responsiveness + Throughput)
- Dynamically changing timeslice size based on job num. (make sure timeslice is long enough for context switch).
- Increases *responsiveness* by setting the timeslice equal to some target latency divided by the number of jobs, so that some maximum duration before a job gets some service is set.
- Increases *throughput* by setting a minimum length for timeslices, which prevents excessive context switch overhead. 
=== Earliest Eligible Virtual Deadline First
- Run the job with earliest _virtual deadline_ eqal to the time until lag greater than or equal to 0, plus the duration that it should run for.
 - A job's _lag_ is a measure of how far it is behind a fair share of its allocated processor time, and increases automatically as other jobs run.
 - A negative lag value means a job has run more than its fair share, so it won't get scheduled again until its value is >= 0.
=== Summary
- CPU Throughout $<=>$ FIFO, Avg. Turnaround Time $<=>$ SRPT, Avg. Response Time $<=>$ RR, Favoring Important Tasks $<=>$ Priority, Fair CPU Time Usage $<=>$ CFS, EEVDF, Meeting Deadlines $<=>$ EDF, RMS


#line(length: 50%)
= Concurrency 
== Amdahl's Law
/ Amdahl's Law: #[Allows us to calculate
the theoretical speedup from utilizing 
mutliple threads. Let $F$ be the sped-up fraction of execution and $S$ be the scale of the improvement.]
#[
  #align(center, text(10pt)[
    $1/((1-F)+(F\/S))$
  ])
]

== Spinlocks 
#table( columns: 2, 
[```c spin_lock_init(&lock)```], [```c &(lock->flag) = 0;```],
[```c spin_lock_acquire(&lock)```], [```c while (atomic_exchange(&(lock->flag), 1) == 1) {};```],
[```c spin_lock_release(&lock)```], [```c atomic_store(&(lock->flag), 0);```]
)
- Consider the case with a preemptive scheduler. A downside of a spinlock implementation is that if a thread $A$ gets descheduled while still holding the lock, then every other thread that also requires that lock will spin their entired scheduled timeslot. These threads won't be able to perform their actual work until $A$ is rescheduled and releases the lock.
- Fits _Mutual Exclusion_ & _Progress_, but doesn't guarantee _Bounded Wait_.
== TicketLocks
#table( columns: 2, 
[```c struct lock_t;```], [```c unsigned int ticket; unsigned int turn;```],
[```c mutex_init(lock_t *mutex)```], [```c mutex->ticket = 0; mutex-turn = 0;```],
[```c mutex_lock(lock_t* mutex)```], [```c int myturn = atomic_fetch_add(&(mutex->ticket), 1); while (mutex->turn != myturn);```],
[```c mutex_unlock(lock_t* mutex)```], [```c atomic_fetch_add(&(mutex->turn), 1);```]
)
- Similar to positives & negatives as spinlocks (still spins the entire timeslice if waiting on a lock), but fixes the _Bounded Wait_ issue because of its FIFO thread scheduling. 

== Mutexes $=$ YieldLocks 
#table( columns: 2, 
[```c (See TicketLock)```], [```c (See TicketLock)```],
[```c (See TicketLock)```], [```c (See TicketLock)```],
[```c mutex_lock(lock_t* mutex)```], [```c int myturn = atomic_fetch_add(&(mutex->ticket), 1); while (mutex->turn != myturn) {sched_yield();}```],
[```c (See TicketLock)```], [```c (See TicketLock)```]
)
- *Intuition.* The yield syscall unschedules the current thread, leaving room for another thread to be scheduled that might not require on that lock to do work.
  - Improves performace, but time is still spent during the yield context switches.

== Spinning vs. Blocking
If a thread releases a lock quickly compared to the context switch, spin the current thread. If it will take a long time to release the lock, then block the current thread and schedule another.

== Condvars (Condition Variables)
- *Intuition.* A convar acts as a "queue" for threads. 
  - In order to utilize a convar, you must utilize a *lock/mutex* as well as a flag. 
      - The *lock/mutex* ensures that neither the main thread or worker threads enter their CS simultaneously 
      - The *flag* ensures main thread doesn't wait unnecessarily (if worker thread acquires lock before main thread and completes its work)
- The convar has two methods 
  - `wait(convar_t* c, mutex_t* t)` will put the calling thread to `sleep()` and releases the lock `&t`. 
    - the calling thread now _waits_, only to be awaken by a worker thread that repossesses the lock 
  - `signal(convar_t*)` is called by a worker thread that possesses the lock
    - it will `wake()` any waiting/sleeping threads as well as 
    - *note.* this function does _not_ release the lock, the lock must be manually released afterwards with a call to _Pthread_mutex_unlock_ for example.

- *Implementation Tips.* Whenever implementing a convar, make sure you have a condition that can be represented as a flag 
  - For the producer-consumer problem, you will need *two convars* and *one global mutex* 
    - If a queue is full $->$ producers must wait (are put to sleep by convar, making sure that only a consumer can get the lock)
      - A consumer will call `signal()` only after `get()`ing a value 
    - If a queue is empty $->$ consumers must wait (are put to sleep by convar, making sure that only a consumer can get the lock)
      - A producer will call `signal()` only after `put()`'ing a value.
- *Note.* You should always use a loop when checking the flag variable ```c while (done == 0) { Pthread_cond_wait(&cond, &mutex) }
``` since the following could happen:
  - The current thread was woken up from its wait, but the resource it wanted was taken again right before it could be scheduled.
  - Occurrence of a _spurious wakeup_, where an interrupt handler might broadcast a wakeup signal to all threads for example. 

== Semaphores 
- *Intuition.* A generalization of the condvar. 
  - It wraps the idea of a state, lock, and queue into a single object.
    - Condvars simply contained the logic for `wait()` and `get()`, everything else handled externally.
- Structure 
  - Contains an initial internal value that represents available "resources."
    - For queues, the initial value is the number of empty buckets.
    - For mutexes, the initial value is 1 (i.e. only one lock can be held.)
#table( 
  columns: 2, 
  [*Method Name*], [*Method Body*],
  [```c init(lock_t* lock)```], 
  [```c sem_init(&(lock->sem), 1);```],
  [```c acquire(lock_t* lock)```],
  [```c 
    // Decrement init. value, wait() until value >= 0 
    sem_wait(&(lock->sem));```],
  [```c release(lock_t* lock)```],
  [```c
  // Increment init value, then wake a single wait()ing thread 
  sem_post(&(lock->sem));```]
  
)

== Synchronization Bugs 
#table( 
  columns: 2, 
  [Atomicity Violation], [An action that we intend to be atomic ends up not being atomic (ie, another thread 
is interleaved inbetween)], 
  [Ordering Violation], [An action that we intend to occur in a particular order does not occur (due to 
interleaving)], 
  [Deadlock], [Both threads are blocked and cannot access the critical section ],
  [Livelock], [Both threads continously block each other in a loop],
)

=== Atomicity Violations
- *Solution.* 
  + Lock _all_ references to shared memory 
  + Handle the _entire indeterminant state_ (ie, all shared references) in a _single_ atomic section  
=== Ordering Violations
- *Solution.* 
  - Use semaphores and condvars for regions of code that require a _certain ordering of operations_ 
    - Objects must be init'd before use 
    - Objects cannot be freed while in use

=== Deadlocks
- *Solution.*
#table(
  columns: 2, 
  [*Deadlock Avoidance*], [Make sure that resource requests from threads are safe (ie, if there are an adequate num. of resources available for all threads, then serve)],
  [*Deadlock Prevention*], [Write non-deadlock prone code (making sure that $<=4$ of
  - _Mutual Exclusion_ 
  - _Hold-and-wait_ 
  - _No preemption_
  - and _Circular wait_)],
  [*Deadlock Recovery*], [Design a way to recover/fix an undesirable state whenever deadlock happens],
)
=== Livelocks
- *Solution.*
  - Reorder the timing of retrying lock acquisition - symmetry makes livelock scenarios worse.

=== Priority Inversion 
- Issue with priority schedulers + concurrency 
  - High priority locks will need to depend on the completion of low priority locks in order to continue-- bad!
    - Deadlines are easily missed
- *Solution.* Priority Inheritance
  - If Task A holds a resource required by Task B with a higher prio, temporarily increase task A's priority to Task B's level. 

= Extended Response 
+ Is it always optimal for a thread waiting on a lock to yield? Why or why not?
  - #[No. On a system that can run multiple threads in parallel, the other
thread could finish its critical section quickly. There is overhead for
yielding and performing a context switch that could have been avoided.
(Must note multicore AND overhead for full credit)]
+ #[A task is comprised of 75% parallelizable work and 25% serial work. How much could the task be sped up by the creation of many
threads executed in parallel? Practically, what might prevent achieving that
speedup?]
  + #[ Can¿t squeeze parallelizable work down to literally nothing. Overhead
from synchronization/mutual exclusion, starting threads, scheduling
threads, OS overhead, hardware limitations, I/O access, etc.]
+ #[Consider a Round Robin scheduler with a one microsecond timeslice. In
what ways would this be better than a scheduler with a one millisecond
timeslice? In what ways would this be worse?]
  + #[*Better*: Shorter response time! More jobs per unit time. *worse.* Significant overhead spent in context switches. Job isn¿t able to make much progress in only a microsecond.]
+ #[What would be the impacts of greatly increasing the timeslice duration for
the highest priority jobs in a Multi-Level Feedback Queue (MLFQ)
scheduler?]
  + #[High-priority jobs are I/O bound and are unlikely to use their
entire timeslice.]
  + #[Starvation of lower-priority jobs isn¿t valid impact here. Anything promoted in priority due to the increased timeslice was already equal or higher priority than the lower-priority jobs, or else the lower-priority jobs would be promoted as well.]
+ #[Is throughput a good metric for a scheduler designed for an interactive
system? Why or why not?]
