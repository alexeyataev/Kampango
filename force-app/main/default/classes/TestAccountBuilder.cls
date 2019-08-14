@isTest
public class TestAccountBuilder {

	private String recordTypeId;
	private String name = 'Test Account';
	private String billingPostalCode;
	private Boolean insertRecord = false;

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

    public TestAccountBuilder insertRecord(Boolean insertRecord)
    {
    	this.insertRecord = insertRecord;
    	return this;
    }
    
    public Account build(){
    	
    	Account testAccount = new Account(RecordTypeId = this.recordTypeId,
    							Name = this.name,
    							BillingPostalCode = this.billingPostalCode);
    	
    	if(insertRecord)
    	{
    		insert testAccount;
    	}
    	
    	return testAccount;
    }
}