//
//  moneroWrapper.cpp
//  XWallet
//
//  Created by loj on 15.08.17.
//

//#include <boost/system/detail/error_code.ipp>

#include "moneroWrapper.h"
#include "Wallet2_api.h"
#include <map>
#include <chrono>

const Scala::NetworkType networkType = Scala::MAINNET;

static Scala::Wallet* monero_wallet;


struct WalletListernerImplementation: Scala::WalletListener
{
    WalletListernerImplementation()
    {
        _refreshedHandler = nullptr;
    }
    
    virtual void moneySpent(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    virtual void moneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }

    virtual void newBlock(uint64_t height)
    {
        if (_newBlockHandler && monero_wallet) {
            _newBlockHandler(_handlerClass, height, monero_wallet->daemonBlockChainHeight());
        }
    }

    virtual void updated()
    {
        // not implemented
    }

    virtual void refreshed()
    {
        if (_refreshedHandler) {
            _refreshedHandler(_handlerClass);
        }
    }
    
    void registerCallbacks(void* handlerClass,
                           callbackActionRefreshed refreshedHandler,
                           callbackActionNewBlock newBlockHandler)
    {
        _handlerClass = handlerClass;
        _refreshedHandler = refreshedHandler;
        _newBlockHandler = newBlockHandler;
    }
    
private:
    callbackActionRefreshed _refreshedHandler = nullptr;
    callbackActionNewBlock _newBlockHandler = nullptr;
    void* _handlerClass = nullptr;
};


static WalletListernerImplementation* monero_walletListener = nullptr;

Scala::WalletManagerFactory::LogLevel monero_logLevel = Scala::WalletManagerFactory::LogLevel_Silent;

bool monero_createWalletFromScatch(const char* pathWithFileName,
                                   const char* password,
                                   const char* language)
{
    Scala::WalletManagerFactory::setLogLevel(monero_logLevel);
    struct Scala::WalletManager *walletManager = Scala::WalletManagerFactory::getWalletManager();
    
    monero_wallet = walletManager->createWallet(pathWithFileName, password, language, networkType);

    return monero_wallet->status() == Scala::Wallet::Status_Ok;
}

bool monero_recoverWalletFromSeed(const char* pathWithFileName,
                                  const char* seed,
                                  const char* password)
{
    Scala::WalletManagerFactory::setLogLevel(monero_logLevel);
    struct Scala::WalletManager *walletManager = Scala::WalletManagerFactory::getWalletManager();

    monero_wallet = walletManager->recoveryWallet(pathWithFileName, seed, networkType);
    if (monero_wallet->status() != Scala::Wallet::Status_Ok) {
        return false;
    }
    
    bool setPasswordState = monero_wallet->setPassword(password);
    return setPasswordState;
}

bool monero_openExistingWallet(const char* pathWithFileName, const char* password)
{
#ifdef DEBUG
    auto start = std::chrono::high_resolution_clock::now();
#endif

    Scala::WalletManagerFactory::setLogLevel(monero_logLevel);
    Scala::WalletManagerFactory::setLogCategories("");
    struct Scala::WalletManager *walletManager = Scala::WalletManagerFactory::getWalletManager();
    monero_wallet = walletManager->openWallet(pathWithFileName, password, networkType);
#ifdef DEBUG
    auto finish = std::chrono::high_resolution_clock::now();
    auto microseconds = std::chrono::duration_cast<std::chrono::milliseconds>(finish-start);
    std::cout << "[SCALA]   " << "Opening wallet takes about : " << microseconds.count() << "ms\n";
#endif
    return monero_wallet->status() == Scala::Wallet::Status_Ok;
}

bool monero_closeWallet() {
    if (!monero_wallet) {
        return false;
    }
    
    struct Scala::WalletManager *walletManager = Scala::WalletManagerFactory::getWalletManager();
    bool result = walletManager->closeWallet(monero_wallet);
    monero_wallet = nullptr;
    
    return result;
}

