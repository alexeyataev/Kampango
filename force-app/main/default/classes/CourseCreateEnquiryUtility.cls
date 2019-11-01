public without sharing class CourseCreateEnquiryUtility {
    public static final String RECORDTYPE_NAME = 'Clients';

    public static void createEnquiry(String courseName, Map<String, String> requestParameters) {
        Boolean isPartnerPresent = requestParameters.containsKey('partner_email') && String.isNotBlank(requestParameters.get('partner_email'));
        List<Course__c> courses;
        if (courseName != null) {
            //NOPMD
            //Incident #24 - https://confluence.nct.org.uk:8443/x/EoSO
            courses = [
                SELECT Id, Name
                FROM Course__c
                WHERE Name =: courseName
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
           
        } else {
            throw new CreateEnquiryException(System.Label.CourseAPIcourseNotExists);
        }
        Boolean areParamsNotEmpty = !courses.isEmpty() && !requestParameters.isEmpty();
        if (areParamsNotEmpty) {
            Id courseId = courses[0].Id;
            Booking__c booking = new Booking__c();
            Contact contact;

            contact = new Contact(
                RecordTypeId = getContactRecordTypeByAPIName(RECORDTYPE_NAME),
                Salutation = requestParameters.get('title'),
                FirstName = requestParameters.get('first_name'),
                LastName = requestParameters.get('last_name'),
                Email = requestParameters.get('email'),
                MobilePhone = requestParameters.get('mobile'),
                MailingCity = requestParameters.get('town'),
                MailingPostalCode = requestParameters.get('postcode'),
                MailingCountry = requestParameters.get('county'),
                MailingStreet = requestParameters.get('address_line1') + ' ' + requestParameters.get('address_line2'),
                npe01__PreferredPhone__c = 'Mobile'
            );
            try {
                if (Schema.sObjectType.Contact.isUpdateable() &&
                    Schema.sObjectType.Contact.isCreateable()) {
                    upsert contact Contact.fields.Email;
                }  else {
                    throw new CreateEnquiryException(System.Label.ContactUpdateException);
                }
            } catch (DmlException ex) {
                throw new CreateEnquiryException(ex.getMessage());
            }
            if (isPartnerPresent) {
                Id partnerId = createPartnerContact(requestParameters);
                booking.Partner_Contact__c = partnerId;
            }
            
            booking.Primary_Contact__c = contact.Id;
            booking.Birth_Due_Date__c = Date.parse((requestParameters.get('duedate')));
            booking.First_Baby__c = parseParameterToPicklistValue(requestParameters.get('firstbaby'));
            booking.Multiple_Birth__c = parseParameterToPicklistValue(requestParameters.get('twinsexpected'));
            booking.Course__c = courseId;
            booking.How_Heard__c = requestParameters.get('hearaboutus');
            booking.Info_for_Practitioner__c = requestParameters.get('additioninfo');
            try {
                if (Schema.sObjectType.Booking__c.isCreateable()) {
                    insert booking;
                } else {
                    throw new CreateEnquiryException(System.Label.BookingInsertException);
                }
            } catch (DmlException ex) {
                throw new CreateEnquiryException(ex.getMessage());
            }
        }
    }

    private static Id createPartnerContact(Map<String, String> requestParameters) {
        Contact partner = new Contact(
            FirstName = requestParameters.get('partner_first_name'),
            LastName = requestParameters.get('partner_last_name'),
            Email = requestParameters.get('partner_email'),
            RecordTypeId = getContactRecordTypeByAPIName(RECORDTYPE_NAME)
        );
        try {
            if (Schema.sObjectType.Contact.isUpdateable() &&
                Schema.sObjectType.Contact.isCreateable()) {
                upsert partner Contact.fields.Email;
            } else {
                throw new CreateEnquiryException(System.Label.ContactUpdateException);
            }
        } catch (DmlException ex) {
            throw new CreateEnquiryException(ex.getMessage());
        }
        return partner.Id;
    }

    private static Id getContactRecordTypeByAPIName(String recordTypeName) {
        return SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    private static String parseParameterToPicklistValue(String parameter) {
        return parameter == '1' ? 'Yes' : 'No';
    }
  
    public static String getCourseName(Map<String, String> params) {
        return params.get('courseId').trim();
    }
    public class CreateEnquiryException extends Exception {}
}