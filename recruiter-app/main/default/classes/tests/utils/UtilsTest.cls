@isTest
private class UtilsTest { 

    @isTest static void test_fieldFilterCorrectly(){
        //Given
        Map<Id,Position__c> oldMap = new Map<Id,Position__c>();
        oldMap.put('a063E00000AomDXQAZ',new Position__c(Name = 'Dev1', Posting_status__c = 'Not Posted', Status__c='Open', Approval_Status__c='Approved'));
        oldMap.put('a064E00000AomDXQAZ',new Position__c(Name = 'Dev2', Posting_status__c = 'Posted', Status__c='Open', Approval_Status__c='Approved'));//
        oldMap.put('a065E00000AomDXQAZ',new Position__c(Name = 'Dev3', Posting_status__c = 'Posted', Status__c='Open'));
        oldMap.put('a066E00000AomDXQAZ',new Position__c(Name = 'Dev4', Posting_status__c = 'Posted', Status__c='Closed', Approval_Status__c='Approved'));
        oldMap.put('a067E00000AomDXQAZ',new Position__c(Name = 'Dev5', Posting_status__c = 'Not Posted', Status__c='Closed', Approval_Status__c='Approved'));
        oldMap.put('a068E00000AomDXQAZ',new Position__c(Name = 'Dev6', Posting_status__c = 'Posted', Status__c='Open', Approval_Status__c='Not Approved'));
        oldMap.put('a069E00000AomDXQAZ',new Position__c(Name = 'Dev7', Posting_status__c = 'Posted', Status__c='Open', Approval_Status__c='Pending'));//
        
        Map<Id,Position__c> newMap = new Map<Id,Position__c>();
        newMap.put('a063E00000AomDXQAZ',new Position__c(Name = 'Dev1', Posting_status__c = 'Not Posted', Status__c='Closed', Approval_Status__c='Approved'));
        newMap.put('a064E00000AomDXQAZ',new Position__c(Name = 'Dev2', Posting_status__c = 'Posted', Status__c='Closed', Approval_Status__c='Approved'));//
        newMap.put('a065E00000AomDXQAZ',new Position__c(Name = 'Dev3', Posting_status__c = 'Posted', Status__c='Closed'));
        newMap.put('a066E00000AomDXQAZ',new Position__c(Name = 'Dev4', Posting_status__c = 'Posted', Status__c='Closed', Approval_Status__c='Approved'));
        newMap.put('a067E00000AomDXQAZ',new Position__c(Name = 'Dev5', Posting_status__c = 'Not Posted', Status__c='Closed', Approval_Status__c='Approved'));
        newMap.put('a068E00000AomDXQAZ',new Position__c(Name = 'Dev6', Posting_status__c = 'Posted', Status__c='Closed', Approval_Status__c='Not Approved'));
        newMap.put('a069E00000AomDXQAZ',new Position__c(Name = 'Dev7', Posting_status__c = 'Posted', Status__c='Closed', Approval_Status__c='Pending'));//
        
        Map<String, Set<String>> fieldValues = new Map<String, Set<String>>();
        fieldValues.put('Posting_status__c',new Set<String>{'Posted'});
        fieldValues.put('Status__c',new Set<String>{'Closed'});
        fieldValues.put('Approval_Status__c',new Set<String>{'Approved','Pending'});
        Utils.RecordFilter filter = new Utils.RecordFilter (oldMap, newMap, fieldValues,'Status__c');
        
        //When
        List<Position__c> positions = filter.getFilteredList();
        
        //Then
        System.debug(positions);
        
        
    }
}