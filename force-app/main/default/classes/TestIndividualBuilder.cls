@IsTest
public class TestIndividualBuilder {

    private Boolean emailOptIn = true;
    private Boolean phoneOptIn = true;
    private Boolean smsOptIn = true;
    private Boolean postOptIn = true;
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

    public TestIndividualBuilder withHasOptedInEmail(Boolean emailOptIn){
        this.emailOptIn = emailOptIn;
        return this;
    }

    public TestIndividualBuilder withHasOptedInPost(Boolean postOptIn){
        this.postOptIn = postOptIn;
        return this;
    }

    public TestIndividualBuilder withHasOptedInSms(Boolean smsOptIn){
        this.smsOptIn = smsOptIn;
        return this;
    }

    public TestIndividualBuilder withHasOptedInTelephone(Boolean phoneOptIn){
        this.phoneOptIn = phoneOptIn;
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
            Has_Opted_In_Email__c = this.emailOptIn,
            Has_Opted_In_Post__c = this.postOptIn,
            Has_Opted_In_SMS__c = this.smsOptIn,
            Has_Opted_In_Telephone__c = this.phoneOptIn
        );
        if(this.insertRecord){
            insert individual;
        }
        return individual;        
    }


}