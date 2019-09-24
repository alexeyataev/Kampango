public without sharing class CourseCreateEnquiryUtility {
    private static final String CONTACT_RECORDTYPE_NAME = 'Contact';

    public static void createEnquiry(String courseNumber, Map<String, String> requestParameters) {
        Boolean isPartnerPresent = requestParameters.containsKey('partner_email') && String.isNotBlank(requestParameters.get('partner_email'));

        if (String.isNotBlank(courseNumber) && !requestParameters.isEmpty()) {
            Booking__c booking = new Booking__c();
            Contact contact;

            contact = new Contact(
                RecordTypeId = getContactRecordTypeByAPIName(CONTACT_RECORDTYPE_NAME),
                Salutation = requestParameters.get('title'),
                FirstName = requestParameters.get('first_name'),
                LastName = requestParameters.get('last_name'),
                Email = requestParameters.get('email'),
                Phone = requestParameters.get('mobile'),
                MailingCity = requestParameters.get('town'),
                MailingPostalCode = requestParameters.get('postcode'),
                MailingCountry = requestParameters.get('county'),
                MailingStreet = requestParameters.get('address_line1') + ' ' + requestParameters.get('address_line2')
            );
            try {
                upsert contact Contact.fields.Email;
            } catch (DmlException ex) {
                System.debug(
                    ex.getTypeName() + ' ' +
                    ex.getStackTraceString() + ' ' +
                    ex.getMessage() + ' ' +
                    ex.getStackTraceString()
                );
            }

            Contact partner;
            if (isPartnerPresent) {
                    partner = new Contact(
                        FirstName = requestParameters.get('partner_first_name'),
                        LastName = requestParameters.get('partner_last_name'),
                        Email = requestParameters.get('partner_email'),
                        RecordTypeId = getContactRecordTypeByAPIName(CONTACT_RECORDTYPE_NAME)
                    );
                    try {
                        upsert partner Contact.fields.Email;
                    } catch (DmlException ex) {
                        System.debug(
                        ex.getTypeName() + ' ' +
                        ex.getStackTraceString() + ' ' +
                        ex.getMessage() + ' ' +
                        ex.getStackTraceString()
                    );
                }
                booking.Partner_Contact__c = partner.Id;
            }
            booking.Primary_Contact__c = contact.Id;
            booking.Birth_Due_Date__c = Date.parse((requestParameters.get('duedate')));
            booking.First_Baby__c = parseParameterToPicklistValue(requestParameters.get('firstbaby'));
            booking.Multiple_Birth__c = parseParameterToPicklistValue(requestParameters.get('twinsexpected'));
            booking.Course__c = courseNumber;
            booking.How_Heard__c = requestParameters.get('hearaboutus');
            booking.Info_for_Practitioner__c = requestParameters.get('additioninfo');
            try {
                insert booking;
            } catch (DmlException ex) {
                System.debug(
                    ex.getTypeName() + ' ' +
                    ex.getStackTraceString() + ' ' +
                    ex.getMessage() + ' ' +
                    ex.getStackTraceString()
                );
            }
        }
    }

    private static Id getContactRecordTypeByAPIName(String recordTypeName) {
        return SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    private static String parseParameterToPicklistValue(String value) {
        return value == '1' ? 'Yes' : 'No';
    }

    public static String getCourseIdFromHeaders(Map<String, String> headers) {
        return headers.get('Referer').substring(headers.get('Referer').lastIndexOf('/') + 1);
    }
}