const char* monero_getPublicAddress()
{
    std::string publicAddress = "";
    
    if (monero_wallet) {
        publicAddress = monero_wallet->address();
    }
    
    const char* cstr = publicAddress.c_str();
    
    return strdup(cstr);
}

const char* monero_getSeed(const char* language)
{
    std::string seed = "";
    
    if (monero_wallet) {
        monero_wallet->setSeedLanguage(language);
        seed = monero_wallet->seed();
    }
    
    const char* cstr = seed.c_str();
    
    return strdup(cstr);
}

bool monero_init(const char* daemonAddress,
                 uint64_t upperTransactionSizeLimit,
                 const char* daemonUsername,
                 const char* daemonPassword)
{
    if (!monero_wallet) {
        return false;
    }

    const bool useSSL = false;
    const bool lightWallet = false;
    bool status = monero_wallet->init(daemonAddress, upperTransactionSizeLimit, daemonUsername, daemonPassword, useSSL, lightWallet);
    return status;
}

void monero_registerListenerCallbacks(void* handlerClass,
                                      callbackActionRefreshed refreshedHandler,
                                      callbackActionNewBlock newBlockHandler)
{
    if (!monero_wallet) {
        return;
    }

    monero_deregisterListenerCallbacks();
    monero_walletListener = new WalletListernerImplementation();
    monero_walletListener->registerCallbacks(handlerClass, refreshedHandler, newBlockHandler);
    
    monero_wallet->setListener(monero_walletListener);
}

void monero_deregisterListenerCallbacks()
{
    if (!monero_wallet) {
        return;
    }
    
    if (monero_walletListener) {
        monero_wallet->setListener(nullptr);
        delete monero_walletListener;
    }
}


enum monero_connectionStatus connectionStatus()
{
    if (!monero_wallet) {
        return ConnectionStatus_Disconnected;
    }
    
    return (monero_connectionStatus)monero_wallet->connected();
}

int monero_status() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->status();
}

const char* monero_errorString() {
    std::string errorString = "";
    
    if (monero_wallet) {
        errorString = monero_wallet->errorString();
    }
    
    const char* cstr = errorString.c_str();
    
    return strdup(cstr);

}

void monero_startRefresh()
{
    if (monero_wallet) {
        monero_wallet->startRefresh();
    }
}

void monero_pauseRefresh()
{
    if (monero_wallet) {
        monero_wallet->pauseRefresh();
    }
}

void monero_refresh() {
    if (monero_wallet) {
        monero_wallet->refresh();
    }
}

bool monero_setNewPassword(const char* newPassword) {
    if (monero_wallet) {
        return monero_wallet->setPassword(newPassword);
    }
    return false;
}

uint64_t monero_getBalance()
{
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->balance();
}

uint64_t monero_getUnlockedBalance() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->unlockedBalance();
}

uint64_t monero_getBlockchainHeight() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->blockChainHeight();
}

uint64_t monero_getDaemonBlockChainHeight() {
    if (!monero_wallet) {
        return 0;
    }
    return monero_wallet->daemonBlockChainHeight();
}

monero_history* monero_getTrxHistory(uint64_t max_records) {
    monero_history *moneroHistory = new monero_history;
    moneroHistory->numberOfTransactions = 0;

    if (!monero_wallet) {
        return moneroHistory;
    }
    

    Scala::TransactionHistory *history = monero_wallet->history();
    if (!history) {
        return moneroHistory;
    }
    try{
        history->refresh();
    }catch(...){
        return moneroHistory;
    }
    
    int historyCount = history->count();
    std::vector<Scala::TransactionInfo *> allTransactionInfo;
    if(max_records > 0 && historyCount > max_records){
        for (int i = 0; i < max_records; ++i) {
            Scala::TransactionInfo * historyInfo = history->transaction(i);
            allTransactionInfo.push_back(historyInfo);
        }
    } else {
        allTransactionInfo = history->getAll();
    }

    moneroHistory->numberOfTransactions = allTransactionInfo.size();

    moneroHistory->transactions = new monero_trx*[moneroHistory->numberOfTransactions];
    
    for (std::size_t i = 0; i < moneroHistory->numberOfTransactions; ++i) {
        try{
            Scala::TransactionInfo *transactionInfo = allTransactionInfo[i];
            monero_trx *trx = new monero_trx;
            trx->direction = (monero_trxDirection)transactionInfo->direction();
            trx->isPending = transactionInfo->isPending();
            trx->isFailed = transactionInfo->isFailed();
            trx->amount = transactionInfo->amount();
            trx->fee = transactionInfo->fee();
            trx->confirmations = transactionInfo->confirmations();
            trx->timestamp = transactionInfo->timestamp();
            trx->height = transactionInfo->blockHeight();
            //std::cout << "Transaction amount : " << trx->amount << '\n';
            moneroHistory->transactions[i] = trx;
        } catch(...) {
#ifdef DEBUG
        std::cout << "ERROR FETCHING HISTORY \n";
        std::cout << monero_errorString() << "\n";
#endif
            continue;
        }
    }
    
    return moneroHistory;
}

