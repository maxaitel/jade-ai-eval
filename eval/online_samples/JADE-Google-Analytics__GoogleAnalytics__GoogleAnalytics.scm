/* JADE COMMAND FILE NAME D:\GitGoogleAnalytics\GoogleAnalytics\GoogleAnalytics.jcf */
jadeVersionNumber "99.0.00";
schemaDefinition
GoogleAnalytics subschemaOf RootSchema completeDefinition, patchVersioningEnabled = false;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.605;
importedPackageDefinitions
constantDefinitions
	categoryDefinition GCs
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:21:35.088;
		CollectorNotification:         Integer = 5432101;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:51:03.457;
		Terminate:                     Integer = 666;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:21:52.722;
		ToogleDebugMessages:           Integer = 83265;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:22:10.719;
localeDefinitions
	5129 "English (New Zealand)" schemaDefaultLocale;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.450;
libraryDefinitions
typeHeaders
	GoogleAnalytics subclassOf RootSchemaApp transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed, highestOrdinal = 6, number = 2793;
	Collector subclassOf Object highestOrdinal = 3, number = 2796;
	AsyncSender subclassOf Collector number = 2789;
	BackgroundSender subclassOf Collector number = 2797;
	GGoogleAnalytics subclassOf RootSchemaGlobal transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed, highestOrdinal = 2, number = 2794;
	SGoogleAnalytics subclassOf RootSchemaSession transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed, number = 2795;
	ExampleApp subclassOf Form transient, transientAllowed, subclassTransientAllowed, highestOrdinal = 12, number = 2791;
 
