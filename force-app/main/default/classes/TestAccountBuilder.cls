@isTest
public class TestAccountBuilder {

	private String recordTypeId;
	private String name = 'Test Account';
	private String billingPostalCode;
	private Boolean insertRecord = false;
	private String type;
	private String accountNumber;
	private String billingEmail;
	private String bankSortCode;
	private String bankAccountNumber;
	private String bankAccountName;

    public TestAccountBuilder withRecordType(string recordTypeName) {
        
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        return this;
    }
    
    public TestAccountBuilder withName(string name)
    {
    	this.name = name;
    	
    	return this;
    }
    
    public TestAccountBuilder withBillingPostalCode(string postalCode)
    {
    	this.billingPostalCode = postalCode;
    	
    	return this;
    }

	public TestAccountBuilder withType(string type)
	{
		this.type = type;

		return this;
	}

	public TestAccountBuilder withAccountNumber(string accountNumber)
	{
		this.accountNumber = accountNumber;

		return this;
	}

	public TestAccountBuilder withBillingEmail(string billingEmail)
	{
		this.billingEmail = billingEmail;

		return this;
	}


	public TestAccountBuilder withBankSortCode(string bankSortCode)
	{
		this.bankSortCode = bankSortCode;

		return this;
	}

	public TestAccountBuilder withBankAccountNumber(string bankAccountNumber)
	{
		this.bankAccountNumber = bankAccountNumber;

		return this;
	}

	public TestAccountBuilder withBankAccountName(string bankAccountName)
	{
		this.bankAccountName = bankAccountName;

		return this;
	}


	public TestAccountBuilder insertRecord(Boolean insertRecord)
    {
    	this.insertRecord = insertRecord;
    	return this;
    }
    
    public Account build(){
    	
    	Account testAccount = new Account(RecordTypeId = this.recordTypeId,
    							Name = this.name,
    							BillingPostalCode = this.billingPostalCode,
								Billing_Email__c = this.billingEmail,
								Type = this.type,
								AccountNumber = this.accountNumber,
								Zumzum__Bank_Sort_Code__c = this.bankSortCode,
								Zumzum__Bank_Account_No__c = this.bankAccountNumber,
								Zumzum__Bank_Account_Name__c = this.bankAccountName);

    	if(insertRecord)
    	{
    		insert testAccount;
    	}
    	
    	return testAccount;
    }
}