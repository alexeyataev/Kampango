public with sharing class ConfirmationEmailController {
    public List<LocationWrapper> locationListWrapper { get; set; }
    public List<SessionWrapper> sessionListWrapper { get; set; }
    public List<PractitionerWrapper> practitionerListWrapper{ get; set; }
    public TypeSessionAndCourseWrapper typeSessionAndCourse { get; set; }
    public Course__c course { get; }
    private static String sessionDayTemplate = 'Session {0}';
    private static String sessionsTemplate = '(session{0} {1})';

    public void setCourse(Course__c course) {
        List<Session__c> sessionList = sessionFilterByStatus(getSessionsList(course.Id));
        getLocationWithSessionNumbers(sessionList);
        getPractitionerWithSessionNumbers(sessionList);
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #11 - https://confluence.nct.org.uk:8443/x/EoSO
    public List<Session__c> getSessionsList(String courseId) {
        return  [
                SELECT  Date__c,
                        Start__c,
                        End__c,
                        Contact_Hours__c,
                        Additional_Information__c,
                        Status__c,
                        Type__c,
                        Parent_Host__c,
                        Parent_Host__r.MailingAddress,
                        Parent_Host__r.Name,
                        Practitioner__c,
                        Practitioner__r.Name,
                        Practitioner__r.Phone,
                        Venue__r.Town__c,
                        Venue__r.Postcode__c,
                        Venue__r.Street_Address__c,
                        Venue__r.County__c,
                        Venue__r.Host__c,
                        Venue__r.Host__r.MailingAddress,
                        Venue__r.Host__r.Name,
                        Venue__c,
                        Venue__r.Name
                FROM Session__c
                WHERE Course__c = :courseId
                WITH SECURITY_ENFORCED
                ORDER BY Date__c, Start__c
        ];
    }

    private void getPractitionerWithSessionNumbers(List<Session__c> sessions){
        Map<Id, List<Integer>>  practitionerIdWithSessionNumbersMap = new Map<Id, List<Integer>>();
        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>();
   
        for(Integer i = 0; i < sessions.size(); i++) {
            if(!practitionerIdWithSessionNumbersMap.containsKey(sessions[i].Practitioner__c)) {
                practitionerIdWithSessionNumbersMap.put(sessions[i].Practitioner__c, new List<Integer>());
            }
            practitionerIdWithSessionNumbersMap.get(sessions[i].Practitioner__c).add(i + 1);
            sessionMap.put(sessions[i].Practitioner__c, sessions[i]);
        }

        practitionerListWrapper = new List<PractitionerWrapper>();
        for (Session__c session : sessionMap.values()) {
            practitionerListWrapper.add(new PractitionerWrapper(session, practitionerIdWithSessionNumbersMap.get(session.Practitioner__c)));
        }
    }

    private void getLocationWithSessionNumbers(List<Session__c> sessions) {
        Map<Id, List<Integer>> venueIdWithSessionNumbersMap = new Map<Id, List<Integer>>();
        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>();

        sessionListWrapper = new List<SessionWrapper>();
        for (Integer i = 0; i < sessions.size(); i++) {

            if (!venueIdWithSessionNumbersMap.containsKey(sessions[i].Venue__c)) {
                venueIdWithSessionNumbersMap.put(sessions[i].Venue__c, new List<Integer>());
            }
            
            venueIdWithSessionNumbersMap.get(sessions[i].Venue__c).add(i + 1);
            sessionMap.put(sessions[i].Venue__c, sessions[i]);
            sessionListWrapper.add(new SessionWrapper(sessions[i], i + 1));
        }

        locationListWrapper = new List<LocationWrapper>();
        for (Session__c session : sessionMap.values()) {
            locationListWrapper.add(new LocationWrapper(session, venueIdWithSessionNumbersMap.get(session.Venue__c)));
        }
    }

    private static String getNewFormatSessionTime(Time sessionTime) {
        Datetime sessionDateTime = Datetime.newInstance(Date.today(), sessionTime);
        return sessionDateTime.format('HH:mm');
    }

    private static String getFormattedSessionDaysList(List<Integer> sessionDays) {
        if (sessionDays.size() >= 3) {
            String days = String.join(sessionDays, ',');
            Integer index = days.lastIndexOf(',');
            return String.format(sessionsTemplate, new List<String> {
                    's', days.replace(days.substring(index - 1), days.substring(index - 1).replace(',', ' & '))
            });

        } else if (sessionDays.size() == 2) {
            return String.format(sessionsTemplate, new List<String> {
                    's', String.join(sessionDays, ',')
            });
        }

        return String.format(sessionsTemplate, new List<String>{
                '', String.join(sessionDays, '')
        });
    }

    private List<Session__c> sessionFilterByStatus(List<Session__c> sessions) {
        List<Session__c> newSessionFilterListByStatus = new List<Session__c>();
        typeSessionAndCourse = new TypeSessionAndCourseWrapper();
        for (Session__c session : sessions) {
            if (session.Status__c != 'Provisional') {
                newSessionFilterListByStatus.add(session);

            } else if (session.Type__c == 'Standard') {
                typeSessionAndCourse.sessionStandard = new SessionProvision();
                typeSessionAndCourse.sessionStandard.provisionTime = String.valueOf(session.Contact_Hours__c);
                typeSessionAndCourse.sessionStandard.sessionProvision = true;

            } else if (session.Type__c == 'Reunion') {
                typeSessionAndCourse.sessionReunion = true;

            } else if (session.Type__c == 'Breastfeeding') {
                typeSessionAndCourse.sessionBreastfeeding = new SessionProvision();
                typeSessionAndCourse.sessionBreastfeeding.provisionTime = String.valueOf(session.Contact_Hours__c);
                typeSessionAndCourse.sessionBreastfeeding.sessionProvision = true;
            }
        }

        return newSessionFilterListByStatus;
    }

    public class LocationWrapper {
        public String locationPostcode { get; set; }
        public String locationStreetAdress { get; set; }
        public String locationCountry { get; set; }
        public String locationName { get; set; }
        public String locationTown { get; set; }
        public String sessionDays { get; set; }

        public LocationWrapper(Session__c session, List<Integer> sessionDays) {
            Contact contactHost = getContactHostAddress(session);
            this.locationPostcode      = contactHost != null ? contactHost.MailingAddress.getPostalCode() : session.Venue__r.Postcode__c;
            this.locationStreetAdress  = contactHost != null ? contactHost.MailingAddress.getStreet() : session.Venue__r.Street_Address__c;
            this.locationCountry       = contactHost != null ? contactHost.MailingAddress.getCountry() : session.Venue__r.County__c;
            this.locationTown          = contactHost != null ? contactHost.MailingAddress.getCity() : session.Venue__r.Town__c;
            this.locationName          = contactHost != null ? contactHost.Name : session.Venue__r.Name;
            this.sessionDays = getFormattedSessionDaysList(sessionDays);
        }
    }

    private static Contact getContactHostAddress(Session__c session) {
        if(session.Parent_Host__c != null) {
            return session.Parent_Host__r;

        } else if(session.Venue__r.Host__c != null) {
            return session.Venue__r.Host__r;
        }

        return null;
    }

    public class SessionWrapper {
        public String sessionDay { get; set; }
        public String sessionDate { get; set; }
        public String sessionStart { get; set; }
        public String sessionEnd { get; set; }
        public String sessionDescription { get; set; }

        public SessionWrapper(Session__c session, Integer sessionDay) {
            this.sessionDay = String.format(sessionDayTemplate, new List<String> {
                    String.valueOf(sessionDay)
            });
            this.sessionDate = String.valueOf(Datetime.newInstance(session.Date__c.year(), session.Date__c.month(), session.Date__c.day()).format('EEE dd MMM'));
            this.sessionStart = getNewFormatSessionTime(session.Start__c);
            this.sessionEnd = getNewFormatSessionTime(session.End__c);
            this.sessionDescription = session.Additional_Information__c;
        }
    }

    private class TypeSessionAndCourseWrapper {
        public Boolean sessionReunion { get; set; }
        public SessionProvision sessionStandard { get; set; }
        public SessionProvision sessionBreastfeeding { get; set; }
    }

    private class SessionProvision {
        public String provisionTime { get; set; }
        public Boolean sessionProvision { get; set; }
    }

    private class PractitionerWrapper{
        public String name { get; set; }
        public String sessions { get; set; }
        public String preferPhone { get; set; }

        PractitionerWrapper(Session__c session, List<Integer> sessionDays){
        this.name = session.Practitioner__r.Name;
        this.sessions = getFormattedSessionDaysList(sessionDays);
        this.preferPhone = session.Practitioner__r.Phone;
        }
    }
}