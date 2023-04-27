//
//  moneroWrapper.hpp
//  XWallet
//
//  Created by loj on 15.08.17.
//

#ifndef moneroWrapper_h
#define moneroWrapper_h

#include "stdbool.h"
#include "stdint.h"
#include "time.h"
#include <uuid/uuid.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    enum monero_status {
        Status_Ok,
        Status_Error,
        Status_Critical
    };
    
    enum monero_connectionStatus {
        ConnectionStatus_Disconnected,
        ConnectionStatus_Connected,
        ConnectionStatus_WrongVersion
    };

    enum monero_trxDirection
    {
        Direction_In,
        Direction_Out
    };
    
    enum monero_pendingTransactionPriority {
        PendingTransactionPriority_Low = 1,
        PendingTransactionPriority_Medium = 2,
        PendingTransactionPriority_High = 3,
        PendingTransactionPriority_Last
    };
    
    struct monero_trx
    {
        enum monero_trxDirection direction;
        bool isPending;
        bool isFailed;
        uint64_t amount;
        uint64_t fee;
        uint64_t confirmations;
        time_t timestamp;
        uint64_t height;
    };
    
    struct monero_history
    {
        uint64_t numberOfTransactions;
        struct monero_trx** transactions;
    };
    
    typedef void (*callbackActionRefreshed)(void*);
    typedef void (*callbackActionNewBlock)(void*, uint64_t curreneight, uint64_t blockChainHeight);

    // Init wallet
    // ----------------------------------------------------------------------------

    bool monero_createWalletFromScatch(const char* pathWithFileName,
                                       const char* password,
                                       const char* language);
    bool monero_recoverWalletFromSeed(const char* pathWithFileName,
                                      const char* seed,
                                      const char* password);
    bool monero_openExistingWallet(const char* pathWithFileName,
                                   const char* password);
    bool monero_closeWallet();

    bool monero_init(const char* daemonAddress,
                     uint64_t upperTransactionSizeLimit,
                     const char* daemonUsername,    // provide "" for no username
                     const char* daemonPassword);   // provide "" for no password
    
    void monero_registerListenerCallbacks(void* handlerClass,
                                          callbackActionRefreshed refreshedHandler,
                                          callbackActionNewBlock newBlockHandler);
    void monero_deregisterListenerCallbacks();

    // Wallet info
    // ----------------------------------------------------------------------------

    const char* monero_getPublicAddress();
    const char* monero_getSeed(const char* language);
    enum monero_connectionStatus connectionStatus();
    int monero_status();
    const char* monero_errorString();
    uint64_t monero_getBlockchainHeight();
    uint64_t monero_getDaemonBlockChainHeight();
    
    // Wallet actions
    // ----------------------------------------------------------------------------

    void monero_startRefresh();
    void monero_pauseRefresh();
    void monero_refresh();
    bool monero_setNewPassword(const char* newPassword);

    // Wallet Balance
    // ----------------------------------------------------------------------------

    uint64_t monero_getBalance();
    uint64_t monero_getUnlockedBalance();
    struct monero_history* monero_getTrxHistory(uint64_t max_records);
    void monero_deleteHistory(struct monero_history* history);
    
    // Transactions
    // ----------------------------------------------------------------------------

    // return key < 0 if unsuccessful
    int64_t monero_createTransaction(const char* dstAddress,
                                     const char* paymentId,
                                     uint64_t amount,
                                     uint32_t mixinCount,
                                     enum monero_pendingTransactionPriority priority);
    
    // return value < 0 if no pending transaction found for key
    int64_t monero_getTransactionFee(int64_t key);
    
    // does nothing if no pending transaction for key
    void monero_commitPendingTransaction(int64_t key);
    
    // Helpers
    // ----------------------------------------------------------------------------

    bool monero_isValidWalletAddress(const char* walletAddress);
    bool monero_isValidPaymentId(const char* paymentId);
    
    void monero_printBlockChainHeight();
    void monero_setRefreshFromBlockHeight(uint64_t height);
    void monero_rescan();
#ifdef __cplusplus
}
#endif

#endif /* moneroWrapper_h */
