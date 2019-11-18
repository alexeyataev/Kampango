@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
/** There are upper case for property names because
 ** Class is useed for serialization */
public without sharing class CoursesDateDistanceModel {
    public List<List<Double>> ViewPort {get; set;}
    public Integer LowestRankIncluded {get; set;}
    public Integer SuggestedLowestRank {get; set;}
    public List<CourseFinderModelOrdered> Courses {get; set;}
}