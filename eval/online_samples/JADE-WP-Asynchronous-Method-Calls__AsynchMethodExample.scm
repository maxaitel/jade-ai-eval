jadeVersionNumber "99.0.00";
schemaDefinition
AsynchMethodExample subschemaOf RootSchema completeDefinition;
constantDefinitions
	categoryDefinition ApplicationNames
		documentationText
		`Schema application names.`
		CALLER_APPLICATION:            String = "CallerApplication";
		REQUEST:                       String = "Request";
		SCHEMA_NAME:                   String = "AsynchMethodExample";
		WORKER_APPLICATION:            String = "WorkerApplication";
	categoryDefinition EventConstants
		documentationText
		`Event constants for notifications.`
		EVENT_CALLER_FINISHED:         Integer = 8801;
		documentationText
		`Event constant if a caller process finished.`
		EVENT_CALLER_STARTS:           Integer = 8802;
		documentationText
		`Event constant if a caller process starts.`
		EVENT_REQUEST_FINISHED:        Integer = 8805;
		documentationText
		`Event constant if a request process finished.`
		EVENT_REQUEST_IN_ACTION:       Integer = 8803;
		documentationText
		`Event constant if a request leaves the queue and gets into active action.`
		EVENT_REQUEST_STARTS:          Integer = 8806;
		documentationText
		`Event constant if a request process starts.`
		EVENT_START_REQUEST:           Integer = 8807;
		documentationText
`Event constant that all necessary procceses  are running and the first request is able to run.`
		EVENT_WORKER_FINISHED:         Integer = 8804;
	categoryDefinition FrameworkConstants
		documentationText
		`Constant limits of the framework.`
		WAIT_FOR_METHOD_LIMIT:         Integer = 63;
	categoryDefinition GUIText
		documentationText
		`Changable GUI textes.`
		LBL_DO_NOTHING:                String = "Milliseconds to sleep :";
		LBL_NUMBER:                    String = "Number to start to search for prime numbers:";
		LBL_TRANSACTIONS:              String = "Number of transactions :";
	categoryDefinition KindOfWorkConstants
		documentationText
		`Constants to define the kind of tasks for the application.`
		DO_NOTHING:                    Integer = 1;
		USE_CPU:                       Integer = 2;
		USE_CPU_AND_IO:                Integer = 4;
		USE_IO:                        Integer = 3;
localeDefinitions
	5129 "English (New Zealand)" schemaDefaultLocale;
typeHeaders
	AsynchMethodExample subclassOf RootSchemaApp transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed;
	Caller subclassOf Object;
	GAsynchMethodExample subclassOf RootSchemaGlobal transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed;
	ProcessingUnit subclassOf Object;
	Report subclassOf Object;
	ReportUnit subclassOf Object abstract;
	CallerReportUnit subclassOf ReportUnit;
	ContinueableReportUnit subclassOf ReportUnit;
	RequestReportUnit subclassOf ReportUnit;
	WorkerReportUnit subclassOf ReportUnit;
	Transaction subclassOf Object;
	SAsynchMethodExample subclassOf RootSchemaSession transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed;
	MainForm subclassOf Form transient, transientAllowed, subclassTransientAllowed;
	Worker subclassOf Object;
	CallerReportUnitDict subclassOf MemberKeyDictionary maxLogicalBlockSize = 43690, loadFactor = 66;
	RequestReportUnitSet subclassOf ObjectSet maxLogicalBlockSize = 43690, loadFactor = 98;
	TransactionSet subclassOf ObjectSet maxLogicalBlockSize = 43690, loadFactor = 98;
	WorkerReportUnitSet subclassOf ObjectSet maxLogicalBlockSize = 43690, loadFactor = 98;
	JadeMethodContextArray subclassOf ObjectArray maxLogicalBlockSize = 43690, loadFactor = 98;
interfaceDefs
	IUIProcessingUnit
	(
		documentationText
`Interface for an user interface to get the output for all the things happen on running the asynchronous method example application.`
	jadeMethodDefinitions
		allCallersFinished();
		callersCreated();
		decQueue();
		documentationText
		`The queue of waiting requests decreases by 1.`
		finishedAction();
		documentationText
		`The whole application finished.`
		incQueue();
		documentationText
		`The queue of waiting requests increases by 1.`
		oneCallerFinished();
		workersCreated();
	)
membershipDefinitions
	CallerReportUnitDict of CallerReportUnit;
	RequestReportUnitSet of RequestReportUnit;
	TransactionSet of Transaction;
	WorkerReportUnitSet of WorkerReportUnit;
	JadeMethodContextArray of JadeMethodContext;
