@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
public class CourseFinderModelOrdered extends CourseFinderModel implements Comparable {
    public static final Integer INAPPROPRIATE_RANK = 8; // correct ranks are 1-7
    public static final Integer INAPPROPRIATE_GROUP = 0; // correct groups are 1 and 2
    public Integer Rank {get; set;}
    public Integer Order {get; set;}
    private transient List<CourseTypeRank> courseTypeRanks;
    private transient Integer groupR {get; set;}
    
    public CourseFinderModelOrdered(Course__c course, Date birthDueDate) {
        super(course);
        this.courseTypeRanks = createOrderToRank();
        updateCourseRankAndGroup(course, birthDueDate);
    }

    private void updateCourseRankAndGroup(Course__c course, Date birthDueDate) {
        Integer numberDays = 0;
        if (birthDueDate != null && course.End_Date__c != null && course.Start_Date__c != null) {
            numberDays = course.Type__c == 'Antenatal' ? course.End_Date__c.daysBetween(birthDueDate) : course.Start_Date__c.daysBetween(birthDueDate);
            numberDays = Math.abs(numberDays);
            for (CourseTypeRank courseTypeRank : courseTypeRanks) {
                Integer groupR = getGroup(courseTypeRank.compareValues, numberDays);
                if (courseTypeRank.courseType == course.Sub_Type__c && groupR > INAPPROPRIATE_GROUP) {
                    this.Rank = courseTypeRank.rank;
                    this.groupR = groupR;
                    return;
                }
            } 
        } 

        this.Rank = INAPPROPRIATE_RANK;
        this.groupR = INAPPROPRIATE_GROUP;
    }

    private Integer getGroup(List<CompareValue> compareValues, Integer numberDays) {
        Integer i = INAPPROPRIATE_GROUP;
        for (CompareValue compareValue : compareValues) {
            if (compareValue.minNumber <= numberDays && compareValue.maxNumber >= numberDays) {
                i++;
                return i;
            } 
        }
        return i;
    }

