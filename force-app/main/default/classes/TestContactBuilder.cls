@isTest
public with sharing class TestContactBuilder {
	
	private Id recordTypeId;
	private string firstName = 'John';
	private string lastName = 'Smith';
	private Account account;
	private String careStatus = 'Waiting';
	private String email = 'johnsmith@ncttest.com';
	private String preferredPhone = 'Mobile';
	private String mobilePhone = '123456789';
	private String homePhone = '987654321';
	private Boolean insertRecord = false;
	private Boolean ignoreDuplicateRules = false;
	private String mailingStreet = 'Test street';
	private String mailingCity = 'Test city';
	private String mailingPostalCode = 'Test code';
	private String mailingCountry = 'Test country';
	private String nctNumber;

	public TestContactBuilder withRecordType(string recordTypeName) {
        recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return this;
    }

    public TestContactBuilder withAccount(Account account) {
    	this.account = account;
    	return this;
    }

	public TestContactBuilder withCareStatus(String careStatus) {
    	this.careStatus = careStatus;
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

    public TestContactBuilder withEmail(string email) {
        if (!String.isEmpty(email)) {
            this.email = email;
        }
        return this;
    }

	public TestContactBuilder withPreferredPhone(String preferredPhone){
		this.preferredPhone = preferredPhone;
		return this;
	}

	public TestContactBuilder withMobilePhone(String mobilePhone){
		this.mobilePhone = mobilePhone;
		return this;
	}

	public TestContactBuilder withHomePhone(String homePhone){
		this.homePhone = homePhone;
		return this;
	}

	public TestContactBuilder withMailingStreet(String mailingStreet){
		this.mailingStreet = mailingStreet;
		return this;
	}

	public TestContactBuilder withMailingCity(String mailingCity){
		this.mailingCity = mailingCity;
		return this;
	}

	public TestContactBuilder withMailingCountry(String mailingCountry){
		this.mailingCountry = mailingCountry;
		return this;
	}

	public TestContactBuilder withMailingPostalCode(String mailingPostalCode){
		this.mailingPostalCode = mailingPostalCode;
		return this;
	}

	public TestContactBuilder withNctNumber(String nctNumber){
		this.nctNumber = nctNumber;
		return this;
	}

    public TestContactBuilder insertRecord(Boolean insertRecord){
    	this.insertRecord = insertRecord;
    	return this;
	}
	
	public TestContactBuilder ignoreDuplicateRules(Boolean ignoreDuplicateRules) {
		this.ignoreDuplicateRules = true;
		return this;
	}
    
    public Contact build(){
    	Contact testContact = new Contact(
			RecordTypeId = this.recordTypeId,
			FirstName = this.firstName,
			LastName = this.lastName,
			Care_Status__c = this.careStatus,
			Email = this.email,
			npe01__PreferredPhone__c = this.preferredPhone,
			MobilePhone = this.mobilePhone,
			HomePhone = this.homePhone,
			MailingStreet = this.mailingStreet,
			MailingCity = this.mailingCity,
			MailingCountry = this.mailingCountry,
			MailingPostalCode = this.mailingPostalCode,
			NCT_Number__c = this.nctNumber
		);
		if (account != null) {
			testContact.AccountId = this.account.Id;
		}
		if(ignoreDuplicateRules && insertRecord){
			Database.DMLOptions dmlOption = new Database.DMLOptions();
			dmlOption.DuplicateRuleHeader.AllowSave =  true;
			Database.insert(testContact, dmlOption);
			return testContact;
		}
		if(insertRecord){
			insert testContact;
		}
    	return testContact;
    }
}