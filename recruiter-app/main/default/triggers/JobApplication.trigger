trigger JobApplication on Job_Application__c (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            System.debug('>>> JobApplication trigger>>> started');
            JobApplicationTriggerHelper.processTaskAdding(Trigger.oldMap, Trigger.newMap);
            System.debug('>>> JobApplication trigger>>> ended');
        }
    }
    // shoul be routined
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
}