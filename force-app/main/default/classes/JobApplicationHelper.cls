public with sharing class JobApplicationHelper {
    public static void processJobApplications(List<Job_Application__c> newJobAppList, Map<Id, Job_Application__c> oldJobAppMap) {
        List<Task> tasksToInsert = new List<Task>();
        Set<Id> processedJobAppIds = new Set<Id>();

        // Fetch existing tasks related to job applications
        Set<String> existingTaskSubjects = new Set<String>();
        for (Task existingTask : [SELECT Id, WhatId, Subject, Type, Application_Status_Snapshot__c FROM Task WHERE WhatId IN :newJobAppList]) {
            existingTaskSubjects.add(existingTask.Subject + '|' + existingTask.Application_Status_Snapshot__c);
            processedJobAppIds.add(existingTask.WhatId);
        }

        List<String> subjectList = new List<String>{
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company or role and mark your excitement level',
            'Find and research someone who works at the company and add them as a contact',
            'Set up an informational interview to learn more about the role/company',
            'Identify potential referrals to help get your application on the top of the pile',
            'Customize your work achievements using the job description keywords',
            'Submit your application on the company website if possible',
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles',
            'Prepare your blurb or “tell me about yourself” response',
            'Practice answering behavioral interview questions',
            'Research the company and your interviewers',
            'Set up your virtual interview space and test your tech',
            'Send thank you emails within 24 hours',
            'Research your market value and know your numbers',
            'Prepare your negotiation scripts',
            'Evaluate your offer and decline or accept',
            'Plan your resignation if applicable',
            'Take some time to relax and recharge',
            'Prepare for your first day of onboarding',
            'Send a follow-up email thanking the interviewer and asking for feedback',
            'Review your notes and reflect on areas of improvement'
        };


        for (Job_Application__c newApplication : newJobAppList) {
            Job_Application__c oldApp = oldJobAppMap != null ? oldJobAppMap.get(newApplication.Id) : null;

            Boolean isStatusChanged = oldApp == null || newApplication.Job_Application_Status__c != oldApp.Job_Application_Status__c;

            // If the application has been processed before and the status didn't change, skip it
            if (!isStatusChanged && processedJobAppIds.contains(newApplication.Id)) {
                continue;
            }

            if (isStatusChanged || !processedJobAppIds.contains(newApplication.Id)) {
                switch on newApplication.Job_Application_Status__c {
                    when 'Saved' {
                        if (!processedJobAppIds.contains(newApplication.Id)) {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Research', 'Normal', subjectList[0]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Research', 'Normal', subjectList[1]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Research', 'Low', subjectList[2]);

                        }
                    }
                    when 'Applying' {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Networking', 'High', subjectList[3]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Networking', 'High', subjectList[4]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Networking', 'High', subjectList[5]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Application Process', 'Normal', subjectList[6]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Application Process', 'High', subjectList[7]);
                    }
                    when 'Applied' {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Application Process', 'High', subjectList[8]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Application Process', 'Normal', subjectList[9]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Research', 'Low', subjectList[10]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Networking', 'Normal', subjectList[11]);
                    }
                    when 'Interviewing' {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Interview Preparation', 'High', subjectList[12]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Interview Preparation', 'Normal', subjectList[13]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Interview Preparation', 'Normal', subjectList[14]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Interview Preparation', 'High', subjectList[15]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Interview Preparation', 'High', subjectList[16]);
                    }
                    when 'Negotiating' {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Offer Negotiation', 'Normal', subjectList[17]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Offer Negotiation', 'Normal', subjectList[18]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Offer Negotiation', 'High', subjectList[19]);
                    }
                    when 'Accepted' {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Onboarding & Reflection', 'Normal', subjectList[20]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Onboarding & Reflection', 'Low', subjectList[21]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Onboarding & Reflection', 'Normal', subjectList[22]);
                    }
                    when 'Closed' {
                            processedJobAppIds.add(newApplication.Id);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Email', 'Normal', subjectList[23]);
                            addTaskIfNotExists(tasksToInsert, existingTaskSubjects, newApplication, 'Onboarding & Reflection', 'Low', subjectList[24]);
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

    private static void addTaskIfNotExists(List<Task> tasksToInsert, Set<String> existingTaskSubjects, Job_Application__c application, String taskType, String priority, String subject) {
        String key = subject + '|' + application.Job_Application_Status__c;
        // Check if a task with the same subject and Application Status Snapshot already exists
        if (!existingTaskSubjects.contains(key)) {
            tasksToInsert.add(TaskManager.prepareTask(application, taskType, priority, subject));
        }
    }
}