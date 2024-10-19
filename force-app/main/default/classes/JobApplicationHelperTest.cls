@isTest
private class JobApplicationHelperTest {
    @TestSetup
    static void setup(){
        TestDataFactory.createJobApplications(400, 'Saved');     
    }

    @isTest
    static void testProcessJobApplications_Saved() {
        // Retrieve the updated job applications
        List<Job_Application__c> updatedAppList = [SELECT Id, Job_Application_Status__c, OwnerId FROM Job_Application__c];

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(updatedAppList, null);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(3, tasksForApp.size(), 'There should be 3 tasks created for each job application with the "Saved" status');
            
            // Check the details of each task
            Boolean check1 = false;
            Boolean check2 = false;
            Boolean check3 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Research' && task.Priority == 'Normal' && task.Description == 'Check if the job description aligns with your interests and values') {
                    check1 = true;
                } else if (task.Subject == 'Research' && task.Priority == 'Normal' && task.Description == 'Review the highlighted skills to see if the role is a good fit') {
                    check2 = true;
                } else if (task.Subject == 'Research' && task.Priority == 'Low' && task.Description == 'Research the company or role and mark your excitement level') {
                    check3 = true;
                }
            }

            // Assert that all three tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Check if the job description aligns with your interests and values) should be created.');
            Assert.isTrue(check2, 'Task 2 (Review the highlighted skills to see if the role is a good fit) should be created.');
            Assert.isTrue(check3, 'Task 3 (Research the company or role and mark your excitement level) should be created.');
        }
    }

    @isTest
    static void testProcessJobApplications_Applying() {   
        // Retrieve Job Applications from TestSetup
        List<Job_Application__c> oldAppList = [SELECT Id, Job_Application_Status__c FROM Job_Application__c];

        //Prepare map of old job applications with original status
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>(oldAppList);

        //Update job applications to 'Applying' status
        for (Job_Application__c app : oldAppList) {
            app.Job_Application_Status__c = 'Applying';
        }
        update oldAppList;

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(oldAppList, oldJobAppMap);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(8, tasksForApp.size(), 'There should be 8 tasks created for each job application after updating to "Applying" status');
            
             // Separate tasks into "Saved" and "Applying" groups based on their descriptions
            Integer savedTaskCount = 0;
            Integer applyingTaskCount = 0;

            for (Task task : tasksForApp) {
                if (task.Description.contains('aligns with your interests') || 
                    task.Description.contains('skills to see if the role is a good fit') || 
                    task.Description.contains('mark your excitement level')) {
                    // Count tasks from the "Saved" status
                    savedTaskCount++;
                } else {
                    // Count tasks from the "Applying" status
                    applyingTaskCount++;
                }
            }

            // Ensure that there are 3 tasks from 'Saved' status (but don't recheck their details)
            Assert.areEqual(3, savedTaskCount, 'There should still be 3 tasks from the "Saved" status');

            // Ensure that there are 5 tasks from 'Applying' status and check their details
            Assert.areEqual(5, applyingTaskCount, 'There should be 5 new tasks from the "Applying" status');
            
            // Check the details of the "Applying" tasks
            Boolean check1 = false;
            Boolean check2 = false;
            Boolean check3 = false;
            Boolean check4 = false;
            Boolean check5 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Networking' && task.Priority == 'High' && task.Description == 'Find and research someone who works at the company and add them as a contact') {
                    check1 = true;
                } else if (task.Subject == 'Networking' && task.Priority == 'High' && task.Description == 'Set up an informational interview to learn more about the role/company') {
                    check2 = true;
                } else if (task.Subject == 'Networking' && task.Priority == 'High' && task.Description == 'Identify potential referrals to help get your application on the top of the pile') {
                    check3 = true;
                } else if (task.Subject == 'Application Process' && task.Priority == 'Normal' && task.Description == 'Customize your work achievements using the job description keywords') {
                    check4 = true;
                } else if (task.Subject == 'Application Process' && task.Priority == 'High' && task.Description == 'Submit your application on the company website if possible') {
                    check5 = true;
                }
            }

            // Assert that all five "Applying" tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Find and research someone who works at the company and add them as a contact) should be created.');
            Assert.isTrue(check2, 'Task 2 (Set up an informational interview to learn more about the role/company) should be created.');
            Assert.isTrue(check3, 'Task 3 (Identify potential referrals to help get your application on the top of the pile) should be created.');
            Assert.isTrue(check4, 'Task 4 (Customize your work achievements using the job description keywords) should be created.');
            Assert.isTrue(check5, 'Task 5 (Submit your application on the company website if possible) should be created.');
        }
    }

    @isTest
    static void testProcessJobApplications_Applied() {   
        // Retrieve Job Applications from TestSetup
        List<Job_Application__c> oldAppList = [SELECT Id, Job_Application_Status__c FROM Job_Application__c];

        //Prepare map of old job applications with original status
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>(oldAppList);

        //Update job applications to 'Applying' status
        for (Job_Application__c app : oldAppList) {
            app.Job_Application_Status__c = 'Applied';
        }
        update oldAppList;

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(oldAppList, oldJobAppMap);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(7, tasksForApp.size(), 'There should be 7 tasks created for each job application after updating to "Applied" status');
            
             // Separate tasks into "Saved" and "Applying" groups based on their descriptions
            Integer savedTaskCount = 0;
            Integer appliedTaskCount = 0;

            for (Task task : tasksForApp) {
                if (task.Description.contains('aligns with your interests') || 
                    task.Description.contains('skills to see if the role is a good fit') || 
                    task.Description.contains('mark your excitement level')) {
                    // Count tasks from the "Saved" status
                    savedTaskCount++;
                } else {
                    // Count tasks from the "Applied" Status
                    appliedTaskCount++;
                }
            }

            // Ensure that there are 3 tasks from 'Saved' status (but don't recheck their details)
            Assert.areEqual(3, savedTaskCount, 'There should still be 3 tasks from the "Saved" status');

            // Ensure that there are 4 tasks from 'Applied' status and check their details
            Assert.areEqual(4, appliedTaskCount, 'There should be 4 new tasks from the "Applied" status');
            
            // Check the details of the "Applying" tasks
            Boolean check1 = false;
            Boolean check2 = false;
            Boolean check3 = false;
            Boolean check4 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Application Process' && task.Priority == 'High' && task.Description == 'Reach out to the hiring manager or recruiter') {
                    check1 = true;
                } else if (task.Subject == 'Application Process' && task.Priority == 'Normal' && task.Description == 'Follow up on your application via email weekly') {
                    check2 = true;
                } else if (task.Subject == 'Research' && task.Priority == 'Low' && task.Description == 'Continue identifying and saving similar job opportunities') {
                    check3 = true;
                } else if (task.Subject == 'Networking' && task.Priority == 'Normal' && task.Description == 'Set up weekly networking calls to explore similar companies/roles') {
                    check4 = true;
                }
            }

            // Assert that all five "Applying" tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Reach out to the hiring manager or recruiter) should be created.');
            Assert.isTrue(check2, 'Task 2 (Follow up on your application via email weekly) should be created.');
            Assert.isTrue(check3, 'Task 3 (Continue identifying and saving similar job opportunities) should be created.');
            Assert.isTrue(check4, 'Task 4 (Set up weekly networking calls to explore similar companies/roles) should be created.');
        }
    }

    @isTest
    static void testProcessJobApplications_Interviewing() {   
        // Retrieve Job Applications from TestSetup
        List<Job_Application__c> oldAppList = [SELECT Id, Job_Application_Status__c FROM Job_Application__c];

        //Prepare map of old job applications with original status
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>(oldAppList);

        //Update job applications to 'Interviewing' status
        for (Job_Application__c app : oldAppList) {
            app.Job_Application_Status__c = 'Interviewing';
        }
        update oldAppList;

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(oldAppList, oldJobAppMap);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(8, tasksForApp.size(), 'There should be 8 tasks created for each job application after updating to "Interviewing" status');
            
             // Separate tasks into "Saved" and "Interviewing" groups based on their descriptions
            Integer savedTaskCount = 0;
            Integer interviewingTaskCount = 0;

            for (Task task : tasksForApp) {
                if (task.Description.contains('aligns with your interests') || 
                    task.Description.contains('skills to see if the role is a good fit') || 
                    task.Description.contains('mark your excitement level')) {
                    // Count tasks from the "Saved" status
                    savedTaskCount++;
                } else {
                    // Count tasks from the "Interviewing" Status
                    interviewingTaskCount++;
                }
            }

            // Ensure that there are 3 tasks from 'Saved' status (but don't recheck their details)
            Assert.areEqual(3, savedTaskCount, 'There should still be 3 tasks from the "Saved" status');

            // Ensure that there are 5 tasks from 'Interviewing' status and check their details
            Assert.areEqual(5, interviewingTaskCount, 'There should be 5 new tasks from the "Interviewing" status');
            
            // Check the details of the "Interviewing" tasks
            Boolean check1 = false;
            Boolean check2 = false;
            Boolean check3 = false;
            Boolean check4 = false;
            Boolean check5 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Interview Preparation' && task.Priority == 'High' && task.Description == 'Prepare your blurb or “tell me about yourself” response') {
                    check1 = true;
                } else if (task.Subject == 'Interview Preparation' && task.Priority == 'Normal' && task.Description == 'Practice answering behavioral interview questions') {
                    check2 = true;
                } else if (task.Subject == 'Interview Preparation' && task.Priority == 'Normal' && task.Description == 'Research the company and your interviewers') {
                    check3 = true;
                } else if (task.Subject == 'Interview Preparation' && task.Priority == 'High' && task.Description == 'Set up your virtual interview space and test your tech') {
                    check4 = true;
                } else if (task.Subject == 'Interview Preparation' && task.Priority == 'High' && task.Description == 'Send thank you emails within 24 hours') {
                    check4 = true;
                }
            }

            // Assert that all four "Interviewing" tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Prepare your blurb or “tell me about yourself” response) should be created.');
            Assert.isTrue(check2, 'Task 2 (Practice answering behavioral interview questions) should be created.');
            Assert.isTrue(check3, 'Task 3 (Research the company and your interviewers) should be created.');
            Assert.isTrue(check4, 'Task 4 (Send thank you emails within 24 hours) should be created.');
        }
    }

    @isTest
    static void testProcessJobApplications_Negotiating() {   
        // Retrieve Job Applications from TestSetup
        List<Job_Application__c> oldAppList = [SELECT Id, Job_Application_Status__c FROM Job_Application__c];

        //Prepare map of old job applications with original status
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>(oldAppList);

        //Update job applications to 'Negotiating' status
        for (Job_Application__c app : oldAppList) {
            app.Job_Application_Status__c = 'Negotiating';
        }
        update oldAppList;

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(oldAppList, oldJobAppMap);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(6, tasksForApp.size(), 'There should be 6 tasks created for each job application after updating to "Negotiating" status');
            
             // Separate tasks into "Saved" and "Negotiating" groups based on their descriptions
            Integer savedTaskCount = 0;
            Integer negotiatingTaskCount = 0;

            for (Task task : tasksForApp) {
                if (task.Description.contains('aligns with your interests') || 
                    task.Description.contains('skills to see if the role is a good fit') || 
                    task.Description.contains('mark your excitement level')) {
                    // Count tasks from the "Saved" status
                    savedTaskCount++;
                } else {
                    // Count tasks from the "Negotiating" Status
                    negotiatingTaskCount++;
                }
            }

            // Ensure that there are 3 tasks from 'Saved' status (but don't recheck their details)
            Assert.areEqual(3, savedTaskCount, 'There should still be 3 tasks from the "Saved" status');

            // Ensure that there are 3 tasks from 'Negotiating' status and check their details
            Assert.areEqual(3, negotiatingTaskCount, 'There should be 3 new tasks from the "Negotiating" status');
            
            // Check the details of the "Negotiating" tasks
            Boolean check1 = false;
            Boolean check2 = false;
            Boolean check3 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Offer Negotiation' && task.Priority == 'Normal' && task.Description == 'Research your market value and know your numbers') {
                    check1 = true;
                } else if (task.Subject == 'Offer Negotiation' && task.Priority == 'Normal' && task.Description == 'Prepare your negotiation scripts') {
                    check2 = true;
                } else if (task.Subject == 'Offer Negotiation' && task.Priority == 'High' && task.Description == 'Evaluate your offer and decline or accept') {
                    check3 = true;
                }
            }

            // Assert that all three "Negotiating" tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Research your market value and know your numbers) should be created.');
            Assert.isTrue(check2, 'Task 2 (Prepare your negotiation scripts) should be created.');
            Assert.isTrue(check3, 'Task 3 (Evaluate your offer and decline or accept) should be created.');
        }
    }

    @isTest
    static void testProcessJobApplications_Accepted() {   
        // Retrieve Job Applications from TestSetup
        List<Job_Application__c> oldAppList = [SELECT Id, Job_Application_Status__c FROM Job_Application__c];

        //Prepare map of old job applications with original status
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>(oldAppList);

        //Update job applications to 'Accepted' status
        for (Job_Application__c app : oldAppList) {
            app.Job_Application_Status__c = 'Accepted';
        }
        update oldAppList;

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(oldAppList, oldJobAppMap);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(6, tasksForApp.size(), 'There should be 6 tasks created for each job application after updating to "Accepted" status');
            
             // Separate tasks into "Saved" and "Accepted" groups based on their descriptions
            Integer savedTaskCount = 0;
            Integer acceptedTaskCount = 0;

            for (Task task : tasksForApp) {
                if (task.Description.contains('aligns with your interests') || 
                    task.Description.contains('skills to see if the role is a good fit') || 
                    task.Description.contains('mark your excitement level')) {
                    // Count tasks from the "Saved" status
                    savedTaskCount++;
                } else {
                    // Count tasks from the "Accepted" Status
                    acceptedTaskCount++;
                }
            }

            // Ensure that there are 3 tasks from 'Saved' status (but don't recheck their details)
            Assert.areEqual(3, savedTaskCount, 'There should still be 3 tasks from the "Saved" status');

            // Ensure that there are 3 tasks from 'Accepted' status and check their details
            Assert.areEqual(3, acceptedTaskCount, 'There should be 3 new tasks from the "Accepted" status');
            
            // Check the details of the "Accepted" tasks
            Boolean check1 = false;
            Boolean check2 = false;
            Boolean check3 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Onboarding & Reflection' && task.Priority == 'Normal' && task.Description == 'Plan your resignation if applicable') {
                    check1 = true;
                } else if (task.Subject == 'Onboarding & Reflection' && task.Priority == 'Low' && task.Description == 'Take some time to relax and recharge') {
                    check2 = true;
                } else if (task.Subject == 'Onboarding & Reflection' && task.Priority == 'Normal' && task.Description == 'Prepare for your first day of onboarding') {
                    check3 = true;
                }
            }

            // Assert that all three "Accepted" tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Plan your resignation if applicable) should be created.');
            Assert.isTrue(check2, 'Task 2 (Take some time to relax and recharge) should be created.');
            Assert.isTrue(check3, 'Task 3 (Prepare for your first day of onboarding) should be created.');
        }
    }

    @isTest
    static void testProcessJobApplications_Closed() {   
        // Retrieve Job Applications from TestSetup
        List<Job_Application__c> oldAppList = [SELECT Id, Job_Application_Status__c FROM Job_Application__c];

        //Prepare map of old job applications with original status
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>(oldAppList);

        //Update job applications to 'Closed' status
        for (Job_Application__c app : oldAppList) {
            app.Job_Application_Status__c = 'Closed';
        }
        update oldAppList;

        // Call the method to be tested
        Test.startTest();
        JobApplicationHelper.processJobApplications(oldAppList, oldJobAppMap);
        Test.stopTest();

        // Retrieve the created tasks
        List<Task> createdTasks = [SELECT Id, Subject, ActivityDate, Priority, OwnerId, WhatId, Status, Description FROM Task];

        // Assertions
        // Ensure that each job application has three related tasks
        Map<Id, List<Task>> tasksByJobApp = new Map<Id, List<Task>>();
        for (Task task : createdTasks) {
            if (!tasksByJobApp.containsKey(task.WhatId)) {
                tasksByJobApp.put(task.WhatId, new List<Task>());
            }
            tasksByJobApp.get(task.WhatId).add(task);
        }
        
        for (Id appId : tasksByJobApp.keySet()) {
            List<Task> tasksForApp = tasksByJobApp.get(appId);
            
            // Check that there are exactly 3 tasks for each job application with the "Saved" status
            Assert.areEqual(5, tasksForApp.size(), 'There should be 5 tasks created for each job application after updating to "Closed" status');
            
             // Separate tasks into "Saved" and "Closed" groups based on their descriptions
            Integer savedTaskCount = 0;
            Integer closedTaskCount = 0;

            for (Task task : tasksForApp) {
                if (task.Description.contains('aligns with your interests') || 
                    task.Description.contains('skills to see if the role is a good fit') || 
                    task.Description.contains('mark your excitement level')) {
                    // Count tasks from the "Saved" status
                    savedTaskCount++;
                } else {
                    // Count tasks from the "Closed" Status
                    closedTaskCount++;
                }
            }

            // Ensure that there are 3 tasks from 'Saved' status (but don't recheck their details)
            Assert.areEqual(3, savedTaskCount, 'There should still be 3 tasks from the "Saved" status');

            // Ensure that there are 2 tasks from 'Closed' status and check their details
            Assert.areEqual(2, closedTaskCount, 'There should be 2 new tasks from the "Closed" status');
            
            // Check the details of the "Closed" tasks
            Boolean check1 = false;
            Boolean check2 = false;

            for (Task task : tasksForApp) {
                if (task.Subject == 'Email' && task.Priority == 'Normal' && task.Description == 'Send a follow-up email thanking the interviewer and asking for feedback') {
                    check1 = true;
                } else if (task.Subject == 'Onboarding & Reflection' && task.Priority == 'Low' && task.Description == 'Review your notes and reflect on areas of improvement') {
                    check2 = true;
                }
            }

            // Assert that all two "Closed" tasks were created correctly
            Assert.isTrue(check1, 'Task 1 (Send a follow-up email thanking the interviewer and asking for feedback) should be created.');
            Assert.isTrue(check2, 'Task 2 (Review your notes and reflect on areas of improvement) should be created.');
        }
    }


    @isTest
    static void testWhenElseCondition_ExceptionThrown() {
        // Arrange: Create a list of new job applications with an unrecognized status.
        List<Job_Application__c> newJobAppList = new List<Job_Application__c>();
        Job_Application__c jobApp = new Job_Application__c(Job_Application_Status__c = 'UnrecognizedStatus');
        newJobAppList.add(jobApp);
        
        // Empty map for old job applications.
        Map<Id, Job_Application__c> oldJobAppMap = new Map<Id, Job_Application__c>();
        
        // Act and Assert: Expect the exception to be thrown.
        // Act and Assert: Expect the exception to be thrown.
        Test.startTest();
        try {
            JobApplicationHelper.processJobApplications(newJobAppList, oldJobAppMap);
            Assert.fail('Expected a CustomException to be thrown'); // Fail the test if no exception is thrown.
        } catch (CustomException e) {
            Assert.areEqual('Unrecognized job application status: UnrecognizedStatus', e.getMessage(), 'The exception message should match the expected message.');
        }
        Test.stopTest();
    }

}