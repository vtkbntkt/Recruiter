public class PositionTriggerHelper {
    private static final String QUEUE_NAME = 'Unclaimed Positions Queue';
    @TestVisible private static Flag testFlag{get;set;}
    
    public static void processJobAdvArchiving(Map<Id, Position__c> oldPositions, Map<Id, Position__c> newPositions){
        Map<String, Set<String>> fieldValues = new Map<String, Set<String>>();
        fieldValues.put('Posting_status__c',new Set<String>{'Posted'});
        fieldValues.put('Status__c',new Set<String>{'Closed'});
        Utils.RecordFilter filter = new Utils.RecordFilter (oldPositions, newPositions, fieldValues,'Status__c');        
        List<Position__c> positions = filter.getFilteredList();    
        if(!positions.isEmpty()){
            Map<Id, Position__c> positionMap = new Map<Id, Position__c>(positions);
            JobAdvServiceImpl.closeJobAdvertisement(new List<Id>(positionMap.keySet()));
        }        
    }
    
    public static void processOwnerSetting(List<Position__c> posns){    
        setOwnerToPosition(posns);                  
    }
    
    private static void setOwnerToPosition(List<Position__c> posns){       
        Map<Id, User> recruiters = getRecruiters();
        if(recruiters.isEmpty()){
            throw new NoRecruitersQueueException();
        }
        Id ownerId = getOwnerId(); 
        if(ownerId==null){
            throw new NoRelevantQueueException();
        }       
        for(Position__c posn:posns){
            if(!recruiters.containsKey(posn.OwnerId)){              
                posn.OwnerId = ownerId;          
            }
        }      
    }
    
    private static Map<Id, User> getRecruiters(){
        if(testFlag==Flag.NO_RECRUITS){
            return new Map<Id,User>();
        }
        return new Map<Id,User>([SELECT ID,Name,Email FROM User WHERE UserRoleId IN (SELECT ID FROM UserRole WHERE Name='Recruiter')]); 
    }
    
    private static Id getOwnerId(){       
        List<Group> groupList = getGroup();
        if (!groupList.isEmpty()&&testFlag!=Flag.NO_QUEUE){
            return groupList.get(0).id;
        }
        return null;
    }
    
    private static List<Group> getGroup(){
        return [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =:QUEUE_NAME];
    }
    
    public static void processEmailSending(List<Position__c> posns){
        if(!posns.isEmpty()){
            Map<Id, User> recruiters = getRecruiters();
            if(!recruiters.isEmpty()){               
                EmailManager.EmailAddress addresses = new EmailManager.EmailAddress();
                addresses.to.addAll(getEmailAddresses(recruiters.values())); 
                EmailManager.sendMail(addresses, getEmailSubject(), getEmailBody(posns)); 
            }          
        }
    }
    
    private static String getEmailSubject(){
        return 'Please meet new positions';
        
    }
    private static String getEmailBody(List<Position__c> posns){
        String body = 'Hi Team,'+'\n'+'Please find new positions below'+'\n';
        for (Position__c posn:posns){
            body+=posn.name+'\n';
        }       
        return body;        
    }
    
    private static List<String> getEmailAddresses(List<User> recruiters){       
        List<String> emails = new List<String>();      
        for(User user:recruiters){
            emails.add(user.email);
        }   
        return emails;
    }
    
    
    
    public class NoRelevantQueueException extends Exception{}
    public class NoRecruitersQueueException extends Exception{}
    public enum Flag {NO_QUEUE, NO_RECRUITS}
    
}