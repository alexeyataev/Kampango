@isTest
public class TestAccountBuilder {

	private String recordTypeId;
	private String name = 'John Smith';
	private String type;
	private String billingPostalCode;
    private String billingEmail;
	private String accountNumber;
	private Boolean insertRecord = false;

    public TestAccountBuilder withRecordType(String recordTypeName) {
        
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        return this;
    }
    public TestAccountBuilder withBillingEmail(String billingEmail) {

       this.billingEmail = billingEmail;

        return this;
    }
    
    public TestAccountBuilder withName(String name)
    {
    	this.name = name;
    	
    	return this;
    }
    public TestAccountBuilder withType(String type)
    {
        this.type = type;

        return this;
    }

    public TestAccountBuilder withAccountNumber(String accountNumber)
    {
        this.accountNumber = accountNumber;

        return this;
    }
    public TestAccountBuilder withBillingPostalCode(String postalCode)
    {
    	this.billingPostalCode = postalCode;
    	
    	return this;
    }

    public TestAccountBuilder insertRecord(Boolean insertRecord)
    {
    	this.insertRecord = insertRecord;
    	return this;
    }

    public Account build(){
    	
    	Account testAccount = new Account(
            RecordTypeId = this.recordTypeId,
            Name = this.name,
            BillingPostalCode = this.billingPostalCode,
            Type = this.type,
            AccountNumber = this.accountNumber,
            Billing_Email__c = this.billingEmail
        );
    	
    	if(insertRecord)
    	{
    		insert testAccount;
    	}
    	
    	return testAccount;
    }
}