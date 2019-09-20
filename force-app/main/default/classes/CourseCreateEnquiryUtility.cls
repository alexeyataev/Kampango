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
            upsert contact Contact.fields.Email;

            Contact partner;
            if (isPartnerPresent) {
                List<Contact> partners = [
                    SELECT Name, FirstName, LastName
                    FROM Contact
                    WHERE Email =: requestParameters.get('partner_email')
                ];
                if (partners.isEmpty()) {
                    partner = new Contact(
                        FirstName = requestParameters.get('partner_first_name'),
                        LastName = requestParameters.get('partner_last_name'),
                        Email = requestParameters.get('partner_email'),
                        RecordTypeId = getContactRecordTypeByAPIName(CONTACT_RECORDTYPE_NAME)
                    );
                    insert partner;
                } else {
                    partner = partners[0];
                }
                booking.Partner_Contact__c = partner.Id;
            }
            booking.Primary_Contact__c = contact.Id;
            booking.Birth_Due_Date__c = Date.parse((requestParameters.get('duedate')));
            booking.First_Baby__c = parseBooleanParameterToPicklistValue(requestParameters.get('firstbaby'));
            booking.Multiple_Birth__c = parseBooleanParameterToPicklistValue(requestParameters.get('twinsexpected'));
            booking.Course__c = courseNumber;
            booking.How_Heard__c = requestParameters.get('hearaboutus');
            booking.Info_for_Practitioner__c = requestParameters.get('additioninfo');
            insert booking;
        }
    }

    private static Id getContactRecordTypeByAPIName(String recordTypeName) {
        return SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    private static String parseBooleanParameterToPicklistValue(String value) {
        return Boolean.valueOf(value) ? 'Yes' : 'No';
    }

    public static String getCourseIdFromHeaders() {
        List<Course__c> availableCourses = [SELECT Id FROM Course__c WHERE Remaining_Places__c > 0];
        if (!availableCourses.isEmpty()) {
            return availableCourses[0].Id;
        } else {
            return null;
        }
    }
}