    private List<CourseTypeRank> createOrderToRank() {
        final String NCT_SIGNATURE_ANTENATAL = 'NCT Signature antenatal course';
        final String NCT_SIGNATURE_ESSENTIALS = 'NCT Essentials antenatal course';
        final String NCT_ANTENATAL_REFRESHER = 'NCT Antenatal refresher course';
        final String TWINS_AND_MULTIPLES = 'NCT Twins and Multiples workshop';
        final String WATERBIRTH = 'NCT Waterbirth workshop';
        final String EARLY_DAYS = 'NCT Early Days course';
        final String INTRODUCING_SOLIDS = 'NCT Introducing Solid Foods workshop';
        final String BABY_MASSAGE = 'NCT Baby Massage course';

        final Integer FIRST_RANK = 1;
        final Integer SECOND_RANK = 2;
        final Integer THIRD_RANK = 3;
        final Integer FOURTH_RANK = 4;
        final Integer FIFTH_RANK = 5;
        final Integer SIXTH_RANK = 6;
        final Integer SEVENTH_RANK = 7;

        final Integer NCT_SIGNATURE_ANTENATAL_FIRST_RANK_MIN = 21; 
        final Integer NCT_SIGNATURE_ANTENATAL_FIRST_RANK_MAX = 49;
        final Integer NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MIN_RANGE_FIRST = 14;
        final Integer NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MAX_RANGE_FIRST = 20;
        final Integer NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MIN_RANGE_SECOND = 50;
        final Integer NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MAX_RANGE_SECOND = 63;
        final Integer NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MIN_RANGE_FIRST = 7; 
        final Integer NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MAX_RANGE_FIRST = 14;
        final Integer NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MIN_RANGE_SECOND = 64; 
        final Integer NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MAX_RANGE_SECOND = 84;
        final Integer NCT_SIGNATURE_ANTENATAL_FOURTH_RANK_MIN = 0; 
        final Integer NCT_SIGNATURE_ANTENATAL_FOURTH_RANK_MAX = 6;
        final Integer NCT_SIGNATURE_ANTENATAL_FIFTH_RANK_MIN = 85; 
        final Integer NCT_SIGNATURE_ANTENATAL_FIFTH_RANK_MAX = 126;
        final Integer NCT_SIGNATURE_ANTENATAL_SIXTH_RANK_MIN = -1000; 
        final Integer NCT_SIGNATURE_ANTENATAL_SIXTH_RANK_MAX = -1;
        final Integer NCT_SIGNATURE_ANTENATAL_SEVENTH_RANK_MIN = 127; 
        final Integer NCT_SIGNATURE_ANTENATAL_SEVENTH_RANK_MAX = 1000;

        final Integer NCT_SIGNATURE_ESSENTIALS_FIRST_RANK_MIN = 21; 
        final Integer NCT_SIGNATURE_ESSENTIALS_FIRST_RANK_MAX = 49;
        final Integer NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MIN_RANGE_FIRST = 14;
        final Integer NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MAX_RANGE_FIRST = 20;
        final Integer NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MIN_RANGE_SECOND = 50;
        final Integer NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MAX_RANGE_SECOND = 63;
        final Integer NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MIN_RANGE_FIRST = 7; 
        final Integer NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MAX_RANGE_FIRST = 14;
        final Integer NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MIN_RANGE_SECOND = 64; 
        final Integer NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MAX_RANGE_SECOND = 84;
        final Integer NCT_SIGNATURE_ESSENTIALS_FOURTH_RANK_MIN = 0; 
        final Integer NCT_SIGNATURE_ESSENTIALS_FOURTH_RANK_MAX = 6;
        final Integer NCT_SIGNATURE_ESSENTIALS_FIFTH_RANK_MIN = 85; 
        final Integer NCT_SIGNATURE_ESSENTIALS_FIFTH_RANK_MAX = 126;
        final Integer NCT_SIGNATURE_ESSENTIALS_SIXTH_RANK_MIN = -1000; 
        final Integer NCT_SIGNATURE_ESSENTIALS_SIXTH_RANK_MAX = -1;
        final Integer NCT_SIGNATURE_ESSENTIALS_SEVENTH_RANK_MIN = 127; 
        final Integer NCT_SIGNATURE_ESSENTIALS_SEVENTH_RANK_MAX = 1000;

        final Integer NCT_ANTENATAL_REFRESHER_FIRST_RANK_MIN = 21; 
        final Integer NCT_ANTENATAL_REFRESHER_FIRST_RANK_MAX = 56;
        final Integer NCT_ANTENATAL_REFRESHER_SECOND_RANK_MIN_RANGE_FIRST = 14;
        final Integer NCT_ANTENATAL_REFRESHER_SECOND_RANK_MAX_RANGE_FIRST = 20;
        final Integer NCT_ANTENATAL_REFRESHER_SECOND_RANK_MIN_RANGE_SECOND = 57;
        final Integer NCT_ANTENATAL_REFRESHER_SECOND_RANK_MAX_RANGE_SECOND = 84;
        final Integer NCT_ANTENATAL_REFRESHER_THIRD_RANK_MIN = 7; 
        final Integer NCT_ANTENATAL_REFRESHER_THIRD_RANK_MAX = 13;
        final Integer NCT_ANTENATAL_REFRESHER_FOURTH_RANK_MIN = 0; 
        final Integer NCT_ANTENATAL_REFRESHER_FOURTH_RANK_MAX = 6;
        final Integer NCT_ANTENATAL_REFRESHER_FIFTH_RANK_MIN = 85; 
        final Integer NCT_ANTENATAL_REFRESHER_FIFTH_RANK_MAX = 126;
        final Integer NCT_ANTENATAL_REFRESHER_SIXTH_RANK_MIN = -1000; 
        final Integer NCT_ANTENATAL_REFRESHER_SIXTH_RANK_MAX = -1;
        final Integer NCT_ANTENATAL_REFRESHER_SEVENTH_RANK_MIN = 127; 
        final Integer NCT_ANTENATAL_REFRESHER_SEVENTH_RANK_MAX = 1000;

        final Integer TWINS_AND_MULTIPLES_FIRST_RANK_MIN = 42; 
        final Integer TWINS_AND_MULTIPLES_FIRST_RANK_MAX = 70;
        final Integer TWINS_AND_MULTIPLES_SECOND_RANK_MIN_RANGE_FIRST = 28;
        final Integer TWINS_AND_MULTIPLES_SECOND_RANK_MAX_RANGE_FIRST = 41;
        final Integer TWINS_AND_MULTIPLES_SECOND_RANK_MIN_RANGE_SECOND = 57;
        final Integer TWINS_AND_MULTIPLES_SECOND_RANK_MAX_RANGE_SECOND = 84;
        final Integer TWINS_AND_MULTIPLES_THIRD_RANK_MIN = 85; 
        final Integer TWINS_AND_MULTIPLES_THIRD_RANK_MAX = 98;
        final Integer TWINS_AND_MULTIPLES_FOURTH_RANK_MIN = 0; 
        final Integer TWINS_AND_MULTIPLES_FOURTH_RANK_MAX = 27;
        final Integer TWINS_AND_MULTIPLES_FIFTH_RANK_MIN = 99; 
        final Integer TWINS_AND_MULTIPLES_FIFTH_RANK_MAX = 126;
        final Integer TWINS_AND_MULTIPLES_SIXTH_RANK_MIN = -1000; 
        final Integer TWINS_AND_MULTIPLES_SIXTH_RANK_MAX = -1;
        final Integer TWINS_AND_MULTIPLES_SEVENTH_RANK_MIN = 127; 
        final Integer TWINS_AND_MULTIPLES_SEVENTH_RANK_MAX = 1000;

        final Integer WATERBIRTH_FIRST_RANK_MIN = 14; 
        final Integer WATERBIRTH_FIRST_RANK_MAX = 91;
        final Integer WATERBIRTH_SECOND_RANK_MIN = 7;
        final Integer WATERBIRTH_SECOND_RANK_MAX = 13;
        final Integer WATERBIRTH_THIRD_RANK_MIN = 0; 
        final Integer WATERBIRTH_THIRD_RANK_MAX = 6;
        final Integer WATERBIRTH_FOURTH_RANK_MIN = 92; 
        final Integer WATERBIRTH_FOURTH_RANK_MAX = 126;
        final Integer WATERBIRTH_SIXTH_RANK_MIN = -1000; 
        final Integer WATERBIRTH_SIXTH_RANK_MAX = -1;
        final Integer WATERBIRTH_SEVENTH_RANK_MIN = 127; 
        final Integer WATERBIRTH_SEVENTH_RANK_MAX = 1000;

        final Integer EARLY_DAYS_FIRST_RANK_MIN = 42; 
        final Integer EARLY_DAYS_FIRST_RANK_MAX = 84;
        final Integer EARLY_DAYS_SECOND_RANK_MIN = 85;
        final Integer EARLY_DAYS_SECOND_RANK_MAX = 126;
        final Integer EARLY_DAYS_THIRD_RANK_MIN_RANGE_FIRST = 0; 
        final Integer EARLY_DAYS_THIRD_RANK_MAX_RANGE_FIRST = 41;
        final Integer EARLY_DAYS_THIRD_RANK_MIN_RANGE_SECOND = 127; 
        final Integer EARLY_DAYS_THIRD_RANK_MAX_RANGE_SECOND = 182;
        final Integer EARLY_DAYS_SIXTH_RANK_MIN = -1000; 
        final Integer EARLY_DAYS_SIXTH_RANK_MAX = -1;
        final Integer EARLY_DAYS_SEVENTH_RANK_MIN = 182; 
        final Integer EARLY_DAYS_SEVENTH_RANK_MAX = 1000;

        final Integer INTRODUCING_SOLIDS_FIRST_RANK_MIN = 91; 
        final Integer INTRODUCING_SOLIDS_FIRST_RANK_MAX = 182;
        final Integer INTRODUCING_SOLIDS_SECOND_RANK_MIN = 56;
        final Integer INTRODUCING_SOLIDS_SECOND_RANK_MAX = 90;
        final Integer INTRODUCING_SOLIDS_THIRD_RANK_MIN = 183; 
        final Integer INTRODUCING_SOLIDS_THIRD_RANK_MAX = 210;
        final Integer INTRODUCING_SOLIDS_SEVENTH_RANK_MIN_RANGE_FIRST = -1000; 
        final Integer INTRODUCING_SOLIDS_SEVENTH_RANK_MAX_RANGE_FIRST = 55;
        final Integer INTRODUCING_SOLIDS_SEVENTH_RANK_MIN_RANGE_SECOND = 211; 
        final Integer INTRODUCING_SOLIDS_SEVENTH_RANK_MAX_RANGE_SECOND = 1000;

        final Integer BABY_MASSAGE_FIRST_RANK_MIN = 42; 
        final Integer BABY_MASSAGE_FIRST_RANK_MAX = 140;
        final Integer BABY_MASSAGE_SECOND_RANK_MIN = 141;
        final Integer BABY_MASSAGE_SECOND_RANK_MAX = 252;
        final Integer BABY_MASSAGE_SIXTH_RANK_MIN = -1000; 
        final Integer BABY_MASSAGE_SIXTH_RANK_MAX = 41;
        final Integer BABY_MASSAGE_SEVENTH_RANK_MIN = 252; 
        final Integer BABY_MASSAGE_SEVENTH_RANK_MAX = 1000;

        List<CourseTypeRank> courseTypeRanks = new List<CourseTypeRank>();
        CourseTypeRank courseTypeRank = null;

        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, FIRST_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_FIRST_RANK_MIN, NCT_SIGNATURE_ANTENATAL_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, SECOND_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MIN_RANGE_FIRST, NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MAX_RANGE_FIRST), 
            new CompareValue(NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MIN_RANGE_SECOND, NCT_SIGNATURE_ANTENATAL_SECOND_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, THIRD_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MIN_RANGE_FIRST, NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MAX_RANGE_FIRST), 
            new CompareValue(NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MIN_RANGE_SECOND, NCT_SIGNATURE_ANTENATAL_THIRD_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, FOURTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_FOURTH_RANK_MIN, NCT_SIGNATURE_ANTENATAL_FOURTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, FIFTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_FIFTH_RANK_MIN, NCT_SIGNATURE_ANTENATAL_FIFTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_SIXTH_RANK_MIN, NCT_SIGNATURE_ANTENATAL_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ANTENATAL, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ANTENATAL_SEVENTH_RANK_MIN, NCT_SIGNATURE_ANTENATAL_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, FIRST_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_FIRST_RANK_MIN, NCT_SIGNATURE_ESSENTIALS_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, SECOND_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MIN_RANGE_FIRST, NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MAX_RANGE_FIRST), 
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MIN_RANGE_SECOND, NCT_SIGNATURE_ESSENTIALS_SECOND_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, THIRD_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MIN_RANGE_FIRST, NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MAX_RANGE_FIRST), 
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MIN_RANGE_SECOND, NCT_SIGNATURE_ESSENTIALS_THIRD_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, FOURTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_FOURTH_RANK_MIN, NCT_SIGNATURE_ESSENTIALS_FOURTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, FIFTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_FIFTH_RANK_MIN, NCT_SIGNATURE_ESSENTIALS_FIFTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_SIXTH_RANK_MIN, NCT_SIGNATURE_ESSENTIALS_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_SIGNATURE_ESSENTIALS, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_SIGNATURE_ESSENTIALS_SEVENTH_RANK_MIN, NCT_SIGNATURE_ESSENTIALS_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, FIRST_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_FIRST_RANK_MIN, NCT_ANTENATAL_REFRESHER_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, SECOND_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_SECOND_RANK_MIN_RANGE_FIRST, NCT_ANTENATAL_REFRESHER_SECOND_RANK_MAX_RANGE_FIRST), 
            new CompareValue(NCT_ANTENATAL_REFRESHER_SECOND_RANK_MIN_RANGE_SECOND, NCT_ANTENATAL_REFRESHER_SECOND_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, THIRD_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_THIRD_RANK_MIN, NCT_ANTENATAL_REFRESHER_THIRD_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, FOURTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_FOURTH_RANK_MIN, NCT_ANTENATAL_REFRESHER_FOURTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, FIFTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_FIFTH_RANK_MIN, NCT_ANTENATAL_REFRESHER_FIFTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_SIXTH_RANK_MIN, NCT_ANTENATAL_REFRESHER_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(NCT_ANTENATAL_REFRESHER, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(NCT_ANTENATAL_REFRESHER_SEVENTH_RANK_MIN, NCT_ANTENATAL_REFRESHER_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, FIRST_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_FIRST_RANK_MIN, TWINS_AND_MULTIPLES_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, SECOND_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_SECOND_RANK_MIN_RANGE_FIRST, TWINS_AND_MULTIPLES_SECOND_RANK_MAX_RANGE_FIRST), 
            new CompareValue(TWINS_AND_MULTIPLES_SECOND_RANK_MIN_RANGE_SECOND, TWINS_AND_MULTIPLES_SECOND_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, THIRD_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_THIRD_RANK_MIN, TWINS_AND_MULTIPLES_THIRD_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, FOURTH_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_FOURTH_RANK_MIN, TWINS_AND_MULTIPLES_FOURTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, FIFTH_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_FIFTH_RANK_MIN, TWINS_AND_MULTIPLES_FIFTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_SIXTH_RANK_MIN, TWINS_AND_MULTIPLES_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(TWINS_AND_MULTIPLES, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(TWINS_AND_MULTIPLES_SEVENTH_RANK_MIN, TWINS_AND_MULTIPLES_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(WATERBIRTH, FIRST_RANK, new List<CompareValue>{
            new CompareValue(WATERBIRTH_FIRST_RANK_MIN, WATERBIRTH_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(WATERBIRTH, SECOND_RANK, new List<CompareValue>{
            new CompareValue(WATERBIRTH_SECOND_RANK_MIN, WATERBIRTH_SECOND_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(WATERBIRTH, THIRD_RANK, new List<CompareValue>{
            new CompareValue(WATERBIRTH_THIRD_RANK_MIN, WATERBIRTH_THIRD_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(WATERBIRTH, FOURTH_RANK, new List<CompareValue>{
            new CompareValue(WATERBIRTH_FOURTH_RANK_MIN, WATERBIRTH_FOURTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(WATERBIRTH, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(WATERBIRTH_SIXTH_RANK_MIN, WATERBIRTH_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(WATERBIRTH, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(WATERBIRTH_SEVENTH_RANK_MIN, WATERBIRTH_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(EARLY_DAYS, FIRST_RANK, new List<CompareValue>{
            new CompareValue(EARLY_DAYS_FIRST_RANK_MIN, EARLY_DAYS_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(EARLY_DAYS, SECOND_RANK, new List<CompareValue>{
            new CompareValue(EARLY_DAYS_SECOND_RANK_MIN, EARLY_DAYS_SECOND_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(EARLY_DAYS, THIRD_RANK, new List<CompareValue>{
            new CompareValue(EARLY_DAYS_THIRD_RANK_MIN_RANGE_FIRST, EARLY_DAYS_THIRD_RANK_MAX_RANGE_FIRST), 
            new CompareValue(EARLY_DAYS_THIRD_RANK_MIN_RANGE_SECOND, EARLY_DAYS_THIRD_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(EARLY_DAYS, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(EARLY_DAYS_SIXTH_RANK_MIN, EARLY_DAYS_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(EARLY_DAYS, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(EARLY_DAYS_SEVENTH_RANK_MIN, EARLY_DAYS_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(INTRODUCING_SOLIDS, FIRST_RANK, new List<CompareValue>{
            new CompareValue(INTRODUCING_SOLIDS_FIRST_RANK_MIN, INTRODUCING_SOLIDS_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(INTRODUCING_SOLIDS, SECOND_RANK, new List<CompareValue>{
            new CompareValue(INTRODUCING_SOLIDS_SECOND_RANK_MIN, INTRODUCING_SOLIDS_SECOND_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(INTRODUCING_SOLIDS, THIRD_RANK, new List<CompareValue>{
            new CompareValue(INTRODUCING_SOLIDS_THIRD_RANK_MIN, INTRODUCING_SOLIDS_THIRD_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(INTRODUCING_SOLIDS, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(INTRODUCING_SOLIDS_SEVENTH_RANK_MIN_RANGE_FIRST, INTRODUCING_SOLIDS_SEVENTH_RANK_MAX_RANGE_FIRST), 
            new CompareValue(INTRODUCING_SOLIDS_SEVENTH_RANK_MIN_RANGE_SECOND, INTRODUCING_SOLIDS_SEVENTH_RANK_MAX_RANGE_SECOND)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(BABY_MASSAGE, FIRST_RANK, new List<CompareValue>{
            new CompareValue(BABY_MASSAGE_FIRST_RANK_MIN, BABY_MASSAGE_FIRST_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(BABY_MASSAGE, SECOND_RANK, new List<CompareValue>{
            new CompareValue(BABY_MASSAGE_SECOND_RANK_MIN, BABY_MASSAGE_SECOND_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(BABY_MASSAGE, SIXTH_RANK, new List<CompareValue>{
            new CompareValue(BABY_MASSAGE_SIXTH_RANK_MIN, BABY_MASSAGE_SIXTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);
        courseTypeRank = new CourseTypeRank(BABY_MASSAGE, SEVENTH_RANK, new List<CompareValue>{
            new CompareValue(BABY_MASSAGE_SEVENTH_RANK_MIN, BABY_MASSAGE_SEVENTH_RANK_MAX)});
        courseTypeRanks.add(courseTypeRank);

        return courseTypeRanks; 
    }

    private class CourseTypeRank {
        private String courseType;
        private Integer rank;
        private List<CompareValue> compareValues;

        private CourseTypeRank(String courseType, Integer rank, List<CompareValue> compareValues) {
            this.courseType = courseType;
            this.rank = rank;
            this.compareValues = compareValues;
        }
    }

    private class CompareValue {
        private Integer minNumber;
        private Integer maxNumber;

        private CompareValue(Integer minNumber, Integer maxNumber) {
            this.minNumber = minNumber;
            this.maxNumber = maxNumber;
        }
    }

    public Integer compareTo(Object compareTo) {
        CourseFinderModelOrdered compareToModel = (CourseFinderModelOrdered) compareTo;
        
        if (this.Rank > compareToModel.Rank){
            return 1;
        } else if (this.Rank < compareToModel.Rank) {
            return -1;
        } else {// comparting the same rank by groupInsideRank
            if (this.groupR > compareToModel.groupR){
                return 1;
            } else if (this.groupR < compareToModel.groupR) {
                return -1;
            } else {//Comparing course numbers
                if (this.Id > compareToModel.Id){
                    return 1;
                } else {
                    return -1;
                }
            }
        }
    }
}