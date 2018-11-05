public class JobApplicationTriggerHelper {
    
    public static void processTaskAdding(Map<Id, Job_Application__c> oldJobApps, Map<Id, Job_Application__c> newJobApps){
        System.debug('>>> JobApplicationTriggerHelper>>> start job app extracting');
        List<Job_Application__c> jobApps = extractJobAppWithChangedStatus(oldJobApps,newJobApps);
        if(!jobApps.isEmpty()){
            System.debug('>>> JobApplicationTriggerHelper>>> start job app wrapping');             
            List<WrappedJobApp> wrappedJobApp = wrapJobApps(jobApps);          
            if(!wrappedJobApp.isEmpty()){
                System.debug('>>> JobApplicationTriggerHelper>>> start tasks creation ');
                List<Task> tasks = prepareTasks(wrappedJobApp);   
                System.debug('>>> JobApplicationTriggerHelper>>> end tasks creation '+tasks.size());
                try{
                    System.debug('>>> JobApplicationTriggerHelper>>> try to insert tasks ');
                    insert tasks;
                    System.debug('>>> JobApplicationTriggerHelper>>> tasks are inserted ');
                }
                catch(DmlException exc){          
                    throw new TaskByJobAppStatusException(exc.getMessage());
                    // logging
                    //throw exc;
                }               
            }           
        }        
    }
    
    private static List<Job_Application__c> extractJobAppWithChangedStatus(Map<Id, Job_Application__c> oldJobApps, 
                                                                           Map<Id, Job_Application__c> newJobApps){
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        for(Id jobAppId : newJobApps.keySet()){  
            if(oldJobApps.get(jobAppId).Stage__c!= newJobApps.get(jobAppId).Stage__c ){
                jobApps.add(newJobApps.get(jobAppId)); 
            }
        }
        return jobApps;       
    }
    
    private static List<WrappedJobApp> wrapJobApps(List<Job_Application__c> jobApps){
        List<WrappedJobApp> wrappedJobApps = new List<WrappedJobApp>();        
        for(Job_Application__c jobApp:jobApps){
            if(jobApp.Stage__c=='Closed - Rejected'){ 
                wrappedJobApps.add(new WrappedJobApp(jobApp, Status.REJECTED));  
            }           
            else if(jobApp.Stage__c=='Offer Extended'){
                wrappedJobApps.add(new WrappedJobApp(jobApp, Status.OFFER_EXTENDED));
            }          
        }
        return wrappedJobApps;        
    }
    
    
    
    private static List<Task> prepareTasks(List<WrappedJobApp> jobApps){
        List<Task> tasks = new List<Task>();
        for (WrappedJobApp jobApp:jobApps){
            tasks.add(prepareTask(jobApp));
        }
        return tasks;      
    }
    
    private static Task prepareTask(WrappedJobApp jobApp){      
        Task task = new Task();
        task.WhatId = jobApp.jobApp.id;
        task.OwnerId = jobApp.jobApp.OwnerId;
        task.Status = 'Not Started';       
        if(jobApp.jobAppstatus == Status.OFFER_EXTENDED){
            task.Subject = 'Extend an Offer';
        }
        else if(jobApp.jobAppstatus == Status.REJECTED){
            task.Subject = 'Send Rejection Letter';           
        }       
        return task;       
    }
    
    public class WrappedJobApp{
        public Job_Application__c jobApp{get;set;}
        public Status jobAppstatus{get;set;}        
        public WrappedJobApp(Job_Application__c jobApp, Status jobAppstatus){
            this.jobApp = jobApp;
            this.jobAppstatus  = jobAppstatus;
        }       
    }
    
    public enum Status {OFFER_EXTENDED, REJECTED} 
    
    public class TaskByJobAppStatusException extends Exception {

}
}