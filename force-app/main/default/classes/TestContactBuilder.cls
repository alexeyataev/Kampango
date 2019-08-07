@isTest
public with sharing class TestContactBuilder {
	
	private Id recordTypeId;
	private string firstName = 'Test';
	private string lastName = 'Contact';
	private Account account;
	private Boolean insertRecord = false;

	public TestContactBuilder() {}

	public TestContactBuilder WithRecordType(string recordTypeName) {
        
        recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        return this;
    }

    public TestContactBuilder WithAccount(Account a) {
    	
    	this.account = a;
    	
    	return this;
    }
    
    public TestContactBuilder WithFirstName(string firstName) {
    	
    	this.firstName = firstName;
    	
    	return this;
    }
    
    public TestContactBuilder WithLastName(string lastName) {
    	
    	this.lastName = lastName;
    	
    	return this;
    }

    public TestContactBuilder InsertRecord(Boolean insertRecord)
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