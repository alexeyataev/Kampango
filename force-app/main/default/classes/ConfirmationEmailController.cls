public with sharing class ConfirmationEmailController {
    public List<LocationWrapper> locationListWrapper { get; set; }
    public List<SessionWrapper> sessionListWrapper { get; set; }
    public List<PractitionerWrapper> practitionerListWrapper{ get; set; }
    public TypeSessionAndCourseWrapper typeSessionAndCourse { get; set; }
    public Course__c course { get; }
    private static String sessionDayTemplate = 'Session {0}';
    private static String sessionsTemplate = '(session{0} {1})';
    private static final String URL_LINK = Google_Map_Url_Setting__c.getOrgDefaults().Url_Link__c;

    public void setCourse(Course__c course) {
        List<Session__c> sessionList = sessionFilterByStatus(getSessionsList(course.Id));
        locationWithDaysOfSession(sessionList);
        practitionerWithDaysOfSession(sessionList);
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
                        Venue__r.Map_Url__c,
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

    private void practitionerWithDaysOfSession(List<Session__c> sessions){
        Map<Id, List<Integer>>  practitionerIdWithSessionDaysMap = new Map<Id, List<Integer>>();
        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>();
   
        for(Integer i = 0; i < sessions.size(); i++) {
            if(!practitionerIdWithSessionDaysMap.containsKey(sessions[i].Practitioner__c)) {
                practitionerIdWithSessionDaysMap.put(sessions[i].Practitioner__c, new List<Integer>());
            }
            practitionerIdWithSessionDaysMap.get(sessions[i].Practitioner__c).add(i + 1);
            sessionMap.put(sessions[i].Practitioner__c, sessions[i]);
        }

        practitionerListWrapper = new List<PractitionerWrapper>();
        for (Session__c session : sessionMap.values()) {
            practitionerListWrapper.add(new PractitionerWrapper(session, practitionerIdWithSessionDaysMap.get(session.Practitioner__c)));
        }
    }

    private void locationWithDaysOfSession(List<Session__c> sessions){
        Map<Id, List<Integer>> venueIdWithSessionDaysMap = new Map<Id, List<Integer>>();
        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>();

        sessionListWrapper = new List<SessionWrapper>();
        for (Integer i = 0; i < sessions.size(); i++) {

            if (!venueIdWithSessionDaysMap.containsKey(sessions[i].Venue__c)) {
                venueIdWithSessionDaysMap.put(sessions[i].Venue__c, new List<Integer>());
            }
            
            venueIdWithSessionDaysMap.get(sessions[i].Venue__c).add(i + 1);
            sessionMap.put(sessions[i].Venue__c, sessions[i]);
            sessionListWrapper.add(new SessionWrapper(sessions[i], i + 1));
        }

        locationListWrapper = new List<LocationWrapper>();
        for (Session__c session : sessionMap.values()) {
            locationListWrapper.add(new LocationWrapper(session, venueIdWithSessionDaysMap.get(session.Venue__c)));
        }

    }

    private static String getNewFormatSessionTime(Time sessionTime) {
        List<String> listString = String.valueOf(sessionTime).split(':');
        return listString.get(0) + ':' + listString.get(1);
    }

    private static String getNewFormatSessionDate(Date sessionDate) {
        Datetime sessionDatetime = Datetime.newInstance(sessionDate.year(), sessionDate.month(), sessionDate.day());
        return String.valueOf(sessionDatetime.format('EEE dd MMM'));
    }

    // Return  strings format like (sessions 1,2) or (session 1) or (sessions 1, 2, 3 & 4);
    private static String formattingDaysOfSession(List<Integer> sessionDays) {
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
        public String locationMapUrl { get; set; }
        public String sessionDays { get; set; }

        public LocationWrapper(Session__c session, List<Integer> sessionDays) {
            Contact contactHost = getContactHostAddress(session);
            this.locationPostcode      = contactHost != null ? contactHost.MailingAddress.getPostalCode() : session.Venue__r.Postcode__c;
            this.locationStreetAdress  = contactHost != null ? contactHost.MailingAddress.getStreet() : session.Venue__r.Street_Address__c;
            this.locationCountry       = contactHost != null ? contactHost.MailingAddress.getCountry() : session.Venue__r.County__c;
            this.locationTown          = contactHost != null ? contactHost.MailingAddress.getCity() : session.Venue__r.Town__c;
            this.locationName          = contactHost != null ? contactHost.Name : session.Venue__r.Name;
            this.locationMapUrl        = contactHost != null ? String.format(URL_LINK, new List<String>{contactHost.MailingAddress.getPostalCode()}) : session.Venue__r.Map_Url__c;
            this.sessionDays = formattingDaysOfSession(sessionDays);
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
            this.sessionDate = getNewFormatSessionDate(session.Date__c);
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
        this.sessions = formattingDaysOfSession(sessionDays);
        this.preferPhone = session.Practitioner__r.Phone;
        }
    }
}