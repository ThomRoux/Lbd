/*********************************************************************************************************************
    liberlandMerit
**********************************************************************************************************************/
contract liberlandMerit {
    
    address public owner;
    address public centralBank;
    mapping (address=>bool) public banks;
    
    mapping (address=>uint) public meritBalanceOf;
    
    modifier onlyOwner { if (msg.sender == owner) _ }
    modifier onlyCentralBank { if (msg.sender == centralBank) _ }
    modifier onlyBank { if (msg.sender == centralBank || banks[msg.sender] == true) _ }
    
    event CentralBankChanged(address _address);
    event BankAdded(address _address);
    event BankRemoved(address _address);
    
    function liberlandMerit() {
        owner = msg.sender;
        centralBank = owner;
        createMerit(100000);
    }
    
    function kill() onlyOwner {
        suicide(owner); 
    }
    
    function changeCentralBank(address _address) onlyOwner {
        meritBalanceOf[_address] += meritBalanceOf[centralBank];
        meritBalanceOf[centralBank] = 0;
        centralBank = _address;
        CentralBankChanged(_address);
    }
    
    function addBank(address _address) onlyCentralBank {
        banks[_address] = true;
        BankAdded(_address);
    }
    
    function removeBank(address _address) onlyCentralBank {
        banks[_address] = false;
        BankRemoved(_address);
    }
    
    function sendMerit(address to, uint value) returns (bool sufficient){
        if (meritBalanceOf[msg.sender] >= value) {
            meritBalanceOf[msg.sender] -= value;
            meritBalanceOf[to] += value; 
            return true;
        } else {
            return false;
        }
    }
    
    function createMerit(uint value) onlyCentralBank {
        meritBalanceOf[centralBank] += value;
    }
    
    function creditMerit(address to, uint value) onlyBank {
        if (to != msg.sender) meritBalanceOf[to] += value;
    }
    
}

/*********************************************************************************************************************
    liberlandCitizenship
**********************************************************************************************************************/
contract liberlandCitizenship {
    
    address public owner;
    mapping (address=>bool) public isCitizen;
    mapping (address=>PersonalData) public datas;
    liberlandMerit public merits;
    uint public meritCost;
    
    struct PersonalData {
        string firstName;
        string lastName;
        uint birthDate;
        string mailAddress;
        string email;
    }
    
    modifier onlyOwner { if (msg.sender == owner) _ }
    modifier onlyCitizen { if (isCitizen[msg.sender]) _ }
    
    function liberlandCitizenship(address meritAddress, uint cost) {
        owner = msg.sender;
        merits = liberlandMerit(meritAddress);
        meritCost = cost;
    }
    
    function requestCitizenship(string _firstName, string _lastName, uint _birthDate, string _mailAddress, string _email) {
        if (merits.meritBalanceOf(msg.sender) >= meritCost) {
            merits.sendMerit(owner,meritCost);
            isCitizen[msg.sender] = true;
            datas[msg.sender] = PersonalData(_firstName, _lastName, _birthDate, _mailAddress, _email);
        }
    }
    
    function revoqueCitizenship(address citizen) onlyOwner {
        isCitizen[citizen] = false;
    }
    
    function kill() onlyOwner {
        suicide(owner);
    }
    
    function updateMailAddress(string _address) onlyCitizen {
        datas[msg.sender].mailAddress = _address;
    }
    
    function updateEMail(string _address) onlyCitizen {
        datas[msg.sender].email = _address;
    }
    
}


/*********************************************************************************************************************
    liberlandTasks
**********************************************************************************************************************/
contract liberlandTasks {
    
    address public owner;
    
    modifier onlyOwner { if (msg.sender == owner) _ }
    
    function liberlandTasks() {
        owner = msg.sender;
    }
    
    function kill() onlyOwner {
        suicide(owner);
    }
    
}


/*********************************************************************************************************************
    liberlandDAO
**********************************************************************************************************************/
contract liberlandDAO {
    
    address public owner;
    liberlandCitizenship public citizens;
    
    
    modifier onlyOwner { if (msg.sender == owner) _ }
    
    function liberlandDAO() {
        owner = msg.sender;
    }
    
    function kill() onlyOwner {
        suicide(owner);
    }
}
