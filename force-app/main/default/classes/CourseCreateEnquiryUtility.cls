public without sharing class CourseCreateEnquiryUtility {
    public static final String RECORDTYPE_NAME = 'Clients';

    public static void createEnquiry(Map<String, String> requestParameters) {
        if (requestParameters.isEmpty() || String.isBlank(requestParameters.get('courseId'))) {
            throw new CreateEnquiryException(System.Label.CourseAPIEnqueryParametersSpecifiedNotCorrectly);
        }

        String courseName = requestParameters.get('courseId').trim();

        Course__c course =  CourseSearchUtility.getCourseById(courseName, true);
        if (course == null) {
            throw new CreateEnquiryException(System.Label.CourseAPIcourseNotExists);
        }
        
        Booking__c booking = new Booking__c();
        Contact contact = new Contact(
            RecordTypeId = getContactRecordTypeByAPIName(RECORDTYPE_NAME),
            Salutation = requestParameters.get('title'),
            FirstName = requestParameters.get('first_name'),
            LastName = requestParameters.get('last_name'),
            Email = requestParameters.get('email'),
            MobilePhone = requestParameters.get('mobile'),
            MailingCity = requestParameters.get('town'),
            MailingPostalCode = requestParameters.get('postcode'),
            MailingState = requestParameters.get('county'), // 'county' is not a 'countRy'
            MailingStreet = requestParameters.get('address_line1') + ' ' + requestParameters.get('address_line2'),
            npe01__PreferredPhone__c = 'Mobile'
        );
        try {
            insert contact;
        } catch (DmlException ex) {
            throw new CreateEnquiryException(ex.getMessage());
        }
        Boolean isPartnerPresent = requestParameters.containsKey('partner_email') 
                                    && String.isNotBlank(requestParameters.get('partner_email'));
        if (isPartnerPresent) {
            Id partnerId = createPartnerContact(requestParameters);
            booking.Partner_Contact__c = partnerId;
        }

        Boolean areEmailsEqual = requestParameters.get('email') == requestParameters.get('partner_email');
        if (areEmailsEqual) {
            throw new CreateEnquiryException(System.Label.CourseAPIEnqueryEmailsAreEqual);
        }
        
        booking.Primary_Contact__c = contact.Id;

        try {
            booking.Birth_Due_Date__c = getDate(requestParameters.get('duedate'));
        } catch (Exception e){
            throw new CreateEnquiryException(e.getMessage());
        }
        
        booking.First_Baby__c = parseParameterToPicklistValue(requestParameters.get('firstbaby'));
        booking.Multiple_Birth__c = parseParameterToPicklistValue(requestParameters.get('twinsexpected'));
        booking.Course__c = course.Id;
        booking.How_Heard__c = requestParameters.get('hearaboutus');
        booking.Info_for_Practitioner__c = requestParameters.get('additioninfo');
        try {
            insert booking;
        } catch (DmlException ex) {
            throw new CreateEnquiryException(ex.getMessage());
        }

        updateContactPreferences(contact.Id, requestParameters);

    }

    private static Date getDate(String dateString){
        Date result;
        try {
            // process date format like '12/27/2009'
            result = Date.parse(dateString);
        } catch (Exception e){
            // process date format like '2009-12-27'
            result = Date.valueOf(dateString);
        }
        return result;
    }

    private static Id createPartnerContact(Map<String, String> requestParameters) {
        Contact partner = new Contact(
            FirstName = requestParameters.get('partner_first_name'),
            LastName = requestParameters.get('partner_last_name'),
            Email = requestParameters.get('partner_email'),
            RecordTypeId = getContactRecordTypeByAPIName(RECORDTYPE_NAME)
        );
        try {
            insert partner;
        } catch (DmlException ex) {
            throw new CreateEnquiryException(ex.getMessage());
        }
        return partner.Id;
    }

    private static void updateContactPreferences(Id contactId, Map<String, String> requestParameters) {
        Contact contact = [
            SELECT IndividualId
            FROM Contact
            WHERE Id =: contactId
            LIMIT 1
        ];

        Individual individual = [
            SELECT Id, Email__c, Post__c, SMS__c, Telephone__c 
            FROM Individual 
            WHERE Id =: contact.IndividualId
            LIMIT 1
        ];
        individual.Email__c = parseParameterToBoolean(requestParameters.get('emailPreference'));
        individual.Post__c = parseParameterToBoolean(requestParameters.get('postPreference'));
        individual.SMS__c = parseParameterToBoolean(requestParameters.get('smstextPreference'));
        individual.Telephone__c = parseParameterToBoolean(requestParameters.get('telephonePreference'));

        try {
            update individual;
        } catch (DmlException ex) {
            throw new CreateEnquiryException(ex.getMessage());
        }
    }

    private static Id getContactRecordTypeByAPIName(String recordTypeName) {
        return SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    private static Boolean parseParameterToBoolean(String parameter) {
        return parameter == '1' ? true : false;
    }

    private static String parseParameterToPicklistValue(String parameter) {
        return parameter == '1' ? 'Yes' : 'No';
    }
  
    public class CreateEnquiryException extends Exception {}
}