typeDefinitions
	Object completeDefinition
	(
	)
	Application completeDefinition
	(
	)
	RootSchemaApp completeDefinition
	(
	)
	AsynchMethodExample completeDefinition
	(
	attributeDefinitions
		mRequests:                     Integer protected;
		documentationText
		`Number of requests for the caller process.`
	referenceDefinitions
		mCaller:                       Caller  protected;
		documentationText
		`Caller object for caller processes.`
		mReport:                       ReportUnit  protected;
		documentationText
		`Report for caller or worker processes.`
		mWorker:                       Worker ;
		documentationText
		`Worker object for the worker process.`
	jadeMethodDefinitions
		clearDatabase();
		finalizeCaller() updating;
		finalizeWorker() updating;
		initialize() updating;
		initializeCaller(caller: Caller) updating;
		initializeRequest(caller: Caller);
		initializeWorker(worker: Worker) updating;
		poissonRandom(lambda: Integer): Integer;
		userNotification(
			eventType: Integer; 
			theObject: Object; 
			eventTag: Integer; 
			userInfo: Any) updating;
	)
	Caller completeDefinition
	(
		documentationText
`Represents a caller data object which holds all the data that is important for a caller process.`
	attributeDefinitions
		mInterval:                     Integer;
		documentationText
		`Interval between the simulated external requests.`
		mNumber:                       Integer;
		documentationText
		`Caller identification.`
		mOptionToDo:                   Integer;
		documentationText
		`Kind of operation to do.`
		mParameter:                    Integer;
		documentationText
		`Operation parameter for the unknown operation to do.`
		mRuns:                         Integer;
		documentationText
		`Number of simulated external requests.`
		mTasks:                        Integer;
		documentationText
		`Number of parallelise tasks per external request.`
	jadeMethodDefinitions
		finalize() updating;
		init() updating;
		userNotification(
			eventType: Integer; 
			theObject: Object; 
			eventTag: Integer; 
			userInfo: Any) updating;
	)
	Global completeDefinition
	(
	)
	RootSchemaGlobal completeDefinition
	(
	)
	GAsynchMethodExample completeDefinition
	(
	)
	JadeScript completeDefinition
	(
	jadeMethodDefinitions
		removeAll();
	)
	ProcessingUnit completeDefinition
	(
		documentationText
`Processes the whole application without an intigrated user interface.
Communicate with an user interface through a defined interface.`
	constantDefinitions
		CLS_DO_NOTHING:                Integer = DO_NOTHING;
		CLS_USE_CPU:                   Integer = USE_CPU;
		CLS_USE_CPU_AND_IO:            Integer = USE_CPU_AND_IO;
		CLS_USE_IO:                    Integer = USE_IO;
	attributeDefinitions
		mAllCallers:                   Integer protected;
		documentationText
		`Number of all expected caller processes.`
		mCallersRunning:               Integer protected;
		documentationText
		`Number of callers currently running.`
		mWorkersRunning:               Integer protected;
		documentationText
		`Number of workers currently running.`
	referenceDefinitions
		mReport:                       Report  protected;
		documentationText
		`Report of the current application.`
		mUserInterface:                IUIProcessingUnit  protected;
		documentationText
		`User interface to put the output to.`
	jadeMethodDefinitions
		finalize() updating;
		init(ui: IUIProcessingUnit) updating;
		startAsynchronousCalls(
			callers: Integer; 
			workers: Integer; 
			optionToDo: Integer; 
			methodParam: Integer; 
			tasks: Integer; 
			runs: Integer; 
			interval: Integer) updating;
		startAsynchronousCallsAndSave(
			callers: Integer; 
			workers: Integer; 
			optionToDo: Integer; 
			methodParam: Integer; 
			tasks: Integer; 
			runs: Integer; 
			interval: Integer; 
			fileName: String) updating;
		startCaller(
			callers: Integer; 
			optionToDo: Integer; 
			param: Integer; 
			tasks: Integer; 
			interval: Integer; 
			runs: Integer) updating, protected;
		startWorkers(
			workers: Integer; 
			callers: Integer) protected;
		userNotification(
			eventType: Integer; 
			theObject: Object; 
			eventTag: Integer; 
			userInfo: Any) updating;
	)
	Report completeDefinition
	(
		documentationText
		`Report of all worker, consumer and request datas.`
	attributeDefinitions
		mFileName:                     String;
		mStartTime:                    Decimal[23] protected;
		documentationText
		`Start time of this application.`
	referenceDefinitions
		mCallerReports:                CallerReportUnitDict  protected;
		documentationText
		`All caller reports.`
		mWorkerReports:                WorkerReportUnitSet  protected;
		documentationText
		`All worker reports.`
	jadeMethodDefinitions
		addCallerReport(report: CallerReportUnit) updating;
		addRequestReport(report: RequestReportUnit input);
		addWorkerReport(report: WorkerReportUnit);
		finalize() updating;
		handleFileException(exception: FileException): Integer protected;
		init() updating;
		print();
		saveToFile(file: File) protected;
		transform(number: Decimal): String protected;
		writeReport() protected;
	)
	ReportUnit completeDefinition
	(
		documentationText
		`Abstract report unit to collect times.`
	attributeDefinitions
		mEndTime:                      Decimal[23] protected;
		documentationText
		`End time.`
		mStartTime:                    Decimal[23] protected;
		documentationText
		`Start time.`
	jadeMethodDefinitions
		getRunningTime(): Decimal;
		start() updating;
		stop() updating;
	)
	CallerReportUnit completeDefinition
	(
		documentationText
		`Report unit for caller processes.`
	attributeDefinitions
		mCallerNumber:                 Integer protected;
		documentationText
		`Identification number of this caller process.`
	referenceDefinitions
		mRequests:                     RequestReportUnitSet  protected;
		documentationText
		`All requests from this caller process.`
	jadeMethodDefinitions
		addRequestReport(report: RequestReportUnit);
		finalize() updating;
		getCaller(): Integer;
		getRequests(): RequestReportUnitSet;
		init() updating;
		setCaller(caller: Integer) updating;
	)
	ContinueableReportUnit completeDefinition
	(
		documentationText
		`Report unit to count switchable times.`
	attributeDefinitions
		mPassiveTime:                  Decimal[23] protected;
		documentationText
		`Idle time in microseconds.`
		mRunTime:                      Decimal[23] protected;
		documentationText
		`Active running time in microseconds.`
	jadeMethodDefinitions
		getPassiveTime(): Decimal;
		getRunningTime(): Decimal;
		start() updating;
		stop() updating;
	)
	RequestReportUnit completeDefinition
	(
		documentationText
		`Report unit for requests.`
	attributeDefinitions
		mCaller:                       Integer protected;
		documentationText
		`Caller identification for this request.`
		mRequestsInQueue:              Integer protected;
		documentationText
		`Number of requests which were in the queue at the time of initilizing.`
		mStartAction:                  Decimal[23] protected;
		documentationText
		`Time of start of action.`
		mTimeSinceAppStart:            Decimal[23] protected;
		documentationText
		`Start time of this request since the start of the whole application.`
		mWorker:                       Integer protected;
		documentationText
		`Worker identification for this request.`
	jadeMethodDefinitions
		getActiveRunningTime(): Decimal;
		getCaller(): Integer;
		getPassiveRunningTime(): Decimal;
		getRequests(): Integer;
		getTimeSinceAppStart(): Decimal;
		getWorker(): Integer;
		setCaller(callerNumber: Integer) updating;
		setRequests(requests: Integer) updating;
		setTimeSinceAppStart(time: Decimal) updating;
		setWorker(workerNumber: Integer) updating;
	)
	WorkerReportUnit completeDefinition
	(
		documentationText
		`Report unit for worker processes.`
	attributeDefinitions
		mActiveTime:                   Decimal[23] protected;
		documentationText
		`Active running time in microseconds.`
		mJobs:                         Integer protected;
		documentationText
		`Number of jobs done.`
		mPassiveTime:                  Decimal[23] protected;
		documentationText
		`Idle time in microseconds.`
		mWorkerNumber:                 Integer protected;
		documentationText
		`Worker identification.`
	jadeMethodDefinitions
		getActiveTime(): Decimal;
		getJobs(): Integer;
		getPassiveTime(): Decimal;
		getWorkerNumber(): Integer;
		setData(
			jobs: Integer; 
			activeTime: Decimal; 
			passiveTime: Decimal) updating;
		setWorker(worker: Integer) updating;
	)
	Transaction completeDefinition
	(
		documentationText
		`Just a class to write and read database transactions.`
	attributeDefinitions
		mNumber:                       Integer;
		documentationText
		`Just a data object to write / read something.`
	)
	WebSession completeDefinition
	(
	)
	RootSchemaSession completeDefinition
	(
	)
	SAsynchMethodExample completeDefinition
	(
	)
	Window completeDefinition
	(
	)
	Form completeDefinition
	(
	)
	MainForm completeDefinition
	(
	attributeDefinitions
		mQueueSize:                    Integer protected;
	referenceDefinitions
		btnStart:                      Button ;
		lblCallers:                    Label ;
		lblInterval:                   Label ;
		lblKindCallers:                Label ;
		lblParam:                      Label ;
		lblRequests:                   Label ;
		lblRuns:                       Label ;
		lblTasks:                      Label ;
		lblWorker:                     Label ;
		mProcessingUnit:               ProcessingUnit  protected;
		optCPU:                        OptionButton ;
		optIO:                         OptionButton ;
		optNoResource:                 OptionButton ;
		optUseBoth:                    OptionButton ;
		txtCallers:                    TextBox ;
		txtInterval:                   TextBox ;
		txtParam:                      TextBox ;
		txtQueue:                      TextBox ;
		txtRuns:                       TextBox ;
		txtStatus:                     TextBox ;
		txtTasks:                      TextBox ;
		txtWorkers:                    TextBox ;
	jadeMethodDefinitions
		btnStart_click(btn: Button input) updating;
		checkInputErrors(): Boolean protected;
		load() updating;
		optCPU_click(optionbutton: OptionButton input) updating;
		optIO_click(optionbutton: OptionButton input) updating;
		optNoResource_click(optionbutton: OptionButton input) updating;
		optUseBoth_click(optionbutton: OptionButton input) updating;
		stub_AllCallersFinished();
		stub_CallersCreated();
		stub_DecQueue() updating;
		stub_FinishedAction();
		stub_IncQueue() updating;
		stub_OneCallerFinished();
		stub_WorkersCreated();
		txtCallers_change(textbox: TextBox input) updating;
		txtParam_change(textbox: TextBox input) updating;
		txtWorkers_change(textbox: TextBox input) updating;
		unload() updating;
	eventMethodMappings
		btnStart_click = click of Button;
		load = load of Form;
		optCPU_click = click of OptionButton;
		optIO_click = click of OptionButton;
		optNoResource_click = click of OptionButton;
		optUseBoth_click = click of OptionButton;
		txtCallers_change = change of TextBox;
		txtParam_change = change of TextBox;
		txtWorkers_change = change of TextBox;
		unload = unload of Form;
	implementInterfaces
		IUIProcessingUnit
		(
			allCallersFinished is stub_AllCallersFinished;
			callersCreated is stub_CallersCreated;
			decQueue is stub_DecQueue;
			finishedAction is stub_FinishedAction;
			incQueue is stub_IncQueue;
			oneCallerFinished is stub_OneCallerFinished;
			workersCreated is stub_WorkersCreated;
		)
	)
	Worker completeDefinition
	(
		documentationText
`Presents a worker data object which holds all the datas which are important for a worker process.`
	attributeDefinitions
		mExpectedCallers:              Integer;
		documentationText
		`Number of all expected caller processes.`
		mJobs:                         Integer;
		documentationText
		`Number of jobs this worker process has done.`
		mNumber:                       Integer;
		documentationText
		`Identification number of the worker process.`
	referenceDefinitions
		mTimer:                        ContinueableReportUnit ;
		documentationText
		`Timer to count the active and passive time of this worker process.`
	jadeMethodDefinitions
		doNothing(time: Integer);
		doWork(
			optionToDo: Integer; 
			param: Integer; 
			report: RequestReportUnit input);
		useCPU(level: Integer);
		useCPUandIO(level: Integer);
		useIO(transactions: Integer);
	)
	Collection completeDefinition
	(
	)
	Btree completeDefinition
	(
	)
	Dictionary completeDefinition
	(
	)
	MemberKeyDictionary completeDefinition
	(
	)
	CallerReportUnitDict completeDefinition
	(
	)
	Set completeDefinition
	(
	)
	ObjectSet completeDefinition
	(
	)
	RequestReportUnitSet completeDefinition
	(
	)
	TransactionSet completeDefinition
	(
	)
	WorkerReportUnitSet completeDefinition
	(
	)
	List completeDefinition
	(
	)
	Array completeDefinition
	(
	)
	ObjectArray completeDefinition
	(
	)
	JadeMethodContextArray completeDefinition
	(
	)