void monero_deleteHistory(monero_history* history)
{
    if (history == nullptr) {
        return;
    }
    if (history->transactions != nullptr) {
        delete [] history->transactions;
    }
    
    delete history;
}

bool monero_isValidWalletAddress(const char* walletAddress)
{
    if (!monero_wallet) {
        return false;
    }
    
    return Scala::Wallet::addressValid(walletAddress, networkType);
}

bool monero_isValidPaymentId(const char* paymentId)
{
    if (!monero_wallet) {
        return false;
    }
    
    return monero_wallet->paymentIdValid(paymentId);
}

// ----------------------------------------------------------------------------
// Transactions
// ----------------------------------------------------------------------------

static std::map<uint64_t, Scala::PendingTransaction*> pendingTransactions;
static int64_t nextPendingTransactionKey = 1;

/// Returns a key which must be deleted after usage.
int64_t monero_createTransaction(const char* dstAddress,
                                 const char* paymentId,
                                 uint64_t amount,
                                 uint32_t mixinCount,
                                 enum monero_pendingTransactionPriority priority)
{
    
    if (!monero_wallet) {
#ifdef DEBUG
        std::cout << "ERROR MONERO WALLET NOT FOUND" << "\n";
#endif
        return -1;
    }
    
    Scala::PendingTransaction *pendingTransaction = monero_wallet->createTransaction
    (dstAddress,
     paymentId,
     amount,
     mixinCount,
     (Scala::PendingTransaction::Priority)priority);
    
    if (!pendingTransaction) {
#ifdef DEBUG
        std::cout << "ERROR NO PENDING TRANSACTION" << "\n";
#endif
        return -1;
    }
    if (pendingTransaction->status() != Status_Ok) {
#ifdef DEBUG
        std::cout << "ERROR PENDING TRANSACTION STATUS NOT OK "  << pendingTransaction->status() << "\n";
        std::cout << monero_errorString() << "\n";
#endif
        return -1;
    }

    int64_t key = nextPendingTransactionKey++;
    pendingTransactions[key] = pendingTransaction;
    
    return key;
}

int64_t monero_getTransactionFee(int64_t key)
{
    std::map<uint64_t, Scala::PendingTransaction*>::iterator it;
    it = pendingTransactions.find(key);
    if (it != pendingTransactions.end()) {
        return it->second->fee();
    }
    
    return -1;
}

void monero_commitPendingTransaction(int64_t key)
{
    std::map<uint64_t, Scala::PendingTransaction*>::iterator it;
    it = pendingTransactions.find(key);
    if (it != pendingTransactions.end()) {
        it->second->commit();
    }
}


void monero_setRefreshFromBlockHeight(uint64_t height) {
    if (!monero_wallet) {
        return;
    }
    
    return monero_wallet->setRefreshFromBlockHeight(height);
}

void monero_rescan(){
    if (!monero_wallet) {
        return;
    }
    monero_wallet->setRefreshFromBlockHeight(0);
    monero_wallet->rescanBlockchainAsync();
}









