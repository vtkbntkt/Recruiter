public class Utils {
    //
    public static Map<String,String> position2jobAdvAsMap(Position__c position){
        Map <String,String> jobAdv = new Map<String, String>();
        jobAdv.put('Description__c', position.Job_Description__c);
        jobAdv.put('Education__c', position.Education__c);           
        jobAdv.put('id', position.ExternalId__c );
        jobAdv.put('Location__c', position.Location__c );          
        
        jobAdv.put('Skills_Required__c', position.Skills_Required__c );
        jobAdv.put('Name', position.Name );
        jobAdv.put('Manager_name__c', position.Hiring_Manager__r.Name);
        jobAdv.put('Phone__c', position.Hiring_Manager__r.Phone);
        jobAdv.put('Email__c', position.Hiring_Manager__r.Email ); 
        if(position.Status__c =='Closed'){
            jobAdv.put('Status__c', 'Archive');  
        }
        if(position.Salary_Range__c!=null){
            Pair salaryRange = salaryRange2values(position.Salary_Range__c);
            jobAdv.put('Salary_from__c', salaryRange.first);
            jobAdv.put('Salary_to__c', salaryRange.second);
        }
        
        return jobAdv;        
    }
    
    public static Pair salaryRange2values(String salaryRange){       
        Pair values = new Pair();
        if(salaryRange!=null){
            List<String> chars  = salaryRange.toLowerCase().split('');
            String fieldName = 'first';       
            for(String charX:chars){
                if(charX.isNumeric()){
                    values.append(fieldName,charX);
                }
                else if(charX.equals('-')){
                    fieldName = 'second';
                }
                else if (charX.equals('k')){
                    values.append(fieldName,'000');
                }
                else if (charX.equals('m')){
                    values.append(fieldName,'000000');
                }
                else if (charX.equals('+')){
                   //no need actions now 
                }
            }
        }
        return values;        
    }

    public static List<Integer> integer2integerList(Integer startIndex, Integer value){
        List<Integer> integerList = new List<Integer>();
        for(Integer i=startIndex;i<value+startIndex;i++){
            integerList.add(i);
        }
        return integerList;

    }
    
    public static Map<String, Map<String,String>> positions2jobAdsAsMapWithId(List <Position__c> positions){
        Map<String, Map<String,String>> jobAdsWithPositionId = new Map<String, Map<String,String>>();
        for(Position__c position:positions){
            jobAdsWithPositionId.put(position.id,position2jobAdvAsMap(position));
        }
        return jobAdsWithPositionId;       
    }
    
    public static String positions2jobAdsWithIdAsJsonString(List <Position__c> positions){
        return JSON.serialize(positions2jobAdsAsMapWithId(positions));        
    }
    
    public static List<Position__c> jobAdsWithIdAsJson2positions(String json){
        Map<String, Position__c> records = 
            (Map<String,Position__c>) System.JSON.deserialize(json,Map<String,Position__c>.class);
        for(String idRecord:records.keySet()){         
            records.get(idRecord).externalid__c = records.get(idRecord).id; 
            records.get(idRecord).id = idRecord;
        }       
        return records.values();
        
    }
    
    public class Pair{
        public final String FIRST_VALUE = 'first';
        public final String SECOND_VALUE = 'second';
        public String first{get;set;}
        public String second{get;set;}
        
        public void append(String fieldName, String value){
            if(fieldName==FIRST_VALUE){
                if(first==null){
                    first='';
                }
                first+=value;
            }
            else if(fieldName==SECOND_VALUE){
                if(second==null){
                    second='';
                }
                second+=value;  
            }
        }
        
        public override String toString(){            
            return first+':'+second;            
        }      
    }
    
    
    public class RecordFilter{
        private Map<Id, sObject> oldMap;
        private Map<Id, sObject> newMap;
        private Map<String, Set<String>> fieldValues;
        private String fieldForCompearing;
        
        public RecordFilter (Map<Id, sObject> oldMap,Map<Id, sObject> newMap, Map<String, Set<String>> fieldValues, String fieldForCompearing){
            this.oldMap = oldMap;                         
            this.newMap = newMap;
            this.fieldValues = fieldValues;
            this.fieldForCompearing  = fieldForCompearing;
        }
        
        public List<sObject> getFilteredList(){
            List<sObject> filteredList = new List<sObject>();             
            for(Id recordId:newMap.keySet()){
                if(oldMap.get(recordId).get(fieldForCompearing)!= 
                   newMap.get(recordId).get(fieldForCompearing)&&
                   isValuesEqual(newMap.get(recordId))){                  
                       filteredList.add(newMap.get(recordId)); 
                   }                 
            }
            return  filteredList;
        }
        
        private Boolean isValuesEqual(sObject record){            
            for(String field:fieldValues.keySet()){
                if(!fieldValues.get(field).contains(String.valueOf(record.get(field)))){
                    return false;
                }                
            }           
            return true;
        }
        
    }
    
    
    
    
    
}