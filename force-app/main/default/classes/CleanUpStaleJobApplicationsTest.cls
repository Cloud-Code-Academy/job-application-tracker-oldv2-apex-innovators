@isTest
private class CleanUpStaleJobApplicationsTest {
    @isTest
    static void testBatchJob() {
        // Create test job applications
        List<Job_Application__c> applications = new List<Job_Application__c>();
        for (Integer i = 0; i < 5; i++) {
            applications.add(new Job_Application__c(
                Job_Application_Status__c = 'Pending', // Change if necessary
                Follow_up_date__c = System.today().addDays(-31) // Stale application
            ));
        }
        insert applications;

        // Start the batch job
        Test.startTest();
        CleanUpStaleJobApplications batchJob = new CleanUpStaleJobApplications();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that the applications were updated
        List<Job_Application__c> updatedApps = [SELECT Id, Job_Application_Status__c, Notes__c FROM Job_Application__c];
        for (Job_Application__c app : updatedApps) {
            System.assertEquals('Closed', app.Job_Application_Status__c, 'The status should be updated to Closed for stale applications.');
            System.assertEquals('Closed by automated process', app.Notes__c, 'Notes should indicate closure by the automated process.');
            System.debug('Updated Application: ' + app.Id + ' Status: ' + app.Job_Application_Status__c);
        }
    }

    @isTest
    static void testScheduler() {
        // Schedule the job
        Test.startTest();
        String jobId = System.schedule('Test Schedule Clean Up', '0 0 0 ? * MON-FRI', new ScheduleCleanUpStaleJobApplications());
        Test.stopTest();

        // Check if the job has been scheduled
        List<CronTrigger> triggers = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assert(!triggers.isEmpty(), 'The job should be scheduled.');
    }
}