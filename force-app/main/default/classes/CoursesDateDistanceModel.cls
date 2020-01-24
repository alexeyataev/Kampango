@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
/** There are upper case for property names because
 ** Class is useed for serialization */
public without sharing class CoursesDateDistanceModel {
    public List<List<Double>> ViewPort {get; set;}
    public Integer LowestRankIncluded {get; set;}
    public Integer SuggestedLowestRank {get; set;}
    public List<CourseFinderModelOrdered> Courses {get; set;}

    public CoursesDateDistanceModel(List<CourseFinderModelOrdered> courses, Integer lowestRankIncluded, Integer radius){
        this.Courses = courses;
        this.LowestRankIncluded = lowestRankIncluded;
        this.SuggestedLowestRank = getSuggestedLowestRank(radius, lowestRankIncluded);
    }

    private static Integer getSuggestedLowestRank(Integer radius, Integer lowestRankIncluded){
        Integer result;

        final Integer RANK_3 = 3;
        final Integer RANK_4 = 4;
        final Integer RANK_5 = 5;

        final Integer RANK_3_MAX_RADIUS = 10;
        final Integer RANK_4_MAX_RADIUS = 20;
        
        if (radius <= RANK_3_MAX_RADIUS) {
            result = RANK_3;
        } else if (radius <= RANK_4_MAX_RADIUS) {
            result = RANK_4;
        } else {
            result = RANK_5;
        }
        
        if (result > lowestRankIncluded) {
            result = lowestRankIncluded;
        }
        
        return result;
    }
}