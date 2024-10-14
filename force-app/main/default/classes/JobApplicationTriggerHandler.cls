public with sharing class JobApplicationTriggerHandler extends TriggerHandler {
    private List<Job_Application__c> newJobAppList;
    private Map<Id, Job_Application__c> newJobAppMap;
    private List<Job_Application__c> oldJobAppList;
    private Map<Id, Job_Application__c> oldJobAppMap;
    
    public JobApplicationTriggerHandler() {
        this.newJobAppList = (List<Job_Application__c>) Trigger.new;
        this.newJobAppMap = (Map<Id, Job_Application__c>) Trigger.newMap;
        this.oldJobAppList = (List<Job_Application__c>) Trigger.old;
        this.oldJobAppMap = (Map<Id, Job_Application__c>) Trigger.oldMap;
    }

    public override void afterUpdate() {
        JobApplicationHelper.processJobApplications(newJobAppList, oldJobAppMap); 
    }     
}