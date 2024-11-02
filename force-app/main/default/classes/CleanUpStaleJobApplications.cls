global class CleanUpStaleJobApplications implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to find stale job applications
        return Database.getQueryLocator([
            SELECT Id, Job_Application_Status__c, Follow_up_date__c, Notes__c 
            FROM Job_Application__c 
            WHERE Job_Application_Status__c != 'Closed' 
            AND Job_Application_Status__c != 'Accepted' 
            AND Follow_up_date__c <= :System.today().addDays(-30)
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Job_Application__c> scope) {
        List<Job_Application__c> applicationsToUpdate = new List<Job_Application__c>();
        
        for (Job_Application__c application : scope) {
            application.Job_Application_Status__c = 'Closed';  // Update status to Closed
            application.Notes__c = 'Closed by automated process';  // Update notes
            applicationsToUpdate.add(application);
        }
        
        if (!applicationsToUpdate.isEmpty()) {
            update applicationsToUpdate;  // Perform the update
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('CleanUpStaleJobApplications batch job completed successfully.');
    }
}