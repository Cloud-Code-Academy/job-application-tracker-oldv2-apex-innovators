trigger JobApplicationTrigger on Job_Application__c (after update, after insert) {
    new JobApplicationTriggerHandler().run();
}