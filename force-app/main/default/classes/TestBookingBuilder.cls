@IsTest
public class TestBookingBuilder {

    private Course__c course;
    private String status;
    private Contact primaryContact;
    private Contact partnerContact;
    private Date birthDueDate = System.today().addMonths(4);
    private String firstBaby = 'No';
    private String multipleBirth = 'No';
    private Date reservationExpiryDate;
    private String howHeard;
    private Decimal feeOverride;
    private String feeOverrideReason;
    private String infoForPractitioner = 'Test info';
    private Boolean under18 = false;
    private Boolean insertRecord = true;
    private Boolean ignoreDuplicateRules =  false;


    public TestBookingBuilder withCourse(Course__c course){
        this.course = course;
        return this;
    }

    public TestBookingBuilder withStatus(String status){
        this.status = status;
        return this;
    }

    public TestBookingBuilder withPrimaryContact(Contact contact){
        this.primaryContact = contact;
        return this;
    }

    public TestBookingBuilder withPartnerContact(Contact contact){
        this.partnerContact = contact;
        return this;
    }

    public TestBookingBuilder withBirthDueDate(Date birthDueDate){
        this.birthDueDate = birthDueDate;
        return this;
    }

    public TestBookingBuilder withFirstBaby(String firstBaby){
        this.firstBaby = firstBaby;
        return this;
    }

    public TestBookingBuilder withMultipleBirth(String multipleBirth){
        this.multipleBirth = multipleBirth;
        return this;
    }

    public TestBookingBuilder withBookingExpiryDate(Date expiryDate){
        this.reservationExpiryDate = expiryDate;
        return this;
    }

    public TestBookingBuilder withHowHeard(String howHeard){
        this.howHeard = howHeard;
        return this;
    }

    public TestBookingBuilder withFeeOverride(Decimal feeOverride){
        this.feeOverride = feeOverride;
        return this;
    }

    public TestBookingBuilder withFeeOverrideReason(String feeOverrideReason){
        this.feeOverrideReason = feeOverrideReason;
        return this;
    }

    public TestBookingBuilder withInfoForPractitioner(String infoForPactitioner){
        this.infoForPractitioner = infoForPractitioner;
        return this;
    }

    public TestBookingBuilder withUnder18(Boolean under18){
        this.under18 = under18;
        return this;
    }

    public TestBookingBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public TestBookingBuilder ignoreDuplicateRules(Boolean ignoreDuplicateRules) {
		this.ignoreDuplicateRules = true;
		return this;
	}

    public Booking__c build(){
        Booking__c booking = new Booking__c(
            Course__c = this.course.Id,
            Status__c = this.status,
            Primary_Contact__c = this.primaryContact.Id,
            Partner_Contact__c = this.partnerContact.Id,
            Birth_Due_Date__c = this.birthDueDate,
            First_Baby__c = this.firstBaby,
            Multiple_birth__c = this.multipleBirth,
            Reservation_Expiry_Date__c = this.reservationExpiryDate,
            How_Heard__c = this.howHeard,
            Fee_Override__c = this.feeOverride,
            Fee_Override_Reason__c = this.feeOverrideReason,
            Info_for_Practitioner__c = this.infoForPractitioner,
            Under_18__c = this.under18
        );
        if(ignoreDuplicateRules && insertRecord){
			Database.DMLOptions dmlOption = new Database.DMLOptions();
			dmlOption.DuplicateRuleHeader.AllowSave =  true;
			Database.insert(booking, dmlOption); 
			return booking;
		}
        if(this.insertRecord){
            insert booking;
        }
        return booking;

    }

}
