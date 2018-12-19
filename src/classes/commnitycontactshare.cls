public class commnitycontactshare{


@future
public static void contactshare(list<id> userids){

list<user> ulist = [select id,contactid from user where id=:userids];
list<ContactShare> conshare = new list<Contactshare>();
for(user u: ulist){
ContactShare con = new ContactShare(ContactId = u.contactid,ContactAccessLevel='Edit',UserOrGroupId=u.id);
conshare.add(con);

//
insert conshare;
}
}
}