pragma solidity ^0.4.6;

contract SupplyChainFactory
{
    address[] public deployedSupplyChains;

    function createSupplyChain(string buyerName, string orderDescription, uint orderPrice) public payable {

        address newSupplyChain = (new SupplyChain).value(msg.value)(msg.sender, buyerName, orderDescription, orderPrice);
        deployedSupplyChains.push(newSupplyChain);

    }

    function getDeployedSupplyChains() public view returns (address[]) {

        return deployedSupplyChains;

    }
}

contract SupplyChain
{
    struct Order
    {
        string Number;
        string Description;
        uint Price;
        string Status; // Placed, Accepted, Rejected, ShippingInProgress, ShippingFinished, Closed
        string StatusMessage;
    }

    struct Shipping
    {
        uint Number;
        string Status; // NotStarted, InProgress, Cancelled, ReplacedByNewShipping, ConfirmedSuccessfull
    }

    struct ShippingStep
    {
        uint ShippingNumber;
        string Company;
        address CompanyAddress;
        string Location;
        uint256 Timestamp;
        string StatusMessage;
        string PackageStatus; // OK (default), Lost, Damaged
    }

    Order order;
    Shipping[] shippings;
    ShippingStep[] shippingSteps;

    string buyer;
    string seller;

    address buyerAddress;
    address sellerAddress;

    address temporaryMoneyStorageAddress; //set default value

    constructor (address creatorAddress, string buyerName, string orderDescription, uint orderPrice) public payable {

        buyerAddress = creatorAddress;
        buyer = buyerName;
        order.Description = orderDescription;
        order.Price = orderPrice;
        order.Status = "Placed";

        // send money from buyerAddress to temporaryMoneyStorageAddress (contract)
        //buyerAddress.transfer(orderPrice);

    }

    function rejectOrder(string orderStatusMessage) public payable {

        order.Status = "Rejected";
        order.StatusMessage = orderStatusMessage;

        // return money from temporaryMoneyStorageAddress (contract) to buyerAddress
        //buyerAddress.transfer(order.Price);

    }

    function startShipping(string shippingCompany, address shippingCompanyAddress, string statusMessage, string location) public {

        order.Status = "Shipping In Progress";
        order.Number = "123456789"; // hardcoded for now

        Shipping memory s;
        s.Number = shippings.length + 1000;
        s.Status = "In Progress";
        shippings.push(s);

        ShippingStep memory ss;
        ss.ShippingNumber = s.Number;
        ss.Company = shippingCompany;
        ss.CompanyAddress = shippingCompanyAddress;
        ss.Location = location;
        ss.Timestamp = now;
        ss.StatusMessage = statusMessage;
        ss.PackageStatus = "OK";
        shippingSteps.push(ss);

    }

    function updateShipping(string shippingCompany, address shippingCompanyAddress, string statusMessage, string location, string packageStatus) public {

        ShippingStep memory ss;
        ss.ShippingNumber = shippings[shippings.length - 1].Number;
        ss.Company = shippingCompany;
        ss.CompanyAddress = shippingCompanyAddress;
        ss.Location = location;
        ss.Timestamp = now;
        ss.StatusMessage = statusMessage;
        ss.PackageStatus = packageStatus;
        shippingSteps.push(ss);

    }

    function confirmReceivedByBuyer(string statusMessage, string location) public payable {

        order.Status = "Shipping Finished";
        shippings[shippings.length - 1].Status = "Confirmed Successfull";

        ShippingStep memory ss;
        ss.ShippingNumber = shippings[shippings.length - 1].Number;
        ss.Company = buyer;
        ss.CompanyAddress = buyerAddress;
        ss.Location = location;
        ss.Timestamp = now;
        ss.StatusMessage = statusMessage;
        ss.PackageStatus = "";
        shippingSteps.push(ss);

        // send money from temporaryMoneyStorageAddress (contract) to sellerAddress
        //sellerAddress.transfer(order.Price);

    }

    function getOrderInfo() public view returns (string, string, string, string, uint) {

        return (buyer, seller, order.Number, order.Description, order.Price);

    }

    function getOrderStatus() public view returns (string) {

        return order.Status;

    }

    function getShippingStatus() public view returns (string) {

        return shippings[shippings.length - 1].Status;

    }

    function getShippingEntitiesCount() public view returns (uint) {

        return shippingSteps.length;

    }

    function getShippingEntity(uint index) public view returns (string) {

        return shippingSteps[index].Company;

    }

    function getTimestamp(uint index) public view returns (uint256) {

        return shippingSteps[index].Timestamp;

    }

    function getCurrentHolder() public view returns (string) {

        uint shippingStepsCount = shippingSteps.length;
        if (shippingStepsCount > 0) {
            return shippingSteps[shippingStepsCount - 1].Company;
        }
        else {
            return "";
        }

    }

    function refund() public payable {

        // send money from temporaryMoneyStorageAddress (contract) to buyer
        //buyerAddress.transfer(order.Price);

    }

    function closeOrder() public {

        order.Status = "Closed";

    }

}
