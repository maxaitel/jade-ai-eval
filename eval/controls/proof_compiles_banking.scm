/* JADE COMMAND FILE NAME D:\Jades\JadeDailyUNICODE12.10.2018\Erewhon Files\BankingSchema\BankingModelSchema.jcf */
jadeVersionNumber "99.0.00";
schemaDefinition
BankingModelSchema subschemaOf RootSchema completeDefinition, patchVersioningEnabled = false;
		setModifiedTimeStamp "cnwta3" "6.1.05" 2018:10:15:16:29:27;
importedPackageDefinitions
constantDefinitions
	categoryDefinition FinancialConstants
		setModifiedTimeStamp "cnwta3" "6.1.05" 2018:10:15:16:29:27;
		TaxRate:                       Decimal = 0.125;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:16:36:57;
localeDefinitions
	5129 "English (New Zealand)" schemaDefaultLocale;
		setModifiedTimeStamp "cnwta3" "6.1.05" 2018:10:15:16:29:27;
	10249 "English (Belize)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	1033 "English (United States)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	11273 "English (Trinidad and Tobago)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	2057 "English (United Kingdom)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	3081 "English (Australia)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	4105 "English (Canada)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	6153 "English (Ireland)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	7177 "English (South Africa)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	8201 "English (Jamaica)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
	9225 "English (Caribbean)" _cloneOf 5129;
		setModifiedTimeStamp "<unknown>" "" 2018:10:15:16:29:27;
libraryDefinitions
typeHeaders
	BankingModelSchema subclassOf RootSchemaApp transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed, highestOrdinal = 1, number = 2048;
	Bank subclassOf Object highestSubId = 4, highestOrdinal = 5, number = 2049;
	BankAccount subclassOf Object abstract, highestSubId = 1, highestOrdinal = 3, number = 2050;
	ChequeAccount subclassOf BankAccount highestOrdinal = 2, number = 2051;
	SavingsAccount subclassOf BankAccount highestOrdinal = 2, number = 2061;
	Customer subclassOf Object highestSubId = 1, highestOrdinal = 6, number = 2062;
	GBankingModelSchema subclassOf RootSchemaGlobal transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed, number = 2076;
	SequenceNumber subclassOf Object highestOrdinal = 1, number = 2078;
	SBankingModelSchema subclassOf RootSchemaSession transient, sharedTransientAllowed, transientAllowed, subclassSharedTransientAllowed, subclassTransientAllowed, number = 2080;
	BankAccountByNumber subclassOf MemberKeyDictionary loadFactor = 66, number = 2081;
	ChequeAccountByNumber subclassOf MemberKeyDictionary loadFactor = 66, number = 2082;
	CustomerByLastName subclassOf MemberKeyDictionary loadFactor = 66, number = 2095;
	SavingsAccountByNumber subclassOf MemberKeyDictionary loadFactor = 66, number = 2096;
	CustomerSet subclassOf Set loadFactor = 66, number = 2103;
	CustomerArray subclassOf Array loadFactor = 66, number = 2127;
 
