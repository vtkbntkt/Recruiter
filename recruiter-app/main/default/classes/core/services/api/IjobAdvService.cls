public interface IjobAdvService {
    void postJobAdvWithPositionUpdate(Position__c position);
    void updateJobAdv(Position__c position);
    void removeJobAdv(Position__c position);
    
}