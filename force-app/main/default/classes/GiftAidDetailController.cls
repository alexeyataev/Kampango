public with sharing class GiftAidDetailController {
    private static final String PARENT_PAY = 'parent';
    private static final String PARTNER_PAY = 'partner';

    @AuraEnabled
    public static void createGiftAidDeclaration(String value, Id bookingId) {
        if (value == PARENT_PAY) {
            parentPay(bookingId);
        } else if (value == PARTNER_PAY) {
            partnerPay(bookingId);
        }
    }

    private static void parentPay(Id bookingId) {
        Booking__c booking = [
            SELECT  Primary_Contact__c,
                    First_Name__c,
                    Last_Name__c,
                    Postcode__c,
                    Primary_Contact__r.MailingStreet
            FROM Booking__c
            WHERE ID = :bookingId
        ];

        gaid__Gift_Aid_Declaration__c giftAidDeclaration = new gaid__Gift_Aid_Declaration__c();
        giftAidDeclaration.gaid__Date_Made__c = Date.today();
        giftAidDeclaration.gaid__Active__c = true;
        giftAidDeclaration.gaid__Contact__c = booking.Primary_Contact__c;
        giftAidDeclaration.gaid__FirstName__c = booking.First_Name__c;
        giftAidDeclaration.gaid__LastName__c = booking.Last_Name__c;
        giftAidDeclaration.gaid__Postalcode__c = booking.Postcode__c;
        giftAidDeclaration.gaid__Housename_or_number__c = booking.Primary_Contact__r.MailingStreet;
        giftAidDeclaration.gaid__Acquisition_Method__c = 'Digital';
        giftAidDeclaration.Method__c = 'GiftAid';

        insertGiftAidDeclaration(giftAidDeclaration);
    }

    private static void partnerPay(Id bookingId) {
        Booking__c booking = [
            SELECT  Partner_Contact__c,
                    Primary_Contact__c,
                    First_Name_Partner__c,
                    Last_Name_Partner__c,
                    Postcode__c,
                    Primary_Contact__r.MailingStreet
            FROM Booking__c
            WHERE ID = :bookingId
        ];

        gaid__Gift_Aid_Declaration__c giftAidDeclaration = new gaid__Gift_Aid_Declaration__c();
        giftAidDeclaration.gaid__Date_Made__c = Date.today();
        giftAidDeclaration.gaid__Active__c = true;
        giftAidDeclaration.gaid__Contact__c = booking.Partner_Contact__c;
        giftAidDeclaration.gaid__FirstName__c = booking.First_Name_Partner__c;
        giftAidDeclaration.gaid__LastName__c = booking.Last_Name_Partner__c;
        giftAidDeclaration.gaid__Postalcode__c = booking.Postcode__c;
        giftAidDeclaration.gaid__Housename_or_number__c = booking.Primary_Contact__r.MailingStreet;
        giftAidDeclaration.gaid__Acquisition_Method__c = 'Digital';
        giftAidDeclaration.Method__c = 'GiftAid';
        
        insertGiftAidDeclaration(giftAidDeclaration);
    }

    private static void insertGiftAidDeclaration(gaid__Gift_Aid_Declaration__c giftAidDeclarationObject) {
        try {
            insert giftAidDeclarationObject;
        } catch (DmlException ex) {
           throw new AuraHandledException(ex.getMessage());
        }
    }
}
