@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing virtual class CourseFinderModel {
    @testVisible
    public String Id {get; set;}
    public transient Date StartDate {get; set;}
    private String Reference;
    private String Title;
    private String Summary;
    private String Type;
    private Boolean CouplesAllowed;
    private Boolean WomenOnly;
    private String BranchNumber;
    private Decimal Price;
    private Integer PlacesAvailable;
    private CourseOrganiser CourseOrganiser;
    private Venue Venue;
    private List<Session> Sessions;
    public List<String> HowHeardTexts;

    public CourseFinderModel(Course__c course) {
        this.Id = course.Name;
        this.Reference = course.PSA_Area__c + '/' + course.Name;
        this.Title = 'field is colected';
        this.Summary = 'field is colected';
        this.Type = course.Sub_Type__c;
        this.CouplesAllowed = course.Couples_Allowed__c;
        this.WomenOnly = course.Women_Only__c;
        this.BranchNumber = course.Branch__r.Branch_Number__c;
        this.Price = course.Fee__c;
        this.PlacesAvailable = Integer.valueOf(course.Remaining_Places__c);
        this.CourseOrganiser = new CourseOrganiser(course);
        this.Venue = new Venue(course);
        this.Sessions = collectSessionsToList(course.Sessions__r);
        this.StartDate = course.Start_Date__c;
    }

    private without sharing class CourseOrganiser {
        private String Name;
        private String Email;
        private String Telephone;
        
        private CourseOrganiser (Course__c course) {
            this.Name = course.Branch__r.Enquiries_PSA__r.Name;
            this.Email = course.Branch__r.Enquiries_PSA_Email__c;
            this.Telephone = course.Branch__r.Enquiries_PSA_Phone__c;
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
            this.PostcodeArea = getLeftPartOfPostcode(course.Main_Venue__r.Postcode__c);
            this.Location = course.Main_Venue__r.Location__c;   
        }

        private String getLeftPartOfPostcode(String postcode) {
            return !String.isEmpty(postcode) ? postcode.split(' ')[0] : 'SW1A';
        }
    }
  
    private without sharing class Session {
        private String Session_Date;
        private String Start;
        private String Session_End;
        private Boolean WomenOnly;
        private Boolean Breastfeeding;
        private String Notes;
        
        private Session (Session__c session) {
            this.Session_Date = session.Date__c;
            this.Start = String.valueOf(session.Start__c);
            this.Session_End = String.valueOf(session.End__c); 
            this.WomenOnly = session.Specific_Attendee_Type__c == 'Women Only' ? true : false;  
            this.Breastfeeding = session.Type__c == 'Breastfeeding' ? true : false;  
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