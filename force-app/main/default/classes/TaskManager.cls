public with sharing class TaskManager {
    public static void createTasksForApplication (List<Task> tasks) {
        try {
            if (!tasks.isEmpty()) {
                insert newTask;
            }         
        } catch (DmlException e) {
            System.debug('Error creating tasks: ' + e.getMessage());
        }
    }

    public static void prepareTasks(Job_Application__c app, String subject, Date dueDate, String priority) {
        Task newTask = new Task(
            Subject = subject,
            ActivityDate = dueDate,
            Priority = priority,
            OwnerId = app.OwnerId,
            WhatId = app.Id,
            Status = 'Not Started'
        );     
    }
}