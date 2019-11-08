@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #27 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class PractitionerBandFeeHelperTest {

    private static final String PRACTITIONER_LAST_NAME = 'Smith';
    private static final String PRACTITIONER_RECORDTYPE_NAME = 'Practitioner';
    private static final String PRACTITIONER_PROMOTED_BAND ='B';
    private static final Date promotionDate = Date.today() + 7;

    @TestSetup
    private static void setupTestData(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LAST_NAME)
                    .buildPractitionerFeeRateSet()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildSession();
                                                
    }
    @isTest
    private static void PractitionerHasExistingSession_GetsPromoted_SessionAfterPromotionGetsAssignedToNewRate(){
        Contact practitioner = getPractitioner();
        Practitioner_Band__c practitionerOriginalBand = getOriginalPractitionerBand(practitioner);

        Session__c sessionToMoveAfterPromotionDate = [SELECT    Id,
                                                                Practitioner_Fee_Rate__r.Practitioner_Band__c 
                                                            FROM Session__c 
                                                            WHERE Practitioner__c = :practitioner.Id 
                                                            LIMIT 1];

        sessionToMoveAfterPromotionDate.Date__c = promotionDate.addDays(5);
        update sessionToMoveAfterPromotionDate;

        test.startTest();

        practitionerOriginalBand.End_Date__c = promotionDate;
        update practitionerOriginalBand;

        Practitioner_Band__c practitionerNewBand = new Practitioner_Band__c(Start_Date__c = promotionDate,
                                                                                Band__c = PRACTITIONER_PROMOTED_BAND,
                                                                                Practitioner__c = practitioner.Id);

        insert practitionerNewBand;

        List<Practitioner_Band__c> bandsToProcess = new List<Practitioner_Band__c>{practitionerOriginalBand, practitionerNewBand};

        PractitionerBandFeeHelper.updateFeesOnAffectedSessions(bandsToProcess);                                                                            

        test.stopTest();

        Session__c sessionAfterPractitionerPromoted = [SELECT  Id,
                                                                Practitioner_Fee_Rate__r.Practitioner_Band__c 
                                                            FROM Session__c 
                                                            WHERE Practitioner__c = :practitioner.Id 
                                                            LIMIT 1];
        
        System.assertEquals(PRACTITIONER_PROMOTED_BAND, sessionAfterPractitionerPromoted.Practitioner_Fee_Rate__r.Practitioner_Band__c);

    }

    @isTest
    private static void PractitionerHasExistingSession_GetsFutureDatedPromotion_SessionRemainsOnExistingBand(){
        Contact practitioner = getPractitioner();
        Practitioner_Band__c practitionerOriginalBand = getOriginalPractitionerBand(practitioner);

        test.startTest();

        practitionerOriginalBand.End_Date__c = promotionDate;
        update practitionerOriginalBand;

        Practitioner_Band__c practitionerNewBand = new Practitioner_Band__c(Start_Date__c = promotionDate,
                                                                                Band__c = PRACTITIONER_PROMOTED_BAND,
                                                                                Practitioner__c = practitioner.Id);

        insert practitionerNewBand;  

        List<Practitioner_Band__c> bandsToProcess = new List<Practitioner_Band__c>{practitionerOriginalBand, practitionerNewBand};

        PractitionerBandFeeHelper.updateFeesOnAffectedSessions(bandsToProcess);                                                                                  

        test.stopTest();

        Session__c sessionAfterPractitionerPromoted = [SELECT  Id,
                                                                Practitioner_Fee_Rate__r.Practitioner_Band__c 
                                                            FROM Session__c 
                                                            WHERE Practitioner__c = :practitioner.Id 
                                                            LIMIT 1];
        
        System.assertEquals(practitionerOriginalBand.Band__c, sessionAfterPractitionerPromoted.Practitioner_Fee_Rate__r.Practitioner_Band__c);

    }
    @isTest
    private static void PractitionerHasExistingSession_ExistingBandRecordGetsBackEndDated_SessionGetsAssignedToNullRate(){
        Date bandEndDate = Date.today() - 50;
        Contact practitioner = getPractitioner();
        Practitioner_Band__c practitionerOriginalBand = getOriginalPractitionerBand(practitioner);

        test.startTest();

        practitionerOriginalBand.End_Date__c = bandEndDate;
        update practitionerOriginalBand;    

        List<Practitioner_Band__c> bandsToProcess = new List<Practitioner_Band__c>{practitionerOriginalBand};

        PractitionerBandFeeHelper.updateFeesOnAffectedSessions(bandsToProcess);                                                                              

        test.stopTest();

        Session__c sessionAfterPractitionerBandEnded = [SELECT  Id,
                                                                Practitioner_Fee_Rate__c 
                                                            FROM Session__c 
                                                            WHERE Practitioner__c = :practitioner.Id 
                                                            LIMIT 1];
        
        System.assertEquals(null, sessionAfterPractitionerBandEnded.Practitioner_Fee_Rate__c);

    }

    private static Contact getPractitioner(){
        return [SELECT Id
                    FROM Contact
                    WHERE RecordType.DeveloperName = :PRACTITIONER_RECORDTYPE_NAME
                        AND LastName = :PRACTITIONER_LAST_NAME
                    LIMIT 1];
    }

    private static Practitioner_Band__c getOriginalPractitionerBand(Contact practitioner){
        return [SELECT  Id,
                        Band__c,
                        Start_Date__c,
                        End_Date__c,
                        Practitioner__c
                    FROM Practitioner_Band__c
                    WHERE Practitioner__c = :practitioner.Id
                        AND Start_Date__c <= TODAY
                        AND End_Date__c = null
                    LIMIT 1];
    }
}