memberKeyDefinitions
	CallerReportUnitDict completeDefinition
	(
		mCallerNumber;
	)
databaseDefinitions
	AsynchMethodExampleDb
	(
	databaseFileDefinitions
		"bank";
	defaultFileDefinition "bank";
	classMapDefinitions
		AsynchMethodExample in "_usergui";
		Caller in "bank";
		CallerReportUnit in "bank";
		CallerReportUnitDict in "bank";
		ContinueableReportUnit in "bank";
		GAsynchMethodExample in "bank";
		JadeMethodContextArray in "bank";
		ProcessingUnit in "bank";
		Report in "bank";
		ReportUnit in "bank";
		RequestReportUnit in "bank";
		RequestReportUnitSet in "bank";
		SAsynchMethodExample in "_environ";
		Transaction in "bank";
		TransactionSet in "bank";
		Worker in "bank";
		WorkerReportUnit in "bank";
		WorkerReportUnitSet in "bank";
	)
exportedPackageDefinitions
	AsynchronousMethodExample
	(

	exportedClassDefinitions
		MainForm transientAllowed, transient 
		(
		)
		ProcessingUnit
		(
		exportedConstantDefinitions
			CLS_DO_NOTHING;
			CLS_USE_CPU;
			CLS_USE_CPU_AND_IO;
			CLS_USE_IO;
		exportedMethodDefinitions
			finalize;
			init;
			startAsynchronousCalls;
			startAsynchronousCallsAndSave;
		)
	exportedInterfaceDefinitions
		IUIProcessingUnit
	)
