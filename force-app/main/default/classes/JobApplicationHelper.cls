public with sharing class JobApplicationHelper {
    public static void processJobApplications(List<Job_Application__c> jobApplications) {
        List<Task> tasksToInsert = new List<Task>();

        for (Job_Application__c application : jobApplications) {
           switch on application.Job_Application_Status__c {
                when 'Saved' {
                    // Logic for Saved
                }
                when 'Applying' {
                    // Logic for Applying
                }
                when 'Applied' {
                    // Logic for Applied
                }
                when 'Interviewing' {
                    // Logic for Interviewing
                }
                when 'Negotiating' {
                    // Logic for Negotiating
                }
                when 'Accepted' {
                    // Logic for Accepted
                }
                when 'Closed' {
                    // Logic for Closed
                }
                when else {
                    // Other situations not covered
                }
           } 
        }

        TaskManager.createTasksForApplication(tasksToInsert);
    }
}