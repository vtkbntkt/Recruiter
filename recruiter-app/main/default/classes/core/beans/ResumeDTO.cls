public class ResumeDTO {
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String age {get;set;}
    public String phone {get;set;}
    public String email {get;set;}
    public String education {get;set;}
    public Boolean currentlyEmployed {get;set;}
    public String country {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String zipCode {get;set;}
    public String street {get;set;}
    public String salary {get;set;}
    public String experienceYears {get;set;}
    public String additionalInformation {get;set;}
    public String photo {get;set;}
    public String photoName {get;set;}
    public List<String> jobAdIds{get;set;}
    
    public ResumeDTO(){
        jobAdIds  = new List<String>();

    }
}