typeSources
	AsynchMethodExample (
	jadeMethodSources
clearDatabase
{
clearDatabase();

begin
	beginTransaction;
	Caller.instances.purge();
	ProcessingUnit.instances.purge();
	Report.instances.purge();
	ReportUnit.instances.purge();
	CallerReportUnit.instances.purge();
	ContinueableReportUnit.instances.purge();
	RequestReportUnit.instances.purge();
	WorkerReportUnit.instances.purge();
	Transaction.instances.purge();
	Worker.instances.purge();
	commitTransaction;
end;
}
finalizeCaller
{
finalizeCaller() updating;

begin
	mReport.stop();
	mCaller.finalize();
	ProcessingUnit.causeClassEvent(EVENT_CALLER_FINISHED, true, null);
	Application.causeClassEvent(EVENT_CALLER_FINISHED, true, null);
	beginTransaction;
	delete mCaller;
	commitTransaction;
	endClassNotification(Application, false, EVENT_REQUEST_FINISHED);
end;
}
finalizeWorker
{
finalizeWorker() updating;

begin
	mReport.stop();
	mReport.WorkerReportUnit.setData(mWorker.mJobs, mWorker.mTimer.getRunningTime(), mWorker.mTimer.getPassiveTime());
	beginTransaction;
	delete mWorker.mTimer;
	delete mWorker;
	commitTransaction;
	endClassNotification(Application, false, EVENT_CALLER_FINISHED);
	app.asyncFinalize();
	ProcessingUnit.causeClassEvent(EVENT_WORKER_FINISHED, true, null);
end;
}
initialize
{
initialize() updating;

begin
	inheritMethod();
end;
}
initializeCaller
{
initializeCaller(caller : Caller) updating;

vars
	report : CallerReportUnit;

begin
	beginTransaction;
	create report persistent;
	commitTransaction;
	report.init();
	report.setCaller(caller.mNumber);
	report.start();
	mReport := report;
	Report.firstInstance.addCallerReport(report);
	mCaller := caller;
	mCaller.init();
	mRequests := caller.mRuns * caller.mTasks;
	beginClassNotification(Application, false, EVENT_REQUEST_FINISHED, Response_Continuous, 0);
	ProcessingUnit.causeClassEvent(EVENT_CALLER_STARTS, true, null);
end;
}
initializeRequest
{
initializeRequest(caller : Caller);

vars
	callerCtx, resultCtx : JadeMethodContext;
	callerCtxs : JadeMethodContextArray;
	report : RequestReportUnit;
	run, tasks, queueDepth : Integer;
	invokeTS, beginTS, finishTS, harvestTS : TimeStamp;

begin
	tasks := caller.mTasks;
	create callerCtxs transient;
	foreach run in 1 to tasks do
		beginTransaction;
		create report persistent;
		commitTransaction;
		report.setCaller(caller.mNumber);
		Report.firstInstance.addRequestReport(report);
		report.start();

		create callerCtx transient;
		callerCtx.workerAppName := WORKER_APPLICATION;
		callerCtx.invoke(Worker.firstInstance(), doWork, caller.mOptionToDo, caller.mParameter, report);
		callerCtx.getTimestamps(invokeTS, beginTS, finishTS, harvestTS, queueDepth);
		report.setRequests(queueDepth);
		callerCtxs.add(callerCtx);

		ProcessingUnit.causeClassEvent(EVENT_REQUEST_STARTS, true, null);
	endforeach;

	while true do
		resultCtx := process.waitForMethods(callerCtxs);
		if resultCtx = null then
			break;
		else
			Application.causeClassEvent(EVENT_REQUEST_FINISHED, true, caller.mNumber);
		endif;
	endwhile;

	foreach run in 1 to tasks do
		delete callerCtxs.at(run);
	endforeach;
epilog
	delete callerCtxs;
	terminate;
end;
}
initializeWorker
{
initializeWorker(worker : Worker) updating;

vars
	report : WorkerReportUnit;

begin
	beginTransaction;
	create report persistent;
	commitTransaction;
	report.setWorker(worker.mNumber);
	report.start();
	mReport := report;
	Report.firstInstance.addWorkerReport(report);
	mWorker := worker;
	mRequests := 0;
	beginClassNotification(Application, false, EVENT_CALLER_FINISHED, Response_Continuous, 0);
	app.asyncInitialize();
end;
}
poissonRandom
{
poissonRandom(lambda: Integer): Integer;

vars
	total: Real;
	result: Integer;
	factor: Real;
	randomReal: Real;
	randomInteger: Integer;

begin
	factor:= -(1/lambda);
	while true do
		randomInteger:= app.random(1000);
		if randomInteger = 0 then
			randomInteger:= 1;
		endif;
		randomReal:= randomInteger.Real * 0.001;
		total:= total + (factor * randomReal.log);
		if total >= 1 then
			break;
		endif;
		result:= result + 1;
	endwhile; 
	return result;
end;
}
userNotification
{
userNotification(eventType: Integer; theObject: Object; eventTag: Integer; userInfo: Any) updating;

begin
	if eventType = EVENT_CALLER_FINISHED then
		beginTransaction;
		mWorker.mExpectedCallers := mWorker.mExpectedCallers - 1;
		commitTransaction;
		if mWorker.mExpectedCallers = 0 then
			terminate;
		endif;
	endif;
	if eventType = EVENT_REQUEST_FINISHED and userInfo.Integer = mCaller.mNumber then
		mRequests := mRequests - 1;
		if mRequests = 0 then
			terminate;
		endif;
	endif;
end;
}
	)
	Caller (
	jadeMethodSources
finalize
{
finalize() updating;

begin
	endClassNotification(Caller, false, EVENT_START_REQUEST);
end;
}
init
{
init() updating;

begin
	beginClassNotification(Caller, false, EVENT_START_REQUEST, Response_Continuous, 0);
end;
}
userNotification
{
userNotification(eventType: Integer; theObject: Object; eventTag: Integer; userInfo: Any) updating;

vars
	run : Integer;
	proc : Process;

begin
	foreach run in 1 to mRuns do
		proc := app.startApplicationWithParameter(SCHEMA_NAME, REQUEST, self);
		if run <> mRuns then
			process.sleep(app.poissonRandom(mInterval));
		endif;
	endforeach;
end;
}
	)
	JadeScript (
	jadeMethodSources
removeAll
{
removeAll();

begin
	beginTransaction;
	Caller.instances.purge();
	ProcessingUnit.instances.purge();
	Report.instances.purge();
	ReportUnit.instances.purge();
	CallerReportUnit.instances.purge();
	ContinueableReportUnit.instances.purge();
	RequestReportUnit.instances.purge();
	WorkerReportUnit.instances.purge();
	Transaction.instances.purge();
	Worker.instances.purge();
	commitTransaction;
end;
}
	)
	ProcessingUnit (
	jadeMethodSources
finalize
{
finalize() updating;

begin
	endClassNotification(ProcessingUnit, false, EVENT_CALLER_STARTS);
	endClassNotification(ProcessingUnit, false, EVENT_CALLER_FINISHED);
	endClassNotification(ProcessingUnit, false, EVENT_REQUEST_STARTS);
	endClassNotification(ProcessingUnit, false, EVENT_REQUEST_IN_ACTION);
	endClassNotification(ProcessingUnit, false, EVENT_WORKER_FINISHED);
	Report.firstInstance.finalize();
	beginTransaction;
	delete mReport;
	commitTransaction;
end;
}
init
{
init(ui : IUIProcessingUnit) updating;

begin
	app.clearDatabase();
	beginTransaction;
	create mReport persistent;
	commitTransaction;
	mUserInterface := ui;
	mAllCallers := 0;
	mCallersRunning := 0;
	mWorkersRunning := 0;
	mReport.init();
	beginClassNotification(ProcessingUnit, false, EVENT_CALLER_STARTS, Response_Continuous, 0);
	beginClassNotification(ProcessingUnit, false, EVENT_CALLER_FINISHED, Response_Continuous, 0);
	beginClassNotification(ProcessingUnit, false, EVENT_REQUEST_STARTS, Response_Continuous, 0);
	beginClassNotification(ProcessingUnit, false, EVENT_REQUEST_IN_ACTION, Response_Continuous, 0);
	beginClassNotification(ProcessingUnit, false, EVENT_WORKER_FINISHED, Response_Continuous, 0);
end;
}
startAsynchronousCalls
{
startAsynchronousCalls(callers	: Integer;
					   workers 		: Integer;
					   optionToDo	: Integer;
					   methodParam	: Integer;
					   tasks		: Integer;
					   runs			: Integer;
					   interval		: Integer) updating;

vars
	metTasks : Integer;
					   
begin
	if tasks > WAIT_FOR_METHOD_LIMIT then
		metTasks := WAIT_FOR_METHOD_LIMIT;
	else
		metTasks := tasks;
	endif;
	mWorkersRunning := workers;
	startWorkers(workers, callers);
	mUserInterface.workersCreated();
	mAllCallers := callers;
	mCallersRunning := 0;
	startCaller(callers, optionToDo, methodParam, metTasks, interval, runs);
	mUserInterface.callersCreated();
end;
}
startAsynchronousCallsAndSave
{
startAsynchronousCallsAndSave(callers		: Integer;
							  workers 		: Integer;
							  optionToDo	: Integer;
							  methodParam	: Integer;
							  tasks			: Integer;
							  runs			: Integer;
							  interval		: Integer;
							  fileName		: String) updating;

begin
	beginTransaction;
	Report.firstInstance.mFileName := fileName;
	commitTransaction;
	startAsynchronousCalls(callers, workers, optionToDo, methodParam, tasks, runs, interval);
end;
}
startCaller
{
startCaller(callers, optionToDo, param, tasks, interval, runs : Integer) updating, protected;

vars
	caller : Caller;
	proc : Process;
	run : Integer;

begin
	foreach run in 1 to callers do
		beginTransaction;
		create caller persistent;
		caller.mParameter := param;
		caller.mNumber := run;
		caller.mOptionToDo := optionToDo;
		caller.mTasks := tasks;
		caller.mInterval := interval;
		caller.mRuns := runs;
		commitTransaction;
		proc := app.startApplicationWithParameter(SCHEMA_NAME, CALLER_APPLICATION, caller);
	endforeach;
end;
}
startWorkers
{
startWorkers(workers : Integer; callers : Integer) protected;

vars
	proc : Process;
	run : Integer;
	worker : Worker;

begin
	foreach run in 1 to workers do
		beginTransaction;
		create worker persistent;
		create worker.mTimer persistent;
		worker.mNumber := run;
		worker.mJobs := 0;
		worker.mExpectedCallers := callers;
		commitTransaction;
		proc := app.startApplicationWithParameter(SCHEMA_NAME, WORKER_APPLICATION, worker);
	endforeach;
end;
}
userNotification
{
userNotification(eventType: Integer; theObject: Object; eventTag: Integer; userInfo: Any) updating;

vars

begin
	if eventType = EVENT_CALLER_FINISHED then
		reserveLock(self);
		mCallersRunning := mCallersRunning - 1;
		mUserInterface.oneCallerFinished();
		unlock(self);
		if mCallersRunning = 0 then
			mUserInterface.allCallersFinished();
		endif;
		return;
	endif;
	if eventType = EVENT_WORKER_FINISHED then
		reserveLock(self);
		mWorkersRunning := mWorkersRunning - 1;
		unlock(self);
		if mWorkersRunning = 0 then
			Report.firstInstance.print();
			Report.firstInstance.finalize();
			Report.firstInstance.init();
			mUserInterface.finishedAction();
		endif;
	endif;
	if eventType = EVENT_REQUEST_STARTS then
		reserveLock(self);
		mUserInterface.incQueue();
		unlock(self);
	endif;
	if eventType = EVENT_REQUEST_IN_ACTION then
		reserveLock(self);
		mUserInterface.decQueue();
		unlock(self);
	endif;
	if eventType = EVENT_CALLER_STARTS then
		reserveLock(self);
		mCallersRunning := mCallersRunning + 1;
		unlock(self);
		if mCallersRunning = mAllCallers then
			Caller.causeClassEvent(EVENT_START_REQUEST, true, null);
		endif;
	endif;
end;
}
	)
	Report (
	jadeMethodSources
addCallerReport
{
addCallerReport(report : CallerReportUnit) updating;

begin
	exclusiveLock(self);
	beginTransaction;
	if mCallerReports.isEmpty() then
		mStartTime := app.relativeMachineMicros();
	endif;
	mCallerReports.add(report);
	commitTransaction;
	unlock(self);
end;
}
addRequestReport
{
addRequestReport(report : RequestReportUnit input);

vars
	now : Decimal[23];
	
begin
	exclusiveLock(self);
	now := app.relativeMachineMicros();
	report.setTimeSinceAppStart(now - mStartTime);
	mCallerReports.getAtKey(report.getCaller()).addRequestReport(report);
	unlock(self);
end;
}
addWorkerReport
{
addWorkerReport(report : WorkerReportUnit);

begin
	exclusiveLock(self);
	beginTransaction;
	mWorkerReports.add(report);
	commitTransaction;
	unlock(self);
end;
}
finalize
{
finalize() updating;

vars
	consRepUnit : CallerReportUnit;
	workRepUnit : WorkerReportUnit;

begin
	beginTransaction;
	foreach consRepUnit in mCallerReports do
		consRepUnit.finalize();
		delete consRepUnit;
	endforeach;
	foreach workRepUnit in mWorkerReports do
		delete workRepUnit;
	endforeach;
	delete mCallerReports;
	delete mWorkerReports;
	mStartTime := 0;
	commitTransaction;
end;
}
handleFileException
{
handleFileException(exception : FileException): Integer protected;

begin
	app.msgBox("Error on file writing.", "Error", MsgBox_Stop_Icon);
	return Ex_Resume_Next;
end;
}
init
{
init() updating;

begin
	beginTransaction;
	create mCallerReports persistent;
	create mWorkerReports persistent;
	commitTransaction;
end;
}
print
{
print();

vars
	file : File;
	dialog : CMDFileSave;
	
begin
	on FileException do handleFileException(exception);
	if mFileName = null then
		create dialog transient;
		dialog.filter := "*.csv";
		if dialog.open() = 0 then
			create file transient;
			file.mode := File.Mode_Output;
			file.fileName := dialog.fileName;
			saveToFile(file);
			file.close();
		endif;
		writeReport();
	else
		create file transient;
		file.mode := File.Mode_Output;
		file.fileName := mFileName;
		saveToFile(file);
		file.close();
	endif;
epilog
	delete file;
	delete dialog;
end;
}
saveToFile
{
saveToFile(file : File) protected;

vars
	callReport : CallerReportUnit;
	workReport : WorkerReportUnit;
	requestReport : RequestReportUnit;
	activeTime, passiveTime, runingTime : Decimal[23];
	run : Integer;

begin
	file.writeString("REPORT" & CrLf & CrLf);

	file.writeString("Worker report" & CrLf & CrLf);
	file.writeString("Worker, Whole running time in microseconds, Number of jobs, Active time in microseconds, Passive time in microseconds, Use of capacity in percent" & CrLf);
	foreach workReport in mWorkerReports do
		activeTime := workReport.getActiveTime();
		runingTime := workReport.getRunningTime();
		passiveTime := runingTime - activeTime;
		file.writeString(workReport.getWorkerNumber().String & ",");
		file.writeString(runingTime.String & ",");
		file.writeString(workReport.getJobs().String & ",");
		file.writeString(activeTime.String & ",");
		file.writeString(passiveTime.String & ",");
		file.writeString((activeTime / runingTime * 100).String & CrLf);
	endforeach;

	file.writeString(CrLf & "Caller report" & CrLf & CrLf);
	file.writeString("Caller, Whole running time in microseconds" & CrLf);
	foreach run in 1 to mCallerReports.size() do
		callReport := mCallerReports.getAtKey(run);
		file.writeString(callReport.getCaller().String & ",");
		file.writeString(callReport.getRunningTime().String & CrLf);
	endforeach;
	
	file.writeString(CrLf & "Request report" & CrLf & CrLf);
	file.writeString("Requests in queue at start, Start time since application start, Whole running time in microseconds, Waited inside the queue in milliseconds, ");
	file.writeString("Active request time in milliseconds, Request from Caller nr., Handled by Worker nr." & CrLf);
	foreach run in 1 to mCallerReports.size() do
		callReport := mCallerReports.getAtKey(run);
		foreach requestReport in callReport.getRequests() do
			file.writeString(requestReport.getRequests().String & ",");
			file.writeString(requestReport.getTimeSinceAppStart().String & ",");
			file.writeString(requestReport.getRunningTime().String & ",");
			file.writeString(requestReport.getPassiveRunningTime().String & ",");
			file.writeString(requestReport.getActiveRunningTime().String & ",");
			file.writeString(requestReport.getCaller().String & ",");
			file.writeString(requestReport.getWorker().String & CrLf);
		endforeach;
	endforeach;
end;
}
transform
{
transform(number : Decimal): String protected;

vars
	result, addString : String;
	numberInt, numberAdd : Integer;
	
begin
	result := "";
	numberInt := number.Integer;
	numberAdd := numberInt - (numberInt div 1000 * 1000);
	while numberAdd > 0 or numberInt <> 0 do
		addString := numberAdd.String;
		while addString.length <> 3 and numberInt > 999 do
			addString := "0" & addString;
		endwhile;
		if result <> "" then
			addString := addString & ".";
		endif;
		result := addString & result;
		numberInt := numberInt div 1000;
		numberAdd := numberInt - (numberInt div 1000 * 1000);
	endwhile;
	return result;
end;
}
writeReport
{
writeReport() protected;

vars
	callReport : CallerReportUnit;
	workReport : WorkerReportUnit;
	requestReport : RequestReportUnit;
	activeTime, passiveTime, runingTime : Decimal[23];

begin
	write "REPORT";
	write "------";
	foreach callReport in mCallerReports do
		write "Caller : " & callReport.getCaller().String;
		write "Running time : " & transform(callReport.getRunningTime()) & " microseconds.";
		write "-------------------------------------------";
		foreach requestReport in callReport.getRequests() do
			write "Request from Caller : " & requestReport.getCaller().String;
			write "Handled by Worker : " & requestReport.getWorker().String;
			write "Requests in queue at start : " & requestReport.getRequests().String;
			write "Start time since application start : " & transform(requestReport.getTimeSinceAppStart()) & " microseconds.";
			write "Whole time running : " & transform(requestReport.getRunningTime()) & " microseconds.";
			write "Waited inside the queue : " & transform(requestReport.getPassiveRunningTime()) & " microseconds.";
			write "Active request time : " & transform(requestReport.getActiveRunningTime()) & " microseconds.";
			write "-------------------------------------------";
		endforeach;
	endforeach;
	foreach workReport in mWorkerReports do
		activeTime := workReport.getActiveTime();
		runingTime := workReport.getRunningTime();
		passiveTime := runingTime - activeTime;
		write "Worker : " & workReport.getWorkerNumber().String;
		write "Running time : " & transform(runingTime) & " microseconds.";
		write "Number of jobs : " & workReport.getJobs().String;
		write "Active time : " & transform(activeTime) & " microseconds.";
		write "Passive time : " & transform(passiveTime) & " microseconds.";
		write "Use to capacity : " & transform(activeTime / runingTime * 100) & " percent.";
		write "-------------------------------------------";
	endforeach;
end;
}
	)
	ReportUnit (
	jadeMethodSources
getRunningTime
{
getRunningTime(): Decimal;

begin
	return mEndTime - mStartTime;
end;
}
start
{
start() updating;

begin
	beginTransaction;
	mStartTime := app.relativeMachineMicros();
	commitTransaction;
end;
}
stop
{
stop() updating;

begin
	beginTransaction;
	mEndTime := app.relativeMachineMicros();
	commitTransaction;
end;
}
	)
	CallerReportUnit (
	jadeMethodSources
addRequestReport
{
addRequestReport(report : RequestReportUnit);

begin
	beginTransaction;
	mRequests.add(report);
	commitTransaction;
end;
}
finalize
{
finalize() updating;

vars
	report : RequestReportUnit;

begin
	foreach report in mRequests do
		delete report;
	endforeach;
	delete mRequests;
end;
}
getCaller
{
getCaller(): Integer;

begin
	return mCallerNumber;
end;
}
getRequests
{
getRequests(): RequestReportUnitSet;

begin
	return mRequests;
end;
}
init
{
init() updating;

begin
	beginTransaction;
	create mRequests persistent;
	commitTransaction;
end;
}
setCaller
{
setCaller(caller : Integer) updating;

begin
	beginTransaction;
	mCallerNumber := caller;
	commitTransaction;
end;
}
	)
	ContinueableReportUnit (
	jadeMethodSources
getPassiveTime
{
getPassiveTime(): Decimal;

begin
	return mPassiveTime;
end;
}
getRunningTime
{
getRunningTime(): Decimal;

begin
	return mRunTime;
end;
}
start
{
start() updating;

begin
	beginTransaction;
	mStartTime := app.relativeMachineMicros();
	if mEndTime <> 0 then
		mPassiveTime := mPassiveTime + mStartTime - mEndTime;
	endif;
	commitTransaction;
end;
}
stop
{
stop() updating;

begin
	beginTransaction;
	mEndTime := app.relativeMachineMicros();
	mRunTime := mRunTime + mEndTime - mStartTime;
	commitTransaction;
end;
}
	)
	RequestReportUnit (
	jadeMethodSources
getActiveRunningTime
{
getActiveRunningTime(): Decimal;

begin
	return mEndTime - mStartAction;
end;
}
getCaller
{
getCaller(): Integer;

begin
	return mCaller;
end;
}
getPassiveRunningTime
{
getPassiveRunningTime(): Decimal;

begin
	return mStartAction - mStartTime;
end;
}
getRequests
{
getRequests(): Integer;

begin
	return mRequestsInQueue;
end;
}
getTimeSinceAppStart
{
getTimeSinceAppStart(): Decimal;

begin
	return mTimeSinceAppStart;
end;
}
getWorker
{
getWorker(): Integer;

begin
	return mWorker;
end;
}
setCaller
{
setCaller(callerNumber : Integer) updating;

begin
	beginTransaction;
	mCaller := callerNumber;
	commitTransaction;
end;
}
setRequests
{
setRequests(requests : Integer) updating;

begin
	beginTransaction;
	mRequestsInQueue := requests;
	commitTransaction;
end;
}
setTimeSinceAppStart
{
setTimeSinceAppStart(time : Decimal) updating;

begin
	beginTransaction;
	mTimeSinceAppStart := time;
	commitTransaction;
end;
}
setWorker
{
setWorker(workerNumber : Integer) updating;

begin
	beginTransaction;
	mWorker := workerNumber;
	mStartAction := app.relativeMachineMicros();
	commitTransaction;
end;
}
	)
	WorkerReportUnit (
	jadeMethodSources
getActiveTime
{
getActiveTime(): Decimal;

begin
	return mActiveTime;
end;
}
getJobs
{
getJobs(): Integer;

begin
	return mJobs;
end;
}
getPassiveTime
{
getPassiveTime(): Decimal;

begin
	return mPassiveTime;
end;
}
getWorkerNumber
{
getWorkerNumber(): Integer;

begin
	return mWorkerNumber;
end;
}
setData
{
setData(jobs : Integer; activeTime : Decimal; passiveTime : Decimal) updating;

begin
	beginTransaction;
	mJobs := jobs;
	mActiveTime := activeTime;
	mPassiveTime := passiveTime;
	commitTransaction;
end;
}
setWorker
{
setWorker(worker : Integer) updating;

begin
	beginTransaction;
	mWorkerNumber := worker;
	commitTransaction;
end;
}
	)
	MainForm (
	jadeMethodSources
btnStart_click
{
btnStart_click(btn: Button input) updating;

vars
	callers, workers, optionToDo, param, interval, tasks, runs : Integer;
	
begin
	txtStatus.text := "";
	if checkInputErrors() then
		callers := txtCallers.text.Integer;
		workers := txtWorkers.text.Integer;
		param := txtParam.text.Integer;
		interval := txtInterval.text.Integer;
		tasks := txtTasks.text.Integer;
		runs := txtRuns.text.Integer;
		if optNoResource.value then
			optionToDo := DO_NOTHING;
		endif;
		if optCPU.value then
			optionToDo := USE_CPU;
		endif;
		if optIO.value then
			optionToDo := USE_IO;
		endif;
		if optUseBoth.value then
			optionToDo := USE_CPU_AND_IO;
		endif;
		btnStart.enabled := false;
		mProcessingUnit.startAsynchronousCalls(callers, workers, optionToDo, param, tasks, runs, interval);
	endif;
end;
}
checkInputErrors
{
checkInputErrors(): Boolean protected;

vars
	optChoosed : Boolean;

begin
	optChoosed := optCPU.value or optIO.value or optNoResource.value or optUseBoth.value;
	if not optChoosed then
		app.msgBox("Please choose one option what the processes have to do.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	if txtCallers.text = "" then
		app.msgBox("Please insert the number of callers.", self.caption, MsgBox_Stop_Icon);
		return false;
	elseif txtCallers.text.Integer <= 0 then
		app.msgBox("Please enter a number of callers greater than zero.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	if txtWorkers.text = "" then
		app.msgBox("Please insert the number of workers.", self.caption, MsgBox_Stop_Icon);
		return false;
	elseif txtWorkers.text.Integer <= 0 then
		app.msgBox("Please enter a number of workers greater than zero.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	if txtParam.text = "" then
		app.msgBox("Please insert the operation parameter.", self.caption, MsgBox_Stop_Icon);
		return false;
	elseif txtParam.text.Integer <= 0 then
		app.msgBox("Please enter an operation parameter greater than zero.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	if txtInterval.text = "" then
		app.msgBox("Please insert the interval time.", self.caption, MsgBox_Stop_Icon);
		return false;
	elseif txtInterval.text.Integer <= 0 then
		app.msgBox("Please enter an interval time greater than zero.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	if txtTasks.text = "" then
		app.msgBox("Please insert the number of tasks.", self.caption, MsgBox_Stop_Icon);
		return false;
	elseif txtTasks.text.Integer <= 0 then
		app.msgBox("Please enter a number of tasks greater than zero.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	if txtRuns.text = "" then
		app.msgBox("Please insert the number of intervals.", self.caption, MsgBox_Stop_Icon);
		return false;
	elseif txtRuns.text.Integer <= 0 then
		app.msgBox("Please enter a number of intervals greater than zero.", self.caption, MsgBox_Stop_Icon);
		return false;
	endif;

	return true;
end;
}
load
{
load() updating;

begin
	mQueueSize := 0;
	create mProcessingUnit transient;
	mProcessingUnit.init(self);
end;
}
optCPU_click
{
optCPU_click(optionbutton: OptionButton input) updating;

begin
	lblParam.caption := LBL_NUMBER;
end;
}
optIO_click
{
optIO_click(optionbutton: OptionButton input) updating;

begin
	lblParam.caption := LBL_TRANSACTIONS;
end;
}
optNoResource_click
{
optNoResource_click(optionbutton: OptionButton input) updating;

begin
	lblParam.caption := LBL_DO_NOTHING;
end;
}
optUseBoth_click
{
optUseBoth_click(optionbutton: OptionButton input) updating;

begin
	lblParam.caption := LBL_NUMBER;
end;
}
stub_AllCallersFinished
{
stub_AllCallersFinished();

begin
	txtStatus.text := txtStatus.text & "All callers finished." & CrLf;
end;
}
stub_CallersCreated
{
stub_CallersCreated();

begin
	txtStatus.text := txtStatus.text & "Caller processes created." & CrLf;
end;
}
stub_DecQueue
{
stub_DecQueue() updating;

begin
	mQueueSize := mQueueSize - 1;
	txtQueue.text := mQueueSize.String;
	txtStatus.text := txtStatus.text & "Take request to start action." & CrLf;
end;
}
stub_FinishedAction
{
stub_FinishedAction();

begin
	btnStart.enabled := true;
end;
}
stub_IncQueue
{
stub_IncQueue() updating;

begin
	mQueueSize := mQueueSize + 1;
	txtQueue.text := mQueueSize.String;
	txtStatus.text := txtStatus.text & "Put a new request into the queue." & CrLf;
end;
}
stub_OneCallerFinished
{
stub_OneCallerFinished();

begin
	txtStatus.text := txtStatus.text & "A caller finished his work." & CrLf;
end;
}
stub_WorkersCreated
{
stub_WorkersCreated();

begin
	txtStatus.text := txtStatus.text & "Worker processes created" & CrLf;
end;
}
txtCallers_change
{
txtCallers_change(textbox: TextBox input) updating;

vars

begin

end;
}
txtParam_change
{
txtParam_change(textbox: TextBox input) updating;

vars

begin

end;
}
txtWorkers_change
{
txtWorkers_change(textbox: TextBox input) updating;

vars

begin

end;
}
unload
{
unload() updating;

begin
	mProcessingUnit.finalize();
	delete mProcessingUnit;
end;
}
	)
	Worker (
	jadeMethodSources
doNothing
{
doNothing(time : Integer);

begin
	process.sleep(app.poissonRandom(time));
end;
}
doWork
{
doWork(optionToDo : Integer; param : Integer; report : RequestReportUnit input);

begin
  	ProcessingUnit.causeClassEvent(EVENT_REQUEST_IN_ACTION, true, null);
	app.mWorker.mTimer.start();
	report.setWorker(app.mWorker.mNumber);
	beginTransaction;
	app.mWorker.mJobs := app.mWorker.mJobs + 1;
	commitTransaction;
	if optionToDo = DO_NOTHING then
		doNothing(param);
	endif;
	if optionToDo = USE_CPU then
		useCPU(param);
	endif;
	if optionToDo = USE_IO then
		useIO(param);
	endif;
	if optionToDo = USE_CPU_AND_IO then
		useCPUandIO(param);
	endif;
	app.mWorker.mTimer.stop();
	report.stop();
end;
}
useCPU
{
useCPU(level : Integer);

vars
	number, result, runNumber : Integer;

begin
	result := 0;
	number := level;
	
	while number > 2 do
		number := number - 1;
		runNumber := number - 1;
		while runNumber > 1 do
			if number mod runNumber = 0 then
				// no prime number more
				result := result + 1;
				runNumber := 1;
			endif;
			runNumber := runNumber - 1;
		endwhile;
	endwhile;
end;
}
useCPUandIO
{
useCPUandIO(level : Integer);

vars
	number, result, runNumber : Integer;
	trans : Transaction;

begin
	result := 0;
	number := level;
	
	while number > 2 do
		beginTransaction;
		create trans persistent;
		trans.mNumber := number;
		commitTransaction;
		number := number - 1;
		runNumber := number - 1;
		while runNumber > 1 do
			if number mod runNumber = 0 then
				// no prime number more
				result := result + 1;
				runNumber := 1;
			endif;
			runNumber := runNumber - 1;
		endwhile;
		beginTransaction;
		delete trans;
		commitTransaction;
	endwhile;
end;
}
useIO
{
useIO(transactions : Integer);

vars
	set : TransactionSet;
	trans : Transaction;
	run : Integer;

begin
	create set transient;

	foreach run in 1 to transactions do
		beginTransaction;
		create trans persistent;
		trans.mNumber := run;
		commitTransaction;
		set.add(trans);
	endforeach;
	while not set.isEmpty() do
		trans := set.first();
		set.remove(trans);
		beginTransaction;
		delete trans;
		commitTransaction;
	endwhile;
epilog
	delete set;
end;
}
	)
	IUIProcessingUnit (
	jadeMethodSources
allCallersFinished
{
allCallersFinished();
}
callersCreated
{
callersCreated();
}
decQueue
{
decQueue();
}
finishedAction
{
finishedAction();
}
incQueue
{
incQueue();
}
oneCallerFinished
{
oneCallerFinished();
}
workersCreated
{
workersCreated();
}
	)
