public with sharing class GiftAidDetailController {
    //GAD = Gift Aid Declaration;
    private static final String INDIVIDUAL_GAD_DECLARATION = 'individual';
    private static final String JOINT_GAD_DECLARATION = 'joint';
    private static final String ACQUISITION_METHOD = 'Digital';
    private static final String METHOD = 'GiftAid';

    @InvocableMethod
    public static void createGiftAidDeclaration(List<List<String>> flowParams) {
        String bookingId = flowParams[0][0];
        String giftAidDeclarationValue = flowParams[0][1];

        if (giftAidDeclarationValue == INDIVIDUAL_GAD_DECLARATION) {
            addIndividualDeclaration(bookingId);
        } else if (giftAidDeclarationValue == JOINT_GAD_DECLARATION) {
            addJointDeclaration(bookingId);
        }
    }

    private static void addIndividualDeclaration(Id bookingId) {
        Booking__c booking = [
            SELECT  Primary_Contact__c,
                    First_Name__c,
                    Last_Name__c,
                    Postcode__c,
                    Primary_Contact__r.MailingStreet
            FROM Booking__c
            WHERE ID = :bookingId
        ];

        List<gaid__Gift_Aid_Declaration__c> individualGiftAidDeclarationList = new List<gaid__Gift_Aid_Declaration__c> {
            new gaid__Gift_Aid_Declaration__c(
                gaid__Date_Made__c = Date.today(),
                gaid__Active__c = true,
                gaid__Contact__c = booking.Primary_Contact__c,
                gaid__FirstName__c = booking.First_Name__c,
                gaid__LastName__c = booking.Last_Name__c,
                gaid__Postalcode__c = booking.Postcode__c,
                gaid__Housename_or_number__c = booking.Primary_Contact__r.MailingStreet,
                gaid__Acquisition_Method__c = ACQUISITION_METHOD,
                Method__c = METHOD
            )
        };

        insertGiftAidDeclaration(individualGiftAidDeclarationList);
    }

    private static void addJointDeclaration(Id bookingId) {
        Booking__c booking = [
            SELECT  Partner_Contact__c,
                    Primary_Contact__c,
                    First_Name__c,
                    Last_Name__c,
                    First_Name_Partner__c,
                    Last_Name_Partner__c,
                    Postcode__c,
                    Primary_Contact__r.MailingStreet
            FROM Booking__c
            WHERE ID = :bookingId
        ];

        List<gaid__Gift_Aid_Declaration__c> jointGiftAidDeclarationList = new List<gaid__Gift_Aid_Declaration__c> {
            new gaid__Gift_Aid_Declaration__c (
                gaid__Date_Made__c = Date.today(),
                gaid__Active__c = true,
                gaid__Contact__c = booking.Primary_Contact__c,
                gaid__FirstName__c = booking.First_Name__c,
                gaid__LastName__c = booking.Last_Name__c,
                gaid__Postalcode__c = booking.Postcode__c,
                gaid__Housename_or_number__c = booking.Primary_Contact__r.MailingStreet,
                gaid__Acquisition_Method__c = ACQUISITION_METHOD,
                Method__c = METHOD
            ),
            new gaid__Gift_Aid_Declaration__c (
                gaid__Date_Made__c = Date.today(),
                gaid__Active__c = true,
                gaid__Contact__c = booking.Partner_Contact__c,
                gaid__FirstName__c = booking.First_Name_Partner__c,
                gaid__LastName__c = booking.Last_Name_Partner__c,
                gaid__Postalcode__c = booking.Postcode__c,
                gaid__Housename_or_number__c = booking.Primary_Contact__r.MailingStreet,
                gaid__Acquisition_Method__c = ACQUISITION_METHOD,
                Method__c = METHOD
            )
        };
        
        insertGiftAidDeclaration(jointGiftAidDeclarationList);
    }

    private static void insertGiftAidDeclaration(List<gaid__Gift_Aid_Declaration__c> giftAidDeclarationObject) {
        try {
            insert giftAidDeclarationObject;
        } catch (DmlException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}