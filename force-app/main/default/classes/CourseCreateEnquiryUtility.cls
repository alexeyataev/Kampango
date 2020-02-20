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

        Database.SaveResult result = Database.insert(contact, false);
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        
        if (!result.isSuccess()) {
            Boolean isDuplicateError = checkForDuplicateError(result.errors);
            if (!isDuplicateError) {
                throw new CreateEnquiryException(JSON.serialize((result.getErrors())));
            }
            List<sObject> duplicates = getDuplicateRecords(result.errors);
            if (duplicates.size() == 1) {
                contact = getContactById(duplicates[0].Id);
            }
            if (duplicates.size() > 1) {
                dmlOption.DuplicateRuleHeader.AllowSave = true;
                Database.SaveResult duplicateInsertResult = Database.insert(contact, dmlOption);
            }
        }
        
        Boolean isPartnerPresent = requestParameters.containsKey('partner_email') 
                                    && String.isNotBlank(requestParameters.get('partner_email'));
        if (isPartnerPresent) {
            Id partnerId = createPartnerContact(requestParameters);
            booking.Partner_Contact__c = partnerId;
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
    
        Database.SaveResult bookingResult = Database.insert(booking, dmlOption);
        if (!bookingResult.isSuccess()) {
            throw new CreateEnquiryException(JSON.serialize(bookingResult.errors));
        }

        updateContactPreferences(contact.Id, requestParameters);
    }

    private static List<sObject> getDuplicateRecords(List<Database.Error> errors) {
        List<sObject> duplicateRecords = new List<sObject>();
        for (Database.Error  error : errors) {
            Database.DuplicateError duplicateError = (Database.DuplicateError)error;
            Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
            Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
            Datacloud.MatchRecord[] matchRecords;

            for (Datacloud.MatchResult match : matchResults) {
                matchRecords = match.getMatchRecords();
                for (Datacloud.MatchRecord matchRecord : matchRecords) {
                    duplicateRecords.add(matchRecord.getRecord());
                }
            }
        }
        return duplicateRecords;
    }

    private static Boolean checkForDuplicateError(List<Database.Error> errors) {
        Boolean result = true;
        for (Database.Error error : errors) {
            if (error.getStatusCode() != StatusCode.DUPLICATES_DETECTED) {
                result = false;
            }
        }
        return result;
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
        Database.SaveResult result = Database.insert(partner, false);
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        
        if (!result.isSuccess()) {
            Boolean isDuplicateError = checkForDuplicateError(result.errors);
            if (!isDuplicateError) {
                throw new CreateEnquiryException(JSON.serialize(result.getErrors()));
            }
            List<sObject> duplicates = getDuplicateRecords(result.errors);
            if (duplicates.size() == 1) {
                partner = getContactById(duplicates[0].Id);
            }
            if (duplicates.size() > 1) {
                dmlOption.DuplicateRuleHeader.AllowSave = true;
                Database.SaveResult duplicateInsertResult = Database.insert(partner, dmlOption);
            }
        }
        updateContactPreferences(partner.Id, requestParameters);
        return partner.Id;
    }

    private static void updateContactPreferences(Id contactId, Map<String, String> requestParameters) {
        Contact contact = getContactById(contactId);
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

    private static Contact getContactById(Id contactId) {
        Contact contact;
        if (!String.isBlank(contactId)) {
            contact = [
                SELECT Id, FirstName, LastName, MailingCity, MailingPostalCode, Email, MailingStreet, Phone, npe01__PreferredPhone__c, IndividualId
                FROM Contact
                WHERE Id =: contactId
                LIMIT 1
            ];
        } else {
            throw new CreateEnquiryException();
        }
        return contact;
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