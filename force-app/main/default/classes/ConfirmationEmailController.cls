public with sharing class ConfirmationEmailController {
    public List<LocationWrapper> locationListWrapper { get; set; }
    public List<SessionWrapper> sessionListWrapper { get; set; }
    public List<PractitionerWrapper> practitionerListWrapper{ get; set; }
    public Course__c course { get; }
    public Boolean courseHasProvisionalReunion { get; set; }
    private static String sessionDayTemplate = 'Session {0}';
    private static String sessionsTemplate = '(session{0} {1})';

    public void setCourse(Course__c course) {
        List<Session__c> sessionList = getListConfirmedSessions(getSessionsList(course.Id));
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
                        Location_Postcode__c,
                        Location_Map_Url__c,
                        Location_Street__c,
                        Location_County__c,
                        Location_Town__c,
                        Location_Name__c,
                        Location_Id__c,
                        Practitioner__c,
                        Practitioner__r.Name,
                        Practitioner__r.Phone
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
            if (String.isNotBlank(sessions[i].Location_Id__c)) {
                if (!venueIdWithSessionNumbersMap.containsKey(sessions[i].Location_Id__c)) {
                    venueIdWithSessionNumbersMap.put(sessions[i].Location_Id__c, new List<Integer>());
                }

                venueIdWithSessionNumbersMap.get(sessions[i].Location_Id__c).add(i + 1);
                sessionMap.put(sessions[i].Location_Id__c, sessions[i]);
             }
             sessionListWrapper.add(new SessionWrapper(sessions[i], i + 1));
        }

        locationListWrapper = new List<LocationWrapper>();
        for (Session__c session : sessionMap.values()) {
            locationListWrapper.add(new LocationWrapper(session, venueIdWithSessionNumbersMap.get(session.Location_Id__c)));
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

    private List<Session__c> getListConfirmedSessions(List<Session__c> sessions) {
        List<Session__c> listConfirmedSessions = new List<Session__c>();

        for (Session__c session : sessions) {
            if (session.Status__c == 'Confirmed') {
                listConfirmedSessions.add(session);

            } else if (session.Type__c == 'Reunion') {
                courseHasProvisionalReunion = true;
            }
        }

        return listConfirmedSessions;
    }

    public class LocationWrapper {
        public Session__c locationOfSession {get; set;}
        public String sessionDays { get; set; }

        public LocationWrapper(Session__c session, List<Integer> sessionDays) {
            this.locationOfSession = session;
            this.sessionDays = getFormattedSessionDaysList(sessionDays);
        }
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