interfaceDefs
membershipDefinitions
	BankAccountByNumber of BankAccount ;
	ChequeAccountByNumber of ChequeAccount ;
	CustomerByLastName of Customer ;
	SavingsAccountByNumber of SavingsAccount ;
	CustomerSet of Customer ;
	CustomerArray of Customer ;
 
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
	BankingModelSchema completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:14:34;
	referenceDefinitions
		myBank:                        Bank  readonly, number = 1, ordinal = 1;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:07:12:08:53;
 
	jadeMethodDefinitions
		initialize() updating, number = 1001;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:07:12:48:14.350;
	)
	Bank completeDefinition
	(
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:11:04.614;
	referenceDefinitions
		allChequeAccounts:             ChequeAccountByNumber   explicitInverse, readonly, subId = 2, number = 4, ordinal = 1;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51;
		allCustomers:                  CustomerByLastName   explicitInverse, readonly, subId = 4, number = 6, ordinal = 2;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51;
		allSavingsAccounts:            SavingsAccountByNumber   explicitInverse, readonly, subId = 3, number = 5, ordinal = 3;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51;
		myBankAcctSeqNum:              SequenceNumber  protected, number = 1, ordinal = 4;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51;
		myCustomerSeqNum:              SequenceNumber  protected, number = 2, ordinal = 5;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51;
 
	jadeMethodDefinitions
		create() updating, number = 1003;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:19:23.965;
		delete() updating, number = 1004;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:33:18.423;
		nextBankAcctNum(): Integer number = 1001;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:16:45.345;
		nextCustomerNum(): Integer number = 1002;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:17:54.446;
	)
	BankAccount completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:07:11:54:35.233;
	attributeDefinitions
		balance:                       Decimal[12,2] readonly, number = 1, ordinal = 1;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:58:24;
		number:                        Integer readonly, number = 2, ordinal = 2;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:37:56.385;
	referenceDefinitions
		myCustomer:                    Customer   explicitEmbeddedInverse, readonly, number = 3, ordinal = 3;
		setModifiedTimeStamp "<unknown>" "" 2001:06:01:12:38:19;
 
	jadeMethodDefinitions
		create() updating, number = 1001;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:47:04.560;
	)
	ChequeAccount completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:58:24;
	attributeDefinitions
		overdraftLimit:                Decimal[12,2] readonly, number = 1, ordinal = 1;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:58:24;
	referenceDefinitions
		myBank:                        Bank   explicitEmbeddedInverse, readonly, number = 2, ordinal = 2;
		setModifiedTimeStamp "<unknown>" "" 2003:02:10:12:42:10;
 
	jadeMethodDefinitions
		setPropertiesOnCreate(
			pBalance: Decimal; 
			pCustomer: Customer; 
			pOverdraft: Decimal) updating, number = 1001;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:12:47:47.610;
	)
	SavingsAccount completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:58:24;
	attributeDefinitions
		interestRate:                  Decimal[3,3] readonly, number = 1, ordinal = 1;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:58:24;
	referenceDefinitions
		myBank:                        Bank   explicitEmbeddedInverse, readonly, number = 2, ordinal = 2;
		setModifiedTimeStamp "<unknown>" "" 2003:02:10:12:43:30;
 
	jadeMethodDefinitions
		setPropertiesOnCreate(
			pBalance: Decimal; 
			pCustomer: Customer; 
			pIntRate: Decimal) updating, number = 1001;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:12:51:48.839;
	)
	Customer completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:16:40;
	attributeDefinitions
		address:                       String[26] readonly, number = 1, ordinal = 1;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:18:54;
		firstNames:                    String[26] readonly, number = 2, ordinal = 2;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:20:50;
		lastName:                      String[16] readonly, number = 3, ordinal = 3;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:22:43;
		number:                        Integer readonly, number = 4, ordinal = 4;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:23:12;
	referenceDefinitions
		allBankAccounts:               BankAccountByNumber   explicitInverse, readonly, subId = 1, number = 5, ordinal = 5;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51;
		myBank:                        Bank   explicitEmbeddedInverse, readonly, number = 6, ordinal = 6;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:15:10:51.434;
 
	jadeMethodDefinitions
		create() updating, number = 1002;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:48:02.463;
		setPropertiesOnCreate(
			pAddress: String; 
			pFirstNames: String; 
			pLastName: String) updating, number = 1001;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:12:52:37.770;
		setPropertiesOnUpdate(
			pAddress: String; 
			pFirstNames: String; 
			pLastName: String) updating, number = 1003;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:11:13:56:35.545;
	)
	Global completeDefinition
	(
	)
	RootSchemaGlobal completeDefinition
	(
	)
	GBankingModelSchema completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:14:36;
	)
	JadeScript completeDefinition
	(
 
	jadeMethodDefinitions
		count_J_Customers() number = 1005;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:07:10:30:08.276;
		createBank() number = 1006;
		setModifiedTimeStamp "cnwta3" "99.0.00" 2018:10:15:16:48:36.357;
		createCustomerWithBankAccounts() number = 1007;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:13:34:11.300;
		createCustomersFromFile() number = 1004;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:12:12:39:17.620;
		testAddTax() number = 1003;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:16:39:18.246;
	)
	SequenceNumber completeDefinition
	(
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:11:09;
	attributeDefinitions
		number:                        Integer protected, number = 1, ordinal = 1;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:11:51;
 
	jadeMethodDefinitions
		next(): Integer updating, number = 1001;
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:13:06.439;
	)
	WebSession completeDefinition
	(
	)
	RootSchemaSession completeDefinition
	(
		setModifiedTimeStamp "<unknown>" "6.1.00" 20031119 2003:12:01:13:54:02.270;
	)
	SBankingModelSchema completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:15:14:36;
	)
	Window completeDefinition
	(
	)
	Control completeDefinition
	(
		setModifiedTimeStamp "cnwrjd1" "9.9.00" 110516 2016:08:04:16:24:58.135;
	)
	Picture completeDefinition
	(
		setModifiedTimeStamp "cnwrjd1" "9.9.00" 110516 2016:08:04:16:27:32.781;
	)
	Form completeDefinition
	(
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
	BankAccountByNumber completeDefinition
	(
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:12:34:37;
	)
	ChequeAccountByNumber completeDefinition
	(
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:11:52:59;
	)
	CustomerByLastName completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:17:02:00;
	)
	SavingsAccountByNumber completeDefinition
	(
		setModifiedTimeStamp "cnwged1" "6.0.12" 2003:02:10:12:03:52;
	)
	Set completeDefinition
	(
	)
	CustomerSet completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:16:48:31;
	)
	List completeDefinition
	(
	)
	Array completeDefinition
	(
	)
	CustomerArray completeDefinition
	(
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:16:49:45;
	)
	Decimal completeDefinition
	(
 
	jadeMethodDefinitions
		addTax(): Decimal number = 1001;
		setModifiedTimeStamp "abc" "6.0.12" 2003:02:05:16:39:33.959;
	)
 
 
