@isTest
public with sharing class TestContactBuilder {
	
	private Id recordTypeId;
	private string firstName = 'John';
	private string lastName = 'Smith';
	private Account account;
	private String email = 'partnerCommunityUser@ncttest.com';
	private Boolean insertRecord = false;

	public TestContactBuilder withRecordType(string recordTypeName) {
        
        recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        return this;
    }

    public TestContactBuilder withAccount(Account account) {
    	
    	this.account = account;
    	
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
    	Contact testContact = new Contact(
			RecordTypeId = this.recordTypeId,
			FirstName = this.firstName,
			LastName = this.lastName,
			AccountId = this.account.Id,
			Email = this.email
		);

		if(insertRecord)
		{
			insert testContact;
		}

    	return testContact;
    }
}