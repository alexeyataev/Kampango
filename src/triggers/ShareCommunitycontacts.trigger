trigger ShareCommunitycontacts on User (after insert) {

if(trigger.isafter && trigger.isinsert){
profile p = [select id from profile where name='Branch Coordinator'];

list<id> ulist = new list<id>();
for(user u: trigger.new){
id profileid= u.profileid;
if(u.Contactid!=null && profileid==p.id)
ulist.add(u.id);
}
if(ulist.size()>0)
commnitycontactshare.contactshare(ulist);

}


}