memberKeyDefinitions
	BankAccountByNumber completeDefinition
	(
		number;
	)
	ChequeAccountByNumber completeDefinition
	(
		number;
	)
	CustomerByLastName completeDefinition
	(
		lastName;
	)
	SavingsAccountByNumber completeDefinition
	(
		number;
	)
 
inverseDefinitions
	allChequeAccounts of Bank automatic peerOf myBank of ChequeAccount manual;
	allCustomers of Bank automatic peerOf myBank of Customer manual;
	allSavingsAccounts of Bank automatic peerOf myBank of SavingsAccount manual;
	allBankAccounts of Customer automatic peerOf myCustomer of BankAccount manual;
databaseDefinitions
BankingModelSchemaDb
	(
		setModifiedTimeStamp "cnwta3" "6.1.05" 2018:10:15:16:29:27;
	databaseFileDefinitions
		"bank" number=203;
		setModifiedTimeStamp "cnwta3" "6.1.05" 2018:10:15:16:29:27;
	defaultFileDefinition "bank";
	classMapDefinitions
		SBankingModelSchema in "_environ";
		BankingModelSchema in "_usergui";
		GBankingModelSchema in "bank";
		Customer in "bank";
		BankAccount in "bank";
		ChequeAccount in "bank";
		SavingsAccount in "bank";
		CustomerSet in "bank";
		CustomerArray in "bank";
		CustomerByLastName in "bank";
		Bank in "bank";
		SequenceNumber in "bank";
		ChequeAccountByNumber in "bank";
		SavingsAccountByNumber in "bank";
		BankAccountByNumber in "bank";
	)
