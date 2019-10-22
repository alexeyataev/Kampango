public class FlowPaymentHandler {
    //@InvocableMethod
    //old invocable method
    public static List<String> getPaymentLink(List<List<String>> params) {
        try {
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            String contactId = params[0][0];
            String feeAmount = params[0][1];
            return new List<String> {paymentServiceProvider.getCardPaymentURL(contactId, feeAmount)};
        } catch(Exception e) {
            return new List<String> {'error'};
        }
    }
    @InvocableMethod
    public static List<String> invokePaymentMethod(List<List<String>> params) {
        List<String> paramsList = params[0];
        // 0 = course or membership
        String paymentType = paramsList[0];
        String bookingId = paramsList[1];
        String paymentMethod = paramsList[2];
        Boolean isRecurring = Boolean.valueOf(paramsList[3]);
        if(paymentType == 'course') {
            return coursePayment(bookingId, paymentMethod, isRecurring);
        } else if(paymentType == 'membership') {
            if((paymentMethod == 'card' && isRecurring == false) || (paymentMethod == 'dd' && isRecurring == true)) {
                String mType = paramsList[4];
                String amount = paramsList[5];
                String txCode = paramsList[6];
                return membershipPayment(bookingId, paymentMethod, isRecurring, mType, amount, txCode);
            }
        }
        return new List<String> {''};
    }
    public static List<String> coursePayment(String bookingId, String paymentMethod, Boolean isRecurring) {
        if(paymentMethod == 'card') {
            system.debug('### Course/Card/Recurring:'+isRecurring);
            // Get booking record
            Booking__c booking = [SELECT Id, Primary_Contact__c, Course__r.Fee__c FROM Booking__c WHERE Id =: bookingId];
            // StepOrange call:
            // paymentServiceProvider.getCardPaymentURL
            String cardPaymentURL = StepOrangeHelper.getCardPaymentURL(booking, isRecurring);
            return new List<String> {cardPaymentURL};
        } else
        if(paymentMethod == 'dd') {
            system.debug('### Course/DD/Recurring:'+isRecurring);
            // Get booking and contact records
            Booking__c booking = [SELECT Primary_Contact__c, Partner_Contact__c FROM Booking__c WHERE Id =: bookingId];
            Contact cont = [SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE Id =: booking.Primary_Contact__c];
            // Care call:
            // 1. SFAddUpdateContactWS.pl
            CareHelper.sendContact(cont);
            // 3. SFAddBankDetailsWS.pl
            CareHelper.sendBankDetails(cont);
            // StepOrange call:
            // TODO Custom Payment method to create Installments and Opps (will be sent to Care via batch or trigger)
            CareHelper.updateContacts();
        }
        return new List<String> {''};
    }
    public static List<String> membershipPayment(String bookingId, String paymentMethod, Boolean isRecurring, String mType, String amount, String txCode) {
        if(paymentMethod == 'card') {
            system.debug('### Membership/Card/Recurring:'+isRecurring);
            // Get booking and contact records
            Booking__c booking = [SELECT Id, Primary_Contact__c, Partner_Contact__c, Course__r.Fee__c FROM Booking__c WHERE Id =: bookingId];
            Contact cont = [SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE Id =: booking.Primary_Contact__c];
            List<Contact> contPartner = [SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE Id =: booking.Partner_Contact__c];
            // Care call:
            // 1. SFAddUpdateContactWS.pl
            String contactNumber = CareHelper.sendContact(cont);
            // 2. SFAddUpdateContactWS.pl for partner
            String contPartnerNumber;
            if(!contPartner.isEmpty()) {
                contPartnerNumber = CareHelper.sendContact(contPartner[0]);
            }
            // 3. SFAddMembershipWS.pl
            String membership = CareHelper.addMembership('CC', null, null, contactNumber, contPartnerNumber, mType, amount, txCode);
            String cardPaymentURL = '';
            if(!membership.contains('"Error"')) {
                // StepOrange call:
                cardPaymentURL = StepOrangeHelper.getCardPaymentURL(booking, isRecurring);
            }
            CareHelper.updateContacts();
            return new List<String> {cardPaymentURL};
        } else if(paymentMethod == 'dd') {
            system.debug('### Membership/DD/Recurring:'+isRecurring);
            // Get booking and contact records
            Booking__c booking = [SELECT Primary_Contact__c, Partner_Contact__c FROM Booking__c WHERE Id =: bookingId];
            Contact cont = [SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE Id =: booking.Primary_Contact__c];
            List<Contact> contPartner = [SELECT Id, FirstName, LastName, NCT_Number__c, Gender__c, MailingPostalCode, Email, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE Id =: booking.Partner_Contact__c];
            // Care call:
            // 1. SFAddUpdateContactWS.pl
            String contactNumber = CareHelper.sendContact(cont);
            // 2. SFAddUpdateContactWS.pl for partner
            String contPartnerNumber;
            if(!contPartner.isEmpty()) {
                contPartnerNumber = CareHelper.sendContact(contPartner[0]);
            }
            // 3. SFAddBankDetailsWS.pl
            String bankDetailNumber = CareHelper.sendBankDetails(cont);
            // 4. SFAddMembershipWS.pl
            if(bankDetailNumber != null) {
                String paymentMethodParam = isRecurring ? 'DDQ' : 'DD';
                CareHelper.addMembership(paymentMethodParam, bankDetailNumber, '3', contactNumber, contPartnerNumber, mType, amount, txCode);
            }
            CareHelper.updateContacts();
        }
        return new List<String> {''};
    }
}