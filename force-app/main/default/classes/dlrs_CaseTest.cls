@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #136 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_CaseTest
{
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String HOST_LASTNAME_TWO = 'Brown';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final Map<String, String> CASE_TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'Case_CasesInProgress_TDTM',
        'className' => 'Case_CasesInProgress_TDTM',
        'objectAPIName' => 'Case',
        'triggerActions' => 'AfterInsert;AfterUpdate',
        'isActive' => 'true',
        'loadOrder' => '1',
        'isAsynchronous' => 'false'
    };
    @testSetup
    static void testSetup() {
        TestDataFactory.createTriggerSystemHandlerRecord(CASE_TRIGGER_PARAMS);
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME_TWO, HOST_EMAIL_ADDRESS)
                    .buildBooking('Enquiry');
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        List<Case> caseList = new List<Case>();
        Case case1 = new Case();
        case1.Status = 'New';
        case1.Booking__c = booking.Id;
        caseList.add(case1);
        Case case2 = new Case();
        case2.Status = 'In Progress';
        case2.Booking__c = booking.Id;
        caseList.add(case2);
        Case case3 = new Case();
        case3.Status = 'Closed';
        case3.Booking__c = booking.Id;
        caseList.add(case3);
        insert caseList;
    }
    @IsTest
    private static void testTrigger()
    {
        Test.startTest();
        Booking__c booking = [SELECT Id, CasesInProgress__c FROM Booking__c LIMIT 1];
        System.assertEquals(booking.CasesInProgress__c, 2);
        Test.stopTest();
    }
}