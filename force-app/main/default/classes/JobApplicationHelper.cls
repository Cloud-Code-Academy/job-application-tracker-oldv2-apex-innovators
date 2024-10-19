public with sharing class JobApplicationHelper {
    public static void processJobApplications(List<Job_Application__c> newJobAppList, Map<Id, Job_Application__c> oldJobAppMap) {
        List<Task> tasksToInsert = new List<Task>();
        Set<Id> processedJobAppIds = new Set<Id>();

        // Fetch existing tasks related to job applications
        for (Task existingTask : [SELECT Id, WhatId FROM Task WHERE WhatId IN :newJobAppList]) {
            processedJobAppIds.add(existingTask.WhatId);
        }


        for (Job_Application__c newApplication : newJobAppList) {
            Job_Application__c oldApp = oldJobAppMap != null ? oldJobAppMap.get(newApplication.Id) : null;

            Boolean isStatusChanged = oldApp == null || newApplication.Job_Application_Status__c != oldApp.Job_Application_Status__c;

            // If the application has been processed before and the status didn't change, skip it
            if (processedJobAppIds.contains(newApplication.Id) && !isStatusChanged) {
                continue;
            }

            if (isStatusChanged || !processedJobAppIds.contains(newApplication.Id)) {
                switch on newApplication.Job_Application_Status__c {
                    when 'Saved' {
                        if (!processedJobAppIds.contains(newApplication.Id)) {
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Research', 'Normal', 'Check if the job description aligns with your interests and values'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Research', 'Normal', 'Review the highlighted skills to see if the role is a good fit'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Research', 'Low', 'Research the company or role and mark your excitement level'));
                        }
                    }
                    when 'Applying' {
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Networking', 'High', 'Find and research someone who works at the company and add them as a contact'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Networking', 'High', 'Set up an informational interview to learn more about the role/company'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Networking', 'High', 'Identify potential referrals to help get your application on the top of the pile'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Application Process', 'Normal', 'Customize your work achievements using the job description keywords'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Application Process', 'High', 'Submit your application on the company website if possible'));
                    }
                    when 'Applied' {
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Application Process', 'High', 'Reach out to the hiring manager or recruiter'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Application Process', 'Normal', 'Follow up on your application via email weekly'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Research', 'Low', 'Continue identifying and saving similar job opportunities'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Networking', 'Normal', 'Set up weekly networking calls to explore similar companies/roles'));
                    }
                    when 'Interviewing' {
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Interview Preparation', 'High', 'Prepare your blurb or “tell me about yourself” response'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Interview Preparation', 'Normal', 'Practice answering behavioral interview questions'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Interview Preparation', 'Normal', 'Research the company and your interviewers'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Interview Preparation', 'High', 'Set up your virtual interview space and test your tech'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Interview Preparation', 'High', 'Send thank you emails within 24 hours'));
                    }
                    when 'Negotiating' {
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Offer Negotiation', 'Normal', 'Research your market value and know your numbers'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Offer Negotiation', 'Normal', 'Prepare your negotiation scripts'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Offer Negotiation', 'High', 'Evaluate your offer and decline or accept'));

                    }
                    when 'Accepted' {

                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Onboarding & Reflection', 'Normal', 'Plan your resignation if applicable'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Onboarding & Reflection', 'Low', 'Take some time to relax and recharge'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Onboarding & Reflection', 'Normal', 'Prepare for your first day of onboarding'));

                    }
                    when 'Closed' {
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Email', 'Normal', 'Send a follow-up email thanking the interviewer and asking for feedback'));
                            tasksToInsert.add(TaskManager.prepareTask(newApplication, 'Onboarding & Reflection', 'Low', 'Review your notes and reflect on areas of improvement'));
                    }
                    when else {
                        System.debug('No tasks created for unrecognized status: ' + newApplication.Job_Application_Status__c);
                        throw new CustomException('Unrecognized job application status: ' + newApplication.Job_Application_Status__c);
                    }
                }
            }        
        }

        if (!taskstoInsert.isEmpty()) {
            TaskManager.createTasksForApplication(tasksToInsert);
        }

    }
}