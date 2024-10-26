trigger JobApplicationTrigger on Job_Application__c (before insert, after update, after insert) {
    new JobApplicationTriggerHandler().run();
}