interfaceDefs
membershipDefinitions
 
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
	GoogleAnalytics completeDefinition
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.604;
	attributeDefinitions
		debugMessages:                 Boolean number = 2, ordinal = 2;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:13:29:07.583;
		debugTime:                     Time number = 3, ordinal = 3;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:13:25:51.654;
		googleID:                      String[31] number = 4, ordinal = 4;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:28:50.528;
		userUUID:                      String[37] number = 1, ordinal = 1;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:24:41.361;
	referenceDefinitions
		collector:                     Collector  number = 6, ordinal = 6;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:23:41.678;
		controller:                    BackgroundSender  number = 5, ordinal = 5;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:48:46.992;
 
	jadeMethodDefinitions
		asyncFini() number = 1005;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:05:53.191;
		asyncInit() number = 1004;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:18:32.444;
		backgroundInit() updating, number = 1003;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:23:15.510;
		generateUUID() updating, number = 1001;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:26:09.763;
		initialize() updating, number = 1002;
		setModifiedTimeStamp "cnwta3" "99.0.00" 2018:10:29:13:59:15.253;
		userNotification(
			eventType: Integer; 
			theObject: Object; 
			eventTag: Integer; 
			userInfo: Any) updating, number = 1006;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:22:48.366;
	)
	Collector completeDefinition
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:48:37.694;
	attributeDefinitions
		asyncDirect:                   Boolean number = 2, ordinal = 2;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:44:00.881;
		sendDirect:                    Boolean number = 1, ordinal = 1;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:43:36.390;
 
	jadeMethodDefinitions
		create() updating, number = 1011;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:55:23.171;
		debug(msg: String) number = 1008;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:35:13.998;
		debugRequestTime() number = 1007;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:37:14.527;
		endSession(): Boolean number = 1006;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:16:03:37.805;
		logEvent(
			category: String; 
			action: String; 
			label: String; 
			value: Integer): Boolean number = 1005;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:16:03:33.047;
		logExecption(
			description: String; 
			fatal: Boolean): Boolean number = 1004;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:16:03:29.357;
		logScreenView(
			screenName: String; 
			appName: String): Boolean number = 1003;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:16:03:25.934;
		logTiming(
			category: String; 
			variable: String; 
			label: String; 
			time: Integer): Boolean number = 1002;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:16:03:21.437;
		send(
			msg: String; 
			presClient: Boolean): Boolean number = 1009;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:13:56:28.438;
		sendAsync(msg: String) number = 1010;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:27:57.254;
		startSession(): Boolean number = 1001;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:13:32.194;
	)
	AsyncSender completeDefinition
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:18:32.440;
 
	jadeMethodDefinitions
		createAsyncObject() number = 1001;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:18:32.444;
	)
	BackgroundSender completeDefinition
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:18:04.708;
 
	jadeMethodDefinitions
		userNotification(
			eventType: Integer; 
			theObject: Object; 
			eventTag: Integer; 
			userInfo: Any) updating, number = 1001;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:13:29:07.575;
	)
	Global completeDefinition
	(
	)
	RootSchemaGlobal completeDefinition
	(
	)
	GGoogleAnalytics completeDefinition
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.605;
	attributeDefinitions
		googleID:                      String[31] number = 1, ordinal = 1;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:29:17.563;
	referenceDefinitions
		asyncClass:                    AsyncSender  number = 2, ordinal = 2;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:09:17.207;
 
	jadeMethodDefinitions
		getGoogleID(): Integer updating, number = 1001;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:57:47.847;
	)
	JadeScript completeDefinition
	(
 
	jadeMethodDefinitions
		createAsyncObject() number = 1002;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:18:32.444;
	)
	WebSession completeDefinition
	(
	)
	RootSchemaSession completeDefinition
	(
		setModifiedTimeStamp "<unknown>" "6.1.00" 20031119 2003:12:01:13:54:02.270;
	)
	SGoogleAnalytics completeDefinition
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.605;
	)
	Window completeDefinition
	(
	)
	Form completeDefinition
	(
	)
	ExampleApp completeDefinition
	(
		setModifiedTimeStamp "cnwta3" "99.0.00" 2018:10:29:14:36:59.571;
	attributeDefinitions
		lastActivateTime:              TimeStamp number = 3, ordinal = 3;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:32:51.284;
	referenceDefinitions
		asyncSender:                   Process  number = 6, ordinal = 6;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:13:59:54.567;
		backgroundSender:              Process  number = 7, ordinal = 7;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:00:46.923;
		btnAsync:                      Button  number = 5, ordinal = 5;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:43:25.889;
		btnBackground:                 Button  number = 4, ordinal = 4;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:42:39.438;
		btnCheckGoogleID:              Button  number = 10, ordinal = 10;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:10:50.420;
		btnDebug:                      Button  number = 8, ordinal = 8;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:13:57:08.519;
		btnEvent:                      Button  number = 2, ordinal = 2;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:20:56.012;
		btnOpenGoogle:                 Button  number = 12, ordinal = 12;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:05:10:04:02.185;
		btnStopSenderApps:             Button  number = 9, ordinal = 9;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:05:59.089;
		chkSendActivateMessages:       CheckBox  number = 11, ordinal = 11;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:23:16.193;
		status:                        StatusLine  number = 1, ordinal = 1;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:20:56.007;
 
	jadeMethodDefinitions
		activate() updating, number = 1002;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:26:13.472;
		btnAsync_click(btn: Button input) updating, number = 1005;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:02:39.937;
		btnBackground_click(btn: Button input) updating, number = 1004;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:33:28.416;
		btnCheckGoogleID_click(btn: Button input) updating, number = 1010;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:18:05.574;
		btnDebug_click(btn: Button input) updating, number = 1006;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:38:43.708;
		btnEvent_click(btn: Button input) updating, number = 1001;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:15:31:52.396;
		btnOpenGoogle_click(btn: Button input) updating, number = 1014;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:05:10:05:44.651;
		btnStopSenderApps_click(btn: Button input) updating, number = 1008;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:08:07.837;
		checkGoogleID() number = 1011;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:17:48.355;
		deactivate() updating, number = 1003;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:26:24.959;
		exceptionHandler(ex: Exception): Integer updating, number = 1013;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:15:21:01.867;
		load() updating, number = 1012;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:18:22.601;
		stopSenderApps() updating, number = 1007;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:25:02.007;
		unload() updating, number = 1009;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:07:03:14:07:52.678;
 
	eventMethodMappings
		activate = activate of Form;
		btnAsync_click = click of Button;
		btnBackground_click = click of Button;
		btnCheckGoogleID_click = click of Button;
		btnDebug_click = click of Button;
		btnEvent_click = click of Button;
		btnOpenGoogle_click = click of Button;
		btnStopSenderApps_click = click of Button;
		deactivate = deactivate of Form;
		load = load of Form;
		unload = unload of Form;
	)
 
inverseDefinitions
databaseDefinitions
GoogleAnalyticsDb
	(
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.605;
	databaseFileDefinitions
		"googleanalytics" number=95;
		setModifiedTimeStamp "cnwth3" "99.0.00" 2018:06:29:14:21:33.605;
	defaultFileDefinition "googleanalytics";
	classMapDefinitions
		SGoogleAnalytics in "_environ";
		GoogleAnalytics in "_usergui";
		GGoogleAnalytics in "googleanalytics";
		Collector in "googleanalytics";
		BackgroundSender in "googleanalytics";
		AsyncSender in "googleanalytics";
	)
