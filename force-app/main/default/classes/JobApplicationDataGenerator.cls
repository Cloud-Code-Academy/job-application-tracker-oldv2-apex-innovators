public class JobApplicationDataGenerator {

    // Method to create sample Account records as companies
    public static List<Account> createCompanies() {
        List<Account> companies = new List<Account>();

        // Define company names and locations
        List<String> companyNames = new List<String>{'Accenture', 'Capgemini', 'Deloitte', 'PwC', 'IBM', 'KPMG', 'Cognizant', 'Infosys', 'TCS', 'Salesforce'};
        List<String> locations = new List<String>{'Austin, TX', 'San Francisco, CA', 'New York, NY', 'Chicago, IL', 'Seattle, WA'};

        // Create Account records with these names and random locations
        for (String name : companyNames) {
            Account company = new Account(
                Name = name,
                BillingCity = locations[Math.mod(Math.abs(Crypto.getRandomInteger()), locations.size())] // Random location
            );
            companies.add(company);
        }

        insert companies;
        return companies;
    }

    // Method to create sample Contact records related to companies
    public static List<Contact> createContacts(List<Account> companies) {
        List<Contact> contacts = new List<Contact>();

        for (Account company : companies) {
            Contact contact = new Contact(
                FirstName = 'John',
                LastName = 'Doe - ' + company.Name,
                Email = 'jdoe_' + company.Name.toLowerCase() + '@example.com',
                AccountId = company.Id
            );
            contacts.add(contact);
        }

        insert contacts;
        return contacts;
    }

    // Method to create sample Job Application records
    public static void createJobApplications(List<Account> companies, List<Contact> contacts) {
        List<Job_Application__c> jobApplications = new List<Job_Application__c>();

        // Define job sources, positions, statuses, and work locations
        List<String> jobSources = new List<String>{'Jooble Job Board', 'LinkedIn', 'BuiltIn', 'Glassdoor'};
        List<String> jobPositions = new List<String>{'Salesforce Administrator', 'Salesforce Developer', 'Salesforce Consultant', 'Salesforce Architect', 'Salesforce Business Analyst'};
        List<String> jobStatuses = new List<String>{'Applied', 'Saved', 'Interviewing', 'Negotiating', 'Accepted'};
        List<String> workLocations = new List<String>{'Hybrid', 'Remote', 'Onsite'};

        Integer jobIndex = 1;

        // Loop through each job source category and create applications
        for (String source : jobSources) {
            for (Integer i = 0; i < 10; i++) {
                Account randomCompany = companies[Math.mod(Math.abs(Crypto.getRandomInteger()), companies.size())];
                Contact randomContact = contacts[Math.mod(Math.abs(Crypto.getRandomInteger()), contacts.size())];

                Job_Application__c jobApp = new Job_Application__c(
                    Application_Date__c = Date.today().addDays(-Math.mod(Math.abs(Crypto.getRandomInteger()), 30)),
                    Company_Name__c = randomCompany.Id,
                    Date_Posted__c = Date.today().addDays(-Math.mod(Math.abs(Crypto.getRandomInteger()), 20)).format(), // as string format
                    Job_Application_Status__c = jobStatuses[Math.mod(Math.abs(Crypto.getRandomInteger()), jobStatuses.size())],
                    Job_Position__c = jobPositions[Math.mod(Math.abs(Crypto.getRandomInteger()), jobPositions.size())],
                    Job_Source__c = source,
                    JoobleExternalId__c = String.valueOf(Crypto.getRandomInteger()),
                    Location__c = randomCompany.BillingCity,
                    Primary_Contact__c = randomContact.Id,
                    URL__c = 'https://job-board.com/job/' + jobIndex,
                    Work_Location__c = workLocations[Math.mod(Math.abs(Crypto.getRandomInteger()), workLocations.size())],
                    Description__c = 'Exciting opportunity for a Salesforce-related position at ' + randomCompany.Name + '.'
                );

                jobApplications.add(jobApp);
                jobIndex++;
            }
        }

        insert jobApplications;
    }

    // Method to execute all data creation steps
    public static void runDataSetup() {
        List<Account> companies = createCompanies();
        List<Contact> contacts = createContacts(companies);
        createJobApplications(companies, contacts);
    }
}
