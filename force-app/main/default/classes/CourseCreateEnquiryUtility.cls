public with sharing class CourseCreateEnquiryUtility {

    public static void createEnquiry(String courseNumber, Map<String, String> requestParameters) {

        Boolean isPartnerPresent = requestParameters.containsKey('partner_email') && String.isNotBlank(requestParameters.get('partner_email'));

        if (String.isNotBlank(courseNumber) && !requestParameters.isEmpty()) {

            Booking__c booking = new Booking__c();
            Contact contact;
            Contact partner;

            List<Contact> contacts = [
                SELECT Salutation, FirstName, LastName, Email, MobilePhone, MailingAddress
                FROM Contact
                WHERE Email =: requestParameters.get('email')
                LIMIT 1
            ];

            if (contacts.isEmpty()) {
                contact = new Contact(
                    RecordTypeId = '0124E000000E44A',   //Contact record type
                    Salutation = requestParameters.get('title'),
                    FirstName = requestParameters.get('first_name'),
                    LastName = requestParameters.get('last_name'),
                    Email = requestParameters.get('email'),
                    Phone = requestParameters.get('mobile'),
                    MailingCity = requestParameters.get('town'),
                    MailingPostalCode = requestParameters.get('postcode'),
                    MailingCountry = requestParameters.get('county'),
                    MailingStreet = requestParameters.get('adress_line1') + requestParameters.get('address_line2')
                );
                System.debug(contact);
                insert contact;
            } else {
                contact = contacts[0];
            }

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
                        Email = requestParameters.get('partner_email')
                    );
                    insert partner;
                } else {
                    partner = contacts[0];
                }
                booking.Partner_Contact__c = partner.Id;
            }

            booking.Primary_Contact__c = contact.Id;
            booking.Birth_Due_Date__c = Date.parse((requestParameters.get('duedate')));
    
            booking.First_Baby__c = parseBooleanParameterToPicklistValue(requestParameters.get('firstbaby'));
            booking.Multiple_Birth__c = parseBooleanParameterToPicklistValue(requestParameters.get('twinsexpected'));
            booking.Course__c = courseNumber;
            booking.How_Heard__c = requestParameters.get('hearaboutus');

            insert booking;
        }
        
    }

    private static String parseBooleanParameterToPicklistValue(String value) {
        return Boolean.valueOf(value) ? 'Yes' : 'No';
    }

    public static String getCourseIdFromHeaders() {
        // String refererUrl = requestHeaders.get('Referer');
        // return refererUrl.substring(refererUrl.lastIndexOf('/') + 1);

        List<Course__c> availableCourses = [SELECT Id FROM Course__c WHERE Remaining_Places__c > 0];
        return availableCourses[0].Id;
    }
}
