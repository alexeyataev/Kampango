@isTest
public with sharing class TestContactBuilder {
	
	private Id recordTypeId;
	private string firstName = 'Test';
	private string lastName = 'Contact';
	private Account account;
	private Boolean insertRecord = false;

	public TestContactBuilder withRecordType(string recordTypeName) {
        
        recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        return this;
    }

    public TestContactBuilder withAccount(Account a) {
    	
    	this.account = a;
    	
    	return this;
    }
    
    public TestContactBuilder withFirstName(string firstName) {
    	
    	this.firstName = firstName;
    	
    	return this;
    }
    
    public TestContactBuilder withLastName(string lastName) {
    	
    	this.lastName = lastName;
    	
    	return this;
    }

    public TestContactBuilder insertRecord(Boolean insertRecord)
    {
    	this.insertRecord = insertRecord;
    	return this;
    }
    
    public Contact build(){
    	
    	Contact testContact = new Contact(RecordTypeId = this.recordTypeId,
    							FirstName = this.firstName,
    							LastName = this.lastName, AccountId =account.Id );
    	
    	insert testContact;
    	
    	return testContact;
    }
}