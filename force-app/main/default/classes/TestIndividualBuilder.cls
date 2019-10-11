@IsTest
public class TestIndividualBuilder {

    private Boolean emailOptOut = true;
    private Boolean phoneOptOut = true;
    private Boolean smsOptOut = true;
    private Boolean postOptOut = true;
    private String lastName = 'LastName';
    private String firstName;
    private String salutation;
    private Boolean insertRecord = true;

    public TestIndividualBuilder withLastName(String lastName){
        this.lastName = lastName;
        return this;
    }

    public TestIndividualBuilder withFirstName(String firstName){
        this.firstName = firstName;
        return this;
    }

    public TestIndividualBuilder withSalutation(String salutation){
        this.salutation = salutation;
        return this;
    }

    public TestIndividualBuilder withHasOptedOutEmail(Boolean emailOptOut){
        this.emailOptOut = emailOptOut;
        return this;
    }

    public TestIndividualBuilder withHasOptedOutPost(Boolean postOptOut){
        this.postOptOut = postOptOut;
        return this;
    }

    public TestIndividualBuilder withHasOptedOutSms(Boolean smsOptOut){
        this.smsOptOut = smsOptOut;
        return this;
    }

    public TestIndividualBuilder withHasOptedOutTelephone(Boolean phoneOptOut){
        this.phoneOptOut = phoneOptOut;
        return this;
    }

    public TestIndividualBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public Individual build(){
        Individual individual = new Individual (
            LastName = this.lastName,
            FirstName = this.firstName,
            Salutation = this.salutation,
            Email__c = this.emailOptOut,
            Post__c = this.postOptOut,
            SMS__c = this.smsOptOut,
            Telephone__c = this.phoneOptOut
        );
        if(this.insertRecord){
            insert individual;
        }
        return individual;        
    }


}
