@isTest
public class TestDataFactory {

    // Utility method to create multiple Job Applications with associated Accounts and Contacts
    public static List<Job_Application__c> createJobApplications(Integer count, String initialStatus, Integer contactsPerAccount) {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Job_Application__c> jobApplications = new List<Job_Application__c>();

        // Creating associated Accounts and Contacts
        for (Integer i = 0; i < count; i++) {
            Account acc = new Account(Name = 'Test Account ' + i);
            accounts.add(acc);
        }
        insert accounts;

        for (Account acc : accounts) {
            for (Integer j = 0; j < contactsPerAccount; j++) {
                Contact con = new Contact(
                    FirstName = 'Test', 
                    LastName = 'Contact ' + j + ' for Account ' + acc.Name, 
                    AccountId = acc.Id
                );
                contacts.add(con);
            }  
        }
        insert contacts;

        // Creating Job Applications with initial status
        for (Account acc : accounts) {
            Job_Application__c jobApp = new Job_Application__c(
                Job_Application_Status__c = initialStatus,
                Company_Name__c = acc.Id,
                Primary_Contact__c = null,
                OwnerId = UserInfo.getUserId() // Setting the current user as the owner
            );
            jobApplications.add(jobApp);
        }

        insert jobApplications;
        return jobApplications;
    }

    // Utility method to update a specific field on Job Applications (e.g., change status)
    public static void updateJobApplicationStatus(List<Job_Application__c> jobApplications, String newStatus) {
        for (Job_Application__c app : jobApplications) {
            app.Job_Application_Status__c = newStatus;
        }
        update jobApplications;
    }

    // Utility method for creating a single Job Application
    public static Job_Application__c createSingleJobApplication(String status) {
        Account acc = new Account(Name = 'Single Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for (Integer j = 0; j < 3; j++) { // Change the number here for more or fewer contacts
            Contact con = new Contact(FirstName = 'Single', LastName = 'Test Contact ' + j, AccountId = acc.Id);
            contacts.add(con);
        }
        insert contacts;

        Job_Application__c jobApp = new Job_Application__c(
            Job_Application_Status__c = status,
            Company_Name__c = acc.Id, // Link to the account
            Primary_Contact__c = contacts[0].Id, // Link to the first contact created
            OwnerId = UserInfo.getUserId()
        );
        insert jobApp;

        return jobApp;
    }

    // Utility method for updating a single Job Application's status
    public static void updateSingleJobApplicationStatus(Job_Application__c jobApp, String newStatus) {
        jobApp.Job_Application_Status__c = newStatus;
        update jobApp;
    }
}
