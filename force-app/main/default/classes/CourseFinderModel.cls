public with sharing virtual class CourseFinderModel {
    @TestVisible
    private String Id;
    private String Reference;
    private String Title;
    private String Summary;
    private String Type;
    private Boolean CouplesAllowed;
    private Boolean WomenOnly;
    private String BranchNumber;
    private Decimal Price;
    private Integer PlacesAvailable;
    private String Description;
    private CourseOrganiser CourseOrganiser;
    private Venue Venue;
    private List<Session> Sessions;
    public List<String> HowHeardTexts;
    private List<String> BirthingLocations;


    public CourseFinderModel(Course__c course) {
        this.Id = course.Id;
        this.Reference = course.PSA_Area__c + '/' + course.Name;
        this.Title = 'field is colected';
        this.Summary = 'field is colected';
        this.Type = course.Sub_Type__c;
        this.CouplesAllowed = course.Couples_Allowed__c;
        this.WomenOnly = course.Women_Only__c;
        this.BranchNumber = String.valueOf(course.Branch__r.Branch_Key__c);
        this.Price = course.Fee__c;
        this.PlacesAvailable = Integer.valueOf(course.Number_of_places__c);
        this.Description = 'field is deleted';
        this.CourseOrganiser = new CourseOrganiser(course);
        this.Venue = new Venue(course);
        this.Sessions = collectSessionsToList(course.Sessions__r);

    }

    private without sharing class CourseOrganiser {
        private String Name;
        private String Email;
        private String Telephone;
        
        private CourseOrganiser (Course__c course) {
            this.Name = course.Main_Practitioner__r.Name;
            this.Email = course.Main_Practitioner__r.Email;
            this.Telephone = course.Main_Practitioner__r.Phone;   
        }
    }

    private without sharing class Venue {
        private String Name;
        private String Town;
        private String County;
        private String PostcodeArea;
        private Location Location;
        
        private Venue (Course__c course) {
            this.Name = course.Main_Venue__r.Name;
            this.Town = course.Main_Venue__r.Town__c;
            this.County = course.Main_Venue__r.County__c; 
            this.PostcodeArea = course.PSA_Area__c; 
            this.Location = course.Main_Venue__r.Location__c;   
        }
    }
  
    private without sharing class Session {
        private String Session_Date;
        private String Start;
        private String Session_End;
        private Boolean WomenOnly;
        private Boolean Breastfeeding;
        private Boolean Postnatal;
        private String Notes;
        
        private Session (Session__c session) {
            this.Session_Date = session.Name;
            this.Start = String.valueOf(session.Start__c);
            this.Session_End = String.valueOf(session.End__c); 
            this.WomenOnly = WomenOnly;  
            this.Breastfeeding = session.Type__c == 'Breastfeeding' ? true : false;  
            this.Postnatal = true; // Session_Type__c == 'Postnatal' ? true : false; //field is deleted
            this.Notes = 'field is deleted';  
        }
    }

    private List<Session> collectSessionsToList (List<Session__c> sessions) {
        List<Session> sessionsWrap = new List<Session>();

        for (Session__c session : sessions) {
            sessionsWrap.add(new Session(session));
        }

        return sessionsWrap;
    }
}