schemaViewDefinitions
exportedPackageDefinitions
typeSources
	GoogleAnalytics (
	jadeMethodSources
asyncFini
{
asyncFini();

vars

begin
	app.asyncFinalize();
end;

}

asyncInit
{
asyncInit();

vars
	ac : AsyncSender;
begin
	
	
	if global.asyncClass = null then
		create ac transient;
		ac.createAsyncObject();
		delete ac;
	endif;
	
	beginNotification(global,Terminate,Response_Continuous,null);
	beginNotification(global,ToogleDebugMessages,Response_Continuous,null);
	
	app.asyncInitialize();
end;

}

backgroundInit
{
backgroundInit() updating;

vars

begin
	initialize();
		
	controller.beginNotification(controller,CollectorNotification,Response_Continuous,CollectorNotification);
	
	beginNotification(global,Terminate,Response_Continuous,null);
	beginNotification(global,ToogleDebugMessages,Response_Continuous,null);
end;

}

generateUUID
{
generateUUID() updating;

vars

begin
	if userUUID = null then
		userUUID := generateUuid(3).uuidAsString.String;
	endif;
end;

}

initialize
{
initialize() updating;

vars

begin
	inheritMethod();	
	
	generateUUID();		
	
	global.getGoogleID();
	googleID := global.googleID;
	
	create collector transient;
	
	if BackgroundSender.firstInstance = null then
		beginTransaction;
			create controller persistent;
		commitTransaction;
	else
		controller := BackgroundSender.firstInstance();
	endif;
	
end;

}

userNotification
{
userNotification(eventType: Integer; theObject: Object; eventTag: Integer; userInfo: Any) updating;

vars

begin
	if eventType = Terminate then
		terminate;
	elseif eventType = ToogleDebugMessages then
		debugMessages := not debugMessages;
	endif;
end;

}

	)
	Collector (
	jadeMethodSources
create
{
create() updating;

vars

begin	
	
	sendDirect := true;
	asyncDirect := false;
	
end;

}

debug
{
debug(msg : String);

vars

begin
	if app.debugMessages then
		write "================= Start of Debug Message ======================";
		write app.name;
		write msg;
		app.debugTime := app.actualTime.Time;
	endif;
end;

}

debugRequestTime
{
debugRequestTime();

vars

begin
	if app.debugMessages then		
		write "Time to process HTTP POST msg = " & (app.actualTime.Time - app.debugTime.Time).Integer.String & " ms";
		write "================= End of Debug Message ======================";
	endif;
end;

}

endSession
{
endSession() : Boolean;

vars
	msg : String;	
begin
			
	msg := 'v=1';
	msg := msg & '&t=timing';
	msg := msg & '&tid='&app.googleID;
	msg := msg & '&cid='&app.userUUID;
	msg := msg & '&uid='&app.userName&app.clock.String;
	msg := msg & '&sc=end';
			
	if sendDirect then					
		if asyncDirect then			
			sendAsync(msg); 
			return true;
		else		
			return send(msg,true);
		endif;
	else
		app.controller.causeEvent(CollectorNotification,true,msg);		
	endif;	
		
	return true;	
end;


}

logEvent
{
logEvent(category,action,label:String;value:Integer) : Boolean;

vars	
	msg : String;	
begin
				
	msg := 'v=1';
	msg := msg & '&t=event';
	msg := msg & '&tid='&app.googleID;
	msg := msg & '&cid='&app.userUUID;
	msg := msg & '&uid='&app.userName&app.clock.String;
	msg := msg & '&ec='&category;
	msg := msg & '&ea='&action;
	msg := msg & '&el='&label;
	msg := msg & '&ev='&value.String;
			
	if sendDirect then					
		if asyncDirect then			
			sendAsync(msg); 
			return true;
		else		
			return send(msg,true);
		endif;
	else
		app.controller.causeEvent(CollectorNotification,true,msg);		
	endif;	
		
	return true;	
end;

}

logExecption
{
logExecption(description:String;fatal:Boolean) : Boolean;

vars	
	msg : String;	
begin
			
	msg := 'v=1';
	msg := msg & '&t=exception';
	msg := msg & '&tid='&app.googleID;
	msg := msg & '&cid='&app.userUUID;
	msg := msg & '&uid='&app.userName&app.clock.String;
	msg := msg & '&exd='&description;
	
	if fatal then
		msg := msg & '&exf=1';
	else
		msg := msg & '&exf=0';
	endif;
	
	if sendDirect then					
		if asyncDirect then			
			sendAsync(msg); 
			return true;
		else		
			return send(msg,true);
		endif;
	else
		app.controller.causeEvent(CollectorNotification,true,msg);		
	endif;	
		
	return true;	
end;


}

logScreenView
{
logScreenView(screenName,appName:String) : Boolean;

vars
	msg : String;		
begin	
			
	msg := 'v=1';	
	msg := msg & '&tid='&app.googleID;
	msg := msg & '&cid='&app.userUUID;
	msg := msg & '&uid='&app.userName&app.clock.String;
	
	msg := msg & '&t=screenview';
	msg := msg & '&an='&app.name;
	msg := msg & '&av=1';
	msg := msg & '&aid=JADEAPP';
	msg := msg & '&aiid=JADEAPPInstallerId';
	msg := msg & '&cd='&screenName;
				
	if sendDirect then					
		if asyncDirect then			
			sendAsync(msg); 
			return true;
		else		
			return send(msg,true);
		endif;
	else
		app.controller.causeEvent(CollectorNotification,true,msg);		
	endif;	
		
	return true;	
end;

}

logTiming
{
logTiming(category,variable,label:String;time:Integer) : Boolean;

vars	
	msg : String;	
begin			
	msg := 'v=1';
	msg := msg & '&t=timing';
	msg := msg & '&tid='&app.googleID;
	msg := msg & '&cid='&app.userUUID;
	msg := msg & '&uid='&app.userName&app.clock.String;
	msg := msg & '&utc='&category;
	msg := msg & '&utv='&variable;
	msg := msg & '&utt='&time.String;
	msg := msg & '&utl='&label;
			
	if sendDirect then					
		if asyncDirect then			
			sendAsync(msg); 
			return true;
		else		
			return send(msg,true);
		endif;
	else
		app.controller.causeEvent(CollectorNotification,true,msg);		
	endif;	
		
	return true;	
end;

}

send
{
send(msg:String; presClient : Boolean):Boolean;

vars
	httpClass:	JadeHTTPConnection;	
begin
	create httpClass transient;	
	httpClass.usePresentationClient := presClient;

	httpClass.httpVersion := JadeHTTPConnection.ProtocolVersion_1_1;
	httpClass.url := "https://www.google-analytics.com/collect";
	httpClass.open(true);	
	debug(msg);	
	return httpClass.sendRequest("POST",null,msg);
	
epilog
	debugRequestTime();
end;

}

sendAsync
{
sendAsync(msg:String);

vars
	m1 : JadeMethodContext;	
begin
	create m1 transient;
	m1.workerAppName := "AsyncSender";
	m1.invoke(global.asyncClass,send,msg,false);
epilog
	delete m1;
end;

}

startSession
{
startSession() : Boolean;

vars	
	msg : String;	
begin	
			
	msg := 'v=1';
	msg := msg & '&t=timing';
	msg := msg & '&tid='&app.googleID;
	msg := msg & '&cid='&app.userUUID;
	msg := msg & '&uid='&app.userName&app.clock.String;
	msg := msg & '&sc=start';
		
	if sendDirect then					
		if asyncDirect then			
			sendAsync(msg); // perform async call to GA here
			return true;
		else		
			return send(msg,true);
		endif;
	else
		app.controller.causeEvent(CollectorNotification,true,msg);		
	endif;	
		
	return true;
end;

}

	)
	AsyncSender (
	jadeMethodSources
createAsyncObject
{
createAsyncObject();

vars
	ac : AsyncSender;
begin
	
	ac := AsyncSender.firstInstance;

	if ac = null then
		beginTransaction;
			create ac persistent;			
		commitTransaction;	
	endif;
	
	if global.asyncClass = null then
		beginTransaction;
			global.asyncClass := ac;
		commitTransaction;
	endif;
	
end;

}

	)
	BackgroundSender (
	jadeMethodSources
userNotification
{
userNotification(eventType: Integer; theObject: Object; eventTag: Integer; userInfo: Any) updating;

vars
	c : Collector;
begin
	if app.debugMessages then
		write method.qualifiedName & " userInfo = " & userInfo.String;
	endif;
	
	if eventType = CollectorNotification then
		create c transient;
		c.send(userInfo.String,false);
		delete c;
	endif;
end;

}

	)
	GGoogleAnalytics (
	jadeMethodSources
getGoogleID
{
getGoogleID():Integer updating;

vars
	id : String;
begin
	id := app.getProfileString(app.getIniFileNameAppServer,'GoogleAnalytics',"GoogleID",null).String;				
	
	if id = null then
		return 666;
	else	
		beginTransaction;
			googleID := id;
		commitTransaction;
		return 0;
	endif;	
end;

}

	)
	JadeScript (
	jadeMethodSources
createAsyncObject
{
createAsyncObject();

vars
	ac : AsyncSender;
begin
	
	ac := AsyncSender.firstInstance;

	if ac = null then
		beginTransaction;
		create ac persistent;
		commitTransaction;
	else
		beginTransaction;
			global.asyncClass := ac;
		commitTransaction;
	endif;
end;

}

	)
	ExampleApp (
	jadeMethodSources
activate
{
activate() updating;

vars

begin
	if chkSendActivateMessages.value then
		app.collector.logScreenView(self.name,'ExampleApp');	
		lastActivateTime := app.actualTime();
	endif;
end;

}

btnAsync_click
{
btnAsync_click(btn: Button input) updating;

vars

begin
	if app.collector.asyncDirect then
		app.collector.asyncDirect := false;
		status.caption := 'Async Sender disabled';		
	else
		app.collector.asyncDirect := true;		
		status.caption := 'Async Sender enabled';
				
		if asyncSender = null then
			asyncSender := app.startApplication(currentSchema.name,'AsyncSender');
		endif;		
	endif;		
end;

}

btnBackground_click
{
btnBackground_click(btn: Button input) updating;

vars

begin
	if app.collector.sendDirect then
		app.collector.sendDirect := false;
		status.caption := 'Background Sender enabled';	
		
		if backgroundSender = null then
			backgroundSender := app.startApplication(currentSchema.name,'BackgroundSender');
		endif;		
		
	else
		app.collector.sendDirect := true;		
		status.caption := 'Background Sender disabled';		
	endif;		
end;

}

btnCheckGoogleID_click
{
btnCheckGoogleID_click(btn: Button input) updating;

vars

begin
	checkGoogleID();
end;

}

btnDebug_click
{
btnDebug_click(btn: Button input) updating;

vars

begin
	if app.debugMessages then
		app.debugMessages := false;
		status.caption := 'Debug messages disabled';
	else
		app.debugMessages := true;
		status.caption := 'Debug messages enabled';
		global.causeEvent(ToogleDebugMessages,true,null);
	endif;
		
end;

}

btnEvent_click
{
btnEvent_click(btn: Button input) updating;

vars

begin
	app.collector.logEvent('Event','ButtonClick','EventButton',1);
end;

}

btnOpenGoogle_click
{
btnOpenGoogle_click(btn: Button input) updating;

vars

begin	
	call josShellExecute(null, "open", 'https://analytics.google.com/analytics/web/#/realtime/', null, null, 1);	
end;

}

btnStopSenderApps_click
{
btnStopSenderApps_click(btn: Button input) updating;

vars

begin
	stopSenderApps();
end;

}

checkGoogleID
{
checkGoogleID();

vars
	id : String;
begin

	id := global.googleID;
	
	if id = null then
		status.caption := 'Google ID is not set, please set it in your Applicaiton Server INI file';
	else
		status.caption := 'Google ID set to ' & id;
	endif;

end;
}

deactivate
{
deactivate() updating;

vars
	msActive : Integer;
begin
	if chkSendActivateMessages.value then
		msActive := (app.actualTimeServer.time - lastActivateTime.time).Integer;		
		app.collector.logTiming('FormActiveTime',self.name,'OnDeactivate',msActive);	
	endif;
end;

}

exceptionHandler
{
exceptionHandler(ex:Exception):Integer updating;

vars

begin
	if ex.errorCode = 31923 then
		app.collector.asyncDirect := false;
		asyncSender := null;
		status.caption := 'AsyncSender Worker application NOT running!';
		return Ex_Abort_Action;
	endif;
	
	return Ex_Pass_Back;
end;

}

load
{
load() updating;

vars

begin
	checkGoogleID();
end;

}

stopSenderApps
{
stopSenderApps() updating;

vars

begin
	global.causeEvent(Terminate,true,null);
	asyncSender := null;
	backgroundSender := null;
end;

}

unload
{
unload() updating;

vars

begin
	stopSenderApps();
end;

}

	)
