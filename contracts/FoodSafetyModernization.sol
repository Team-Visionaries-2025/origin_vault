// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract FoodSafetyModernization {
    // Enum to represent the different stages of the product
    enum ProductStage {Created, Processed, InTransit, Delivered}

    struct Product {
    uint256 productId;
    string productName;
    string originLocation;
    string processingDetails;
    address farmer;
    address processor;
    address transporter;
    address retailer;
    ProductStage stage;
    uint256 creationTime;
    string ipfsHash;
    bool isCompleted;
    uint8 reviewCount;  
    uint16 totalRating; 
}


    mapping(uint256 => Product) public products;
    uint256 public productCount;
    mapping(uint256 => string[]) public productReviews; //Store reviews linked to productId

    uint256 public productCount;

    // Mappings to store verification status for each role
    mapping(address => bool) public verifiedFarmers;
    mapping(address => bool) public verifiedProcessors;
    mapping(address => bool) public verifiedTransporters;
    mapping(address => bool) public verifiedRetailers;
    mapping(address => bool) public verifiedConsumers;

    address public owner; //Contract owner

    // Events for tracking various actions
    event ProductCreated(uint256  productId, address  farmer);
    event ProductProcessed(uint256 productId, address processor);
    event ProductInTransit(uint256 productId, address transporter);
    event ProductDelivered(uint256 productId, address retailer);
    event ReviewSubmitted(uint256 productId, address consumer, uint256 rating, string review);
    event UserVerified(address user, string role);

    constructor(){
        owner = msg.sender;
        productCount = 0;
    }

    // modifiers to restrict access to verified users
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyVerifiedFarmer(){
        require(verifiedFarmers[msg.sender], "You are not a verified farmer");
        _;
    }

    modifier onlyVerifiedProcessor(){
        require(verifiedProcessors[msg.sender], "You are not a verified processor");
        _;
    }

    modifier onlyVerifiedTransporter(){
        require(verifiedTransporters[msg.sender], "You are not a verified transporter");
        _;
    }

    modifier onlyVerifiedRetailer() {
        require(verifiedRetailers[msg.sender], "You are not a verified retailer");
        _;
    }

    modifier onlyVerifiedConsumer(){
        require(verifiedConsumers[msg.sender], "You are not a verified consumer");
        _;
    }

    // Function for the owner to verify a usre for a specific role
    function verifyUser(address _user, string memory _role) public onlyOwner{
        if(keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("farmer"))){
            verifiedFarmers[_user] = true;
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("processor"))){
            verifiedProcessors[_user] = true; 
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("transporter"))){
            verifiedTransporters[_user] = true;
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("retailer"))){
            verifiedRetailers[_user] = true;
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("consumer"))){
            verifiedConsumers[_user] = true;
        }

        emit UserVerified(_user, _role);
    }

    // Function to create a new product by the farmer
    function createProduct(
        string memory _productName,
        string memory _originLocation,
        string memory _processingDetails,
        string memory _ipfsHash
    ) public onlyVerifiedFarmer{
        productCount++;

        products[productCount] = Product({
            productId: productCount,
            productName: _productName,
            originLocation: _originLocation,
            processingDetails: _processingDetails,
            farmer: msg.sender,
            processor: address(0),
            transporter: address(0),
            retailer: address(0),
            stage:ProductStage.Created,
            creationTime: block.timestamp,
            ipfsHash: _ipfsHash,
            isCompleted: false,
            reviewCount: 0,
            totalRating: 0
        });

        emit ProductCreated(productCount, msg.sender);
    }

    // Function for the processor to update product processing details
    function processProduct(uint256 _productId) public onlyVerifiedProcessor(){
        Product storage product = products[_productId];
        require(product.stage == ProductStage.Created, "Product is not at creation stage");
        require(msg.sender != product.farmer, "Farmer cannot process product");

        product.processor = msg.sender; // Modifies the state
        product.stage = ProductStage.Processed; // Modifies the state

        emit ProductProcessed(_productId, msg.sender); // Emits an event, also modifies the state
    }

    // Function to start transit of a product (only verified transporters)
    function startTransit(uint256 _productId) public onlyVerifiedTransporter {
        Product storage product = products[_productId];
        require(product.stage == ProductStage.Processed, "Product must be processed first");
        require(msg.sender != product.processor, "Processor cannot transport product");

        product.transporter = msg.sender;
        product.stage = ProductStage.InTransit;

        emit ProductInTransit(_productId, msg.sender);
    }

    // Function for the retailer to mark the product as delivered (only verified retailers)
    function markAsDelivered(uint256 _productId) public onlyVerifiedRetailer {
        Product storage product = products[_productId];
        require(product.stage == ProductStage.InTransit, "Product must be in transit");
        require(msg.sender != product.transporter, "Transporter cannot mark as delivered");

        product.retailer = msg.sender;
        product.stage = ProductStage.Delivered;
        product.isCompleted = true;

        emit ProductDelivered(_productId, msg.sender);
    }

    // function to get  product count
    function getProductCount() public view returns (uint256){
        require(productCount > 0 , "No products have been added yet");
        return productCount;
    }

    // Function for viewing product details
    function productDetails(uint256 _productId) public view returns (
        uint256 id,
        string memory name,
        string memory origin,
        string memory processing,
        address farmer,
        address processor,
        address transporter,
        address retailer,
        ProductStage stage,
        uint256 timestamp,
        string memory ipfs,
        bool completed
    ) {
        // Product storage product = products[_productId];

        // productName = product.productName;
        // originLocation = product.originLocation;
        // processingDetails = product.processingDetails;
        // stage = product.stage;
        // creationTime = product.creationTime;
        // ipfsHash = product.ipfsHash;
        // isCompleted = product.isCompleted;

        require(_productId > 0 && _productId <= productCount, "Invalid product ID");

        Product memory product = products[_productId];

        return (
            product.productId,
            product.productName,
            product.originLocation,
            product.processingDetails,
            product.farmer,
            product.processor,
            product.transporter,
            product.retailer,
            product.stage,
            product.creationTime,
            product.ipfsHash,
            product.isCompleted
        )
    }

    // Function for consumers to submit a review
    function submitReview(uint256 _productId, uint256 _rating, string memory _review) public {
        Product storage product = products[_productId];
        require(product.stage == ProductStage.Delivered, "Product has not been delivered yet");
        require(_rating > 0 && _rating <= 5, "Rating must be between 1 and 5");


        // Update total rating and review count
        product.totalRating += uint16(_rating);
        product.reviewCount ++;

        // Store the review
        productReviews[_productId].push(_review);

        emit ReviewSubmitted(_productId, msg.sender, _rating, _review);
    }

    // Function to get average rating of a product
    function getAverageRating(uint256 _productId) public view returns (uint256){
        Product storage product = products[_productId];
        require(product.reviewCount > 0, "No reviews yet");

        return product.totalRating / product.reviewCount;
    }
    // Function to get all reviews of a product
    function getProductReviews(uint256 _productId) public view returns (string[] memory){
        return productReviews[_productId];
    }
}