schemaViewDefinitions
exportedPackageDefinitions
typeSources
	BankingModelSchema (
	jadeMethodSources
initialize
{
initialize() updating;

begin
	self.myBank := Bank.firstInstance();
end;
}

	)
	Bank (
	jadeMethodSources
create
{
create() updating;

begin
	create self.myBankAcctSeqNum;
	create self.myCustomerSeqNum;
end;
}

delete
{
delete() updating;

begin
	delete self.myBankAcctSeqNum;
	delete self.myCustomerSeqNum;
end;
}

nextBankAcctNum
{
nextBankAcctNum() : Integer;

begin
	return self.myBankAcctSeqNum.next();
end;
}

nextCustomerNum
{
nextCustomerNum() : Integer;

begin
	return self.myCustomerSeqNum.next();
end;
}

	)
	BankAccount (
	jadeMethodSources
create
{
create() updating;

begin
	self.number := app.myBank.nextBankAcctNum();
end;
}

	)
	ChequeAccount (
	jadeMethodSources
setPropertiesOnCreate
{
setPropertiesOnCreate(pBalance : Decimal;
					  pCustomer : Customer;
					  pOverdraft : Decimal) updating;
	
begin
	self.balance := pBalance;
	self.overdraftLimit := pOverdraft;
	self.myCustomer := pCustomer;
	self.myBank := app.myBank;
end;
}

	)
	SavingsAccount (
	jadeMethodSources
setPropertiesOnCreate
{
setPropertiesOnCreate(pBalance : Decimal;
					  pCustomer : Customer;
					  pIntRate : Decimal) updating;
	
begin
	self.balance := pBalance;
	self.interestRate := pIntRate;
	self.myCustomer := pCustomer;
	self.myBank := app.myBank;
end;
}

	)
	Customer (
	jadeMethodSources
create
{
create() updating;

begin
	self.number := app.myBank.nextCustomerNum();
end;
}

setPropertiesOnCreate
{
setPropertiesOnCreate(pAddress : String;
					  pFirstNames : String;
					  pLastName : String) updating;
	
begin
	self.address := pAddress;
	self.firstNames := pFirstNames;
	self.lastName := pLastName;
	self.myBank := app.myBank;
end;
}

setPropertiesOnUpdate
{
setPropertiesOnUpdate(pAddress : String;
					  pFirstNames : String;
					  pLastName : String) updating;
	
begin
	self.address := pAddress;
	self.firstNames := pFirstNames;
	if self.lastName <> pLastName then
		self.lastName := pLastName;
	endif;
end;
}

	)
	JadeScript (
	jadeMethodSources
count_J_Customers
{
count_J_Customers();
	
vars
	iter : Iterator;
	dict : CustomerByLastName;
	cust : Customer;
	count : Integer;
begin
	dict := CustomerByLastName.firstInstance();
	iter := dict.createIterator();
	dict.startKeyGeq('J', iter);
	while iter.next(cust) do
		if cust.lastName >= 'K' then
			break;
		endif;
		count := count + 1;
	endwhile;
	write count.String & ' customer last names begin with "J"';
end;
}

createBank
{
createBank();

vars
	bank : Bank;
begin
	beginTransaction;
	create  bank persistent;
	commitTransaction;
end;
}

createCustomerWithBankAccounts
{
createCustomerWithBankAccounts();
	
vars
	customer : Customer;
	chequeAcc : ChequeAccount;
	savingsAcc : SavingsAccount;
begin
	app.initialize();
	
	beginTransaction;
	create customer persistent;
	customer.setPropertiesOnCreate('Wales', 'Tom', 'Jones');
	create chequeAcc persistent;
	chequeAcc.setPropertiesOnCreate (100, customer, 5000);
	create chequeAcc persistent;
	chequeAcc.setPropertiesOnCreate (650, customer, 2000);
	
	create savingsAcc persistent;
	savingsAcc.setPropertiesOnCreate (20000, customer, 0.05);
	create savingsAcc persistent;
	savingsAcc.setPropertiesOnCreate (1550, customer, 0.045);
	commitTransaction;
end;
}

createCustomersFromFile
{
createCustomersFromFile();
	
vars
	file : File;
	str : String;
	cust : Customer;
begin
	app.initialize();
	create file transient;
	file.fileName := "c:\jadecourse\files\data\customers.txt";
	beginTransaction;
	while not file.endOfFile() do
		str := file.readLine();
		create cust persistent;
		cust.setPropertiesOnCreate (str[41:end].trimBlanks(),
									str[16:25].trimBlanks(),
									str[1:15].trimBlanks());
	endwhile;
	commitTransaction;
epilog
	delete file;
end;
}

testAddTax
{
testAddTax();

vars
	d : Decimal[8, 2];
begin
	d := 100;
	write d.addTax();
end;
}

	)
	SequenceNumber (
	jadeMethodSources
next
{
next() : Integer updating;

begin
	self.number := self.number + 1;
	return self.number;
end;
}

	)
	Decimal (
	jadeMethodSources
addTax
{
addTax() : Decimal;

begin
	return self + self * TaxRate;
end;
}

	)
