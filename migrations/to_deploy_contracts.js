const FoodSafetyModernization = artifacts.require("FoodSafetyModernization");

export default function(deployer){
    deployer.deploy(FoodSafetyModernization);
};