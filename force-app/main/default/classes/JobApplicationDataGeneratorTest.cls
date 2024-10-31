@isTest
public class JobApplicationDataGeneratorTest {

    @testSetup
    static void setup() {
        // Run the data setup method to create test data
        JobApplicationDataGenerator.runDataSetup();
    }

    @isTest
    static void testCreateCompanies() {
        // Query to validate that 10 accounts were created
        List<Account> accounts = [SELECT Id, Name, BillingCity FROM Account];
        System.assertEquals(10, accounts.size(), 'Expected 10 Account records for companies');
        
        // Check that each Account has a name and BillingCity
        for (Account acc : accounts) {
            System.assertNotEquals(null, acc.Name, 'Account Name should not be null');
            System.assertNotEquals(null, acc.BillingCity, 'BillingCity should not be null');
        }
    }

    @isTest
    static void testCreateContacts() {
        // Query to validate that there are Contact records and each is related to an Account
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact];
        System.assertEquals(10, contacts.size(), 'Expected 10 Contact records related to companies');
        
        // Check that each Contact has an associated AccountId and an Email
        for (Contact contact : contacts) {
            System.assertNotEquals(null, contact.AccountId, 'Contact should have an associated AccountId');
            System.assertNotEquals(null, contact.Email, 'Contact Email should not be null');
        }
    }

    @isTest
    static void testCreateJobApplications() {
        // Query Job_Application__c records to confirm expected records created
        List<Job_Application__c> jobApplications = [SELECT Id, Company_Name__c, Job_Source__c, Job_Position__c, 
                                                    Job_Application_Status__c, JoobleExternalId__c, 
                                                    Primary_Contact__c, URL__c, Work_Location__c, 
                                                    Location__c, Description__c 
                                                    FROM Job_Application__c];
        
        System.assertEquals(40, jobApplications.size(), 'Expected 40 Job_Application__c records');

        // Verify key fields are populated for each job application
        for (Job_Application__c jobApp : jobApplications) {
            System.assertNotEquals(null, jobApp.Company_Name__c, 'Company_Name__c should not be null');
            System.assertNotEquals(null, jobApp.Job_Source__c, 'Job_Source__c should not be null');
            System.assertNotEquals(null, jobApp.Job_Position__c, 'Job_Position__c should not be null');
            System.assertNotEquals(null, jobApp.Job_Application_Status__c, 'Job_Application_Status__c should not be null');
            System.assertNotEquals(null, jobApp.Primary_Contact__c, 'Primary_Contact__c should not be null');
            System.assertNotEquals(null, jobApp.URL__c, 'URL__c should not be null');
            System.assertNotEquals(null, jobApp.Work_Location__c, 'Work_Location__c should not be null');
            System.assertNotEquals(null, jobApp.Location__c, 'Location__c should not be null');
            System.assertNotEquals(null, jobApp.Description__c, 'Description__c should not be null');
        }
    }
}
