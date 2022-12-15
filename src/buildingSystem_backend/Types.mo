import List "mo:base/List";
import Trie "mo:base/Trie";


// Documento para definir los types (objetos)

module{

    //Type for Family
    public type Family = {
        familyName: Text;
        buildingFloor: Nat;
        m2: Float;
        points: Nat;
        members: Nat;
    };

    //Type for Activitys
    public type Activity = {
        name: Text;
        points: Nat;
    };
};