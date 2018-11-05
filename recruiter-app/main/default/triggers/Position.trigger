trigger Position on Position__c (before insert, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            System.debug('>>> Position trigger before insert>>> started');
            PositionTriggerHelper.processOwnerSetting(Trigger.New);
            System.debug('>>> Position trigger before insert>>> ended');
        }
    } 
    
    else{
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                System.debug('>>> Position trigger after insert>>> started');
                PositionTriggerHelper.processEmailSending(Trigger.New);
                System.debug('>>> Position trigger after insert>>> ended');
            }
            if(Trigger.isUpdate){
                System.debug('>>> Position trigger after update>>> started');
                PositionTriggerHelper.processJobAdvArchiving(Trigger.oldMap, Trigger.newMap);
                System.debug('>>> Position trigger after update>>> ended');
            }
        }
    }
    
}