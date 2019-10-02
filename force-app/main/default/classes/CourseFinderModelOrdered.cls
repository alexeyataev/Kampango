@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
public class CourseFinderModelOrdered extends CourseFinderModel {
    public Integer Rank {get; set;}
    public Integer Order {get; set;}
    public transient Integer groupRank {get; set;}
    private List<CourseTypeRank> courseTypeRanks;
    
    public CourseFinderModelOrdered(Course__c course, Date birthDueDate) {
        super(course);
        this.courseTypeRanks = createOrderToRank();
        this.Rank = getCourseRank(course, birthDueDate);
    }

    private Integer getCourseRank(Course__c course, Date birthDueDate) {
        Integer numberDays = 0;
        numberDays = course.Type__c == 'Antenatal' ? course.End_Date__c.daysBetween(birthDueDate) : course.Start_Date__c.daysBetween(birthDueDate);

        for (CourseTypeRank courseTypeRank : courseTypeRanks) {
            if (courseTypeRank.courseType == course.Sub_Type__c && isAppropriateRank(courseTypeRank.compareValues, numberDays)) {
                return courseTypeRank.rank;
            }
        }
        return null;
    }

    private Boolean isAppropriateRank (List<CompareValue> compareValues, Integer numberDays) {
        for (CompareValue compareValue : compareValues) {
            if (compareValue.minNumber <= numberDays && compareValue.maxNumber >= numberDays) {
                return true;
            } 
        }
        return false;
    }

    public List<CourseTypeRank> createOrderToRank() {
        List<CourseTypeRank> courseTypeRanks = new List<CourseTypeRank>();

        CourseTypeRank courseTypeRank1 = new CourseTypeRank('NCT Signature Antenatal', 1, new List<CompareValue>{new CompareValue(21, 49)});
        courseTypeRanks.add(courseTypeRank1);
        CourseTypeRank courseTypeRank2 = new CourseTypeRank('NCT Signature Antenatal', 2, new List<CompareValue>{new CompareValue(14, 20), new CompareValue(50, 63)});
        courseTypeRanks.add(courseTypeRank2);
        CourseTypeRank courseTypeRank3 = new CourseTypeRank('NCT Signature Antenatal', 3, new List<CompareValue>{new CompareValue(7, 14), new CompareValue(64, 84)});
        courseTypeRanks.add(courseTypeRank3);
        CourseTypeRank courseTypeRank4 = new CourseTypeRank('NCT Signature Antenatal', 4, new List<CompareValue>{new CompareValue(0, 6)});
        courseTypeRanks.add(courseTypeRank4);
        CourseTypeRank courseTypeRank5 = new CourseTypeRank('NCT Signature Antenatal', 5, new List<CompareValue>{new CompareValue(85, 126)});
        courseTypeRanks.add(courseTypeRank5);
        CourseTypeRank courseTypeRank6 = new CourseTypeRank('NCT Signature Antenatal', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank6);
        CourseTypeRank courseTypeRank7 = new CourseTypeRank('NCT Signature Antenatal', 7, new List<CompareValue>{new CompareValue(126, 1000)});
        courseTypeRanks.add(courseTypeRank7);
        CourseTypeRank courseTypeRank8 = new CourseTypeRank('NCT Essentials Antenatal', 1, new List<CompareValue>{new CompareValue(21, 56)});
        courseTypeRanks.add(courseTypeRank8);
        CourseTypeRank courseTypeRank9 = new CourseTypeRank('NCT Essentials Antenatal', 2, new List<CompareValue>{new CompareValue(14, 20), new CompareValue(50, 63)});
        courseTypeRanks.add(courseTypeRank9);
        CourseTypeRank courseTypeRank10 = new CourseTypeRank('NCT Essentials Antenatal', 3, new List<CompareValue>{new CompareValue(14, 20), new CompareValue(50, 63)});
        courseTypeRanks.add(courseTypeRank10);
        CourseTypeRank courseTypeRank11 = new CourseTypeRank('NCT Essentials Antenatal', 4, new List<CompareValue>{new CompareValue(0, 6)});
        courseTypeRanks.add(courseTypeRank11);
        CourseTypeRank courseTypeRank12 = new CourseTypeRank('NCT Essentials Antenatal', 5, new List<CompareValue>{new CompareValue(85, 126)});
        courseTypeRanks.add(courseTypeRank12);
        CourseTypeRank courseTypeRank13 = new CourseTypeRank('NCT Essentials Antenatal', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank13);
        CourseTypeRank courseTypeRank14 = new CourseTypeRank('NCT Essentials Antenatal', 7, new List<CompareValue>{new CompareValue(126, 1000)});
        courseTypeRanks.add(courseTypeRank14);
        CourseTypeRank courseTypeRank15 = new CourseTypeRank('NCT Antenatal Refresher', 1, new List<CompareValue>{new CompareValue(21, 56)});
        courseTypeRanks.add(courseTypeRank15);
        CourseTypeRank courseTypeRank16 = new CourseTypeRank('NCT Antenatal Refresher', 2, new List<CompareValue>{new CompareValue(14, 20), new CompareValue(57, 84)});
        courseTypeRanks.add(courseTypeRank16);
        CourseTypeRank courseTypeRank17 = new CourseTypeRank('NCT Antenatal Refresher', 3, new List<CompareValue>{new CompareValue(7, 14)});
        courseTypeRanks.add(courseTypeRank17);
        CourseTypeRank courseTypeRank18 = new CourseTypeRank('NCT Antenatal Refresher', 4, new List<CompareValue>{new CompareValue(0, 6)});
        courseTypeRanks.add(courseTypeRank18);
        CourseTypeRank courseTypeRank19 = new CourseTypeRank('NCT Antenatal Refresher', 5, new List<CompareValue>{new CompareValue(85, 126)});
        courseTypeRanks.add(courseTypeRank19);
        CourseTypeRank courseTypeRank20 = new CourseTypeRank('NCT Antenatal Refresher', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank20);
        CourseTypeRank courseTypeRank21 = new CourseTypeRank('NCT Antenatal Refresher', 7, new List<CompareValue>{new CompareValue(126, 1000)});
        courseTypeRanks.add(courseTypeRank21);
        CourseTypeRank courseTypeRank22 = new CourseTypeRank('Twins and Multiples', 1, new List<CompareValue>{new CompareValue(42, 70)});
        courseTypeRanks.add(courseTypeRank22);
        CourseTypeRank courseTypeRank23 = new CourseTypeRank('Twins and Multiples', 2, new List<CompareValue>{new CompareValue(28, 41), new CompareValue(71, 84)});
        courseTypeRanks.add(courseTypeRank23);
        CourseTypeRank courseTypeRank24 = new CourseTypeRank('Twins and Multiples', 3, new List<CompareValue>{new CompareValue(85, 98)});
        courseTypeRanks.add(courseTypeRank24);
        CourseTypeRank courseTypeRank25 = new CourseTypeRank('Twins and Multiples', 4, new List<CompareValue>{new CompareValue(0, 27)});
        courseTypeRanks.add(courseTypeRank25);
        CourseTypeRank courseTypeRank26 = new CourseTypeRank('Twins and Multiples', 5, new List<CompareValue>{new CompareValue(99, 126)});
        courseTypeRanks.add(courseTypeRank26);
        CourseTypeRank courseTypeRank27 = new CourseTypeRank('Twins and Multiples', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank27);
        CourseTypeRank courseTypeRank28 = new CourseTypeRank('Twins and Multiples', 7, new List<CompareValue>{new CompareValue(127, 1000)});
        courseTypeRanks.add(courseTypeRank28);
        CourseTypeRank courseTypeRank29 = new CourseTypeRank('Waterbirth', 1, new List<CompareValue>{new CompareValue(14, 91)});
        courseTypeRanks.add(courseTypeRank29);
        CourseTypeRank courseTypeRank30 = new CourseTypeRank('Waterbirth', 2, new List<CompareValue>{new CompareValue(7, 13)});
        courseTypeRanks.add(courseTypeRank30);
        CourseTypeRank courseTypeRank31 = new CourseTypeRank('Waterbirth', 3, new List<CompareValue>{new CompareValue(0, 6)});
        courseTypeRanks.add(courseTypeRank31);
        CourseTypeRank courseTypeRank32 = new CourseTypeRank('Waterbirth', 4, new List<CompareValue>{new CompareValue(92, 126)});
        courseTypeRanks.add(courseTypeRank32);
        CourseTypeRank courseTypeRank33 = new CourseTypeRank('Waterbirth', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank33);
        CourseTypeRank courseTypeRank34 = new CourseTypeRank('Waterbirth', 7, new List<CompareValue>{new CompareValue(127, 1000)});
        courseTypeRanks.add(courseTypeRank34);
        CourseTypeRank courseTypeRank35 = new CourseTypeRank('Early Days', 1, new List<CompareValue>{new CompareValue(42, 84)});
        courseTypeRanks.add(courseTypeRank35);
        CourseTypeRank courseTypeRank36 = new CourseTypeRank('Early Days', 2, new List<CompareValue>{new CompareValue(85, 126)});
        courseTypeRanks.add(courseTypeRank36);
        CourseTypeRank courseTypeRank37 = new CourseTypeRank('Early Days', 3, new List<CompareValue>{new CompareValue(127, 182), new CompareValue(0, 41)});
        courseTypeRanks.add(courseTypeRank37);
        CourseTypeRank courseTypeRank38 = new CourseTypeRank('Early Days', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank38);
        CourseTypeRank courseTypeRank39 = new CourseTypeRank('Early Days', 7, new List<CompareValue>{new CompareValue(183, 1000)});
        courseTypeRanks.add(courseTypeRank39);
        CourseTypeRank courseTypeRank40 = new CourseTypeRank('Introducing Solids', 1, new List<CompareValue>{new CompareValue(91, 182)});
        courseTypeRanks.add(courseTypeRank40);
        CourseTypeRank courseTypeRank41 = new CourseTypeRank('Introducing Solids', 2, new List<CompareValue>{new CompareValue(56, 90)});
        courseTypeRanks.add(courseTypeRank41);
        CourseTypeRank courseTypeRank42 = new CourseTypeRank('Introducing Solids', 3, new List<CompareValue>{new CompareValue(183, 210)});
        courseTypeRanks.add(courseTypeRank42);
        CourseTypeRank courseTypeRank43 = new CourseTypeRank('Introducing Solids', 7, new List<CompareValue>{new CompareValue(-1000, 55), new CompareValue(210, 1000)});
        courseTypeRanks.add(courseTypeRank43);
        CourseTypeRank courseTypeRank44 = new CourseTypeRank('Baby Massage', 1, new List<CompareValue>{new CompareValue(0, 91)});
        courseTypeRanks.add(courseTypeRank44);
        CourseTypeRank courseTypeRank45 = new CourseTypeRank('Baby Massage', 6, new List<CompareValue>{new CompareValue(-1000, -1)});
        courseTypeRanks.add(courseTypeRank45);
        CourseTypeRank courseTypeRank46 = new CourseTypeRank('Baby Massage', 7, new List<CompareValue>{new CompareValue(92, 1000)});
        courseTypeRanks.add(courseTypeRank46);

        return courseTypeRanks; 
    }
  
    private void calculateGroupRank(){
        groupRank = 2;
    }

    public class CourseTypeRank {
        public String courseType;
        public Integer rank;
        public List<CompareValue> compareValues;

        public CourseTypeRank(String courseType, Integer rank, List<CompareValue> compareValues) {
            this.courseType = courseType;
            this.rank = rank;
            this.compareValues = compareValues;
        }
    }

    public class CompareValue {
        private Integer minNumber;
        private Integer maxNumber;

        public CompareValue(Integer minNumber, Integer maxNumber) {
            this.minNumber = minNumber;
            this.maxNumber = maxNumber;
        }
    }
}