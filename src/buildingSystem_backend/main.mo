import Debug "mo:base/Debug";
import Trie "mo:base/Trie"; //Arbol (stable)
import List "mo:base/List"; //Lista (no stable)
import Nat "mo:base/Nat";    //Importacion de las funciones de Motoko 
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Option "mo:base/Option";
import FullRels "Rels/fullRels";
import  Types  "Types";  // Import para documento de Types 

actor BuildingSystem{ 

  type Family = Types.Family; //iniciando Type para Family en el canister
  type Activity = Types.Activity;

  stable var families: Trie.Trie<Nat, Family> = Trie.empty(); //Creando Arbol de tipo Family vacio
  stable var activities: Trie.Trie<Nat, Activity> = Trie.empty();
  stable var memberForRoom = List.nil<(Nat, Family)>();

  type FamilyActivity = {
    status: Status;
    details: Text;
  };

  type Status = {
  #Taken;
  #Approved; 
  #OnHold;
  #Done;
  #Payed
  };

  stable var familyActivityEntries : [(Nat, Nat, FamilyActivity)] = []; //activityId, activityId, position
  let familyActivityEntriesRels = FullRels.Rels<Nat, Nat, FamilyActivity>((Hash.hash, Hash.hash), (Nat.equal, Nat.equal), familyActivityEntries);

  stable var idF: Nat = 0;
  stable var idA: Nat = 0;


  private func keyNat(x : Nat) : Trie.Key<Nat> {
      return { key = x; hash = Hash.hash(x) }
  };

  public func meetingRoom(){
      for(family in Trie.iter(families)){
        var points = family.1.points;
        if(family.1.points >= 10){
           memberForRoom := List.push(family, memberForRoom);
        } else{
          Debug.print(debug_show("Sorry."))
        };
      };
    Debug.print(debug_show(memberForRoom));
  };

  public func getPointsWithRels(activityId: Nat, familyId: Nat){
    var activity = Trie.find(activities, keyNat(activityId), Nat.equal);
    var existsActivity = Option.isSome(activity);
    var family = Trie.find(families, keyNat(familyId), Nat.equal);
    var existsFamily = Option.isSome(family);
    switch(activity) {
      case(null) { 
        Debug.print("Text")
       };
      case(?activity) {
        switch(family) {
          case(null) { 
            Debug.print("Text")
           };
          case(?family) { 
            var newPoints = activity.points + family.points;
            Debug.print(debug_show(newPoints))
          };
        };
       };
    };
  };

  public query func getFamilies(): async Result.Result<[(Nat, Family)], Text>{
  var iterFamilies = Iter.toArray(Trie.iter(families));
  if(iterFamilies == []){
    return #err("Sorry, we can't help you");
  }else{
    return #ok(iterFamilies);
  };
};

public query func getOneFamily(id: Nat): async Result.Result<Family, Text>{
  let familyRes = Trie.find(families, keyNat(id), Nat.equal);
  switch( familyRes ){
    case(null){
      return #err("Sorry, we can't help you");
    };
    case( ?family ){
      return #ok(family);
    };
  };
};

  public func createFamily(family: Types.Family)
  {
    idF += 1;
   let (newFamily, exists): (Trie.Trie<Nat, Family>, ?Family) = Trie.put(families, keyNat(idF), Nat.equal , family);
    if(exists == null){
      families := newFamily;
      Debug.print("Created new family successful!")
    } 
  };

public func updateFamily(id: Nat, family: Family){
  let result = Trie.find(families, keyNat(id), Nat.equal);
  let exists = Option.isSome(result);
  if(exists){
    families := Trie.replace(
      families,
      keyNat(id),
      Nat.equal,
      ?family,
    ).0;
    Debug.print("Family updated successful!");
  } else{
    Debug.print("Sorry, that family doesn't exist");
  };

};

public func removeFamily(id: Nat){
  let result = Trie.find(families, keyNat(id), Nat.equal);
  let exists = Option.isSome(result);
  if(exists){
    families := Trie.replace(
      families,
      keyNat(id),
      Nat.equal,
      null
    ).0;
    Debug.print("Family deleted succesful!");
    Debug.print(debug_show(result));
  }else{
    Debug.print("Sorry, that family doesn't exist");
  };
};


public func createActivity(activity: Activity){
    idA += 1;
    let (newActivity, exists): 
    (Trie.Trie<Nat, Activity>, ?Activity) 
    = Trie.put(
      activities,
      keyNat(idA),
      Nat.equal,
      activity
    );
    if(exists == null){
      activities := newActivity;
      Debug.print("Created activity successful!")
    };
};

public query func readActivities(): async Result.Result<[(Nat, Activity)], Text>{
  let iterActivities = Iter.toArray(Trie.iter(activities));
  if(iterActivities == []){
    return #err("Not found activities");
  } else{
    return #ok(iterActivities);
  };
};

public func readOneActivity(id: Nat): async Result.Result<?Activity, Text>{
  let resActivity = Trie.find(activities, keyNat(id), Nat.equal);
  switch( resActivity ){
    case( null ){
      return #err("Activity not found");
    };
    case( ?activity ){
      return #ok(resActivity);
    };
  };
};

public func updateActivity(id: Nat, activity: Activity){
  let findActivity = Trie.find(activities, keyNat(id), Nat.equal);
  let exists = Option.isSome(findActivity);
  if(exists){
    activities := Trie.replace(
      activities,
      keyNat(id),
      Nat.equal,
      ?activity
    ).0;
  }else{
    Debug.print(debug_show("Sorry, that family doesn't exist"));
  };
};

public func deletedActivity(id: Nat){
  let findActivity = Trie.find(activities, keyNat(id), Nat.equal);
  let exists =  Option.isSome(findActivity);
  if(exists){
    activities := Trie.replace(
      activities,
      keyNat(id),
      Nat.equal,
      null
    ).0;
  }else{
    Debug.print(debug_show("Sorry, that family doesn't exist"));
  };
};

public func assignmentActivity(idFamily: Nat, idActivity: Nat, resultFunc: FamilyActivity){
  familyActivityEntriesRels.put(idFamily, idActivity, resultFunc);
};

public func getRels() : async [(Nat, Nat, FamilyActivity)]{
  familyActivityEntriesRels.getAll();
};

};