@isTest
public with sharing class TestCourseAssignmentBuilder {
    private String status = 'Draft';
    private Course__c course;
    private Boolean insertRecord = false;

    public TestCourseAssignmentBuilder withCourse(Course__c course) {

        this.course = course;

        return this;
    }

    public TestCourseAssignmentBuilder withStatus(String status) {

        this.status = status;

        return this;
    }

    public TestCourseAssignmentBuilder insertRecord(Boolean insertRecord) {

        this.insertRecord = insertRecord;

        return this;
    }

    public Course_Assignment__c build(){

        Course_Assignment__c testCourseAssignment = new Course_Assignment__c (
            Course__c = this.course.Id,
            Status__c = this.Status
        );

        if(insertRecord) {
            insert testCourseAssignment;
        }

        return testCourseAssignment;
    }
}