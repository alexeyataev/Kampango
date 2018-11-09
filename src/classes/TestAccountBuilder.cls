@isTest
public class TestAccountBuilder {

	private String recordTypeId;
	private String name = 'Test Account';
	private String billingPostalCode;
	private Boolean insertRecord = false;

    public TestAccountBuilder WithRecordType(string recordTypeName) {
        
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        return this;
    }
    
    public TestAccountBuilder WithName(string name)
    {
    	this.name = name;
    	
    	return this;
    }
    
    public TestAccountBuilder WithBillingPostalCode(string postalCode)
    {
    	this.billingPostalCode = postalCode;
    	
    	return this;
    }

    public TestAccountBuilder InsertRecord(Boolean insertRecord)
    {
    	this.insertRecord = insertRecord;
    	return this;
    }
    
    public Account Build(){
    	
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