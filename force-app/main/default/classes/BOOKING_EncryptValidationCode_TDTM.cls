@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #99 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class BOOKING_EncryptValidationCode_TDTM extends npsp.TDTM_Runnable {
    private static final String PARENT_COMMUNITY_PROFILE_NAME = 'Parent Community Profile';
    @SuppressWarnings('PMD.ApexCRUDViolation, PMD.ExcessiveParameterList')
    //Incident #100 - https://confluence.nct.org.uk:8443/x/EoSO
    //Incident #101 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            try {
                User parentCommunityUser = [SELECT Id FROM User WHERE Profile.Name =: PARENT_COMMUNITY_PROFILE_NAME];
                List<Booking__c> newBookings = [SELECT Id, Name, Validation_Code__c FROM Booking__c WHERE Id IN : (List<Booking__c>)triggerNew AND Encrypted_Validation_Code__c = null];
                for(Booking__c booking : newBookings) {
                    String encryptedValidationCode = UserEncryptionDecryptionProvider.encrypt(booking.Name + ',' + booking.Validation_Code__c, parentCommunityUser.Id);
                    booking.Encrypted_Validation_Code__c = encryptedValidationCode;
                }
                update newBookings;
            } catch(Exception e) {
                return dmlWrapper;
            }
        }
        return dmlWrapper;
    }
}