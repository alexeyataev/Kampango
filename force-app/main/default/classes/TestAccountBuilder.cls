@isTest
public class TestAccountBuilder {

    private String recordTypeId;
    private String name = 'John Smith';
    private String type;
    private String billingPostalCode;
    private String branchNumber = '123';
    private String billingEmail;
    private String accountNumber;
    private String bankSortCode;
    private String bankAccountNumber;
    private String bankAccountName;
    private String capacityPSAemail;
    private String enquiriesPSAemail;
    private String psaArea;
    private Boolean hasContactEmails;
    private Id enquiriesPSA;

    private Boolean insertRecord = false;

    public TestAccountBuilder withRecordType(String recordTypeName){
        hasContactEmails = this.hasRecordTypeContactEmails(recordTypeName);
        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return this;
    }

    public TestAccountBuilder withBillingEmail(String billingEmail) {
        this.billingEmail = billingEmail;
        return this;
    }

    public TestAccountBuilder withName(String name) {
        this.name = name;
        return this;
    }

    public TestAccountBuilder withType(String type) {
        this.type = type;
        return this;
    }

    public TestAccountBuilder withAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
        return this;
    }

    public TestAccountBuilder withBillingPostalCode(String postalCode) {
        this.billingPostalCode = postalCode;
        return this;
    }

    public TestAccountBuilder withBankSortCode(string bankSortCode) {
        this.bankSortCode = bankSortCode;
        return this;
    }

    public TestAccountBuilder withBankAccountNumber(string bankAccountNumber) {
        this.bankAccountNumber = bankAccountNumber;
        return this;
    }

    public TestAccountBuilder withBankAccountName(string bankAccountName) {
        this.bankAccountName = bankAccountName;
        return this;
    }

    public TestAccountBuilder withCapacityPSAemail(String capacityEmail) {
        if (hasContactEmails) {
            this.capacityPSAemail = capacityEmail;
        }
        return this;
    }

    public TestAccountBuilder withEnquiriesPSAemail(String enquiriesEmail) {
        if (hasContactEmails) {
            this.enquiriesPSAemail = enquiriesEmail;
        }
        return this;
    }

    public TestAccountBuilder withBranchNumber(String branchNumber) {
        this.branchNumber = branchNumber;
        return this;
    }

    public TestAccountBuilder withEnquiriesPSA(Id userId) {
        this.enquiriesPSA = userId;
        return this;
    }

    public TestAccountBuilder withPSAarea(String area) {
        this.psaArea = area;
        return this;
    }

    public TestAccountBuilder insertRecord(Boolean insertRecord) {
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
            Billing_Email__c = this.billingEmail,
            Zumzum__Bank_Sort_Code__c = this.bankSortCode,
            Zumzum__Bank_Account_No__c = this.bankAccountNumber,
            Zumzum__Bank_Account_Name__c = this.bankAccountName,
            Enquiries_PSA__c = this.enquiriesPSA,
            Branch_Number__c = this.branchNumber,
            PSA_Area__c = this.psaArea
        );

        if (hasContactEmails) {
            testAccount.Capacity_PSA_Email__c = this.capacityPSAemail;
            testAccount.Enquiries_PSA_Email__c = this.enquiriesPSAemail;
        }

        if(insertRecord) {
            insert testAccount;
        }

        return testAccount;
    }

    // checks if Account with specific recordType has the capacity PSA and enquiries PSA emails
    private Boolean hasRecordTypeContactEmails(String recordTypeName) {
        return recordTypeName == 'Branch';
    }
}
