local accounts = {}

--- Logs a transaction for a players account.
--- @param transaction table: A table containing transaction details.
local function log_transaction(transaction)
    if not transaction.identifier or not transaction.account_type or not transaction.transaction_type or not transaction.amount then debug_log('error', 'Missing required fields, transaction failed.') return false end
    local query = 'INSERT INTO player_transactions (identifier, account_type, transaction_type, amount, balance_before, balance_after, target_or_sender, note, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
    local params = {
        transaction.identifier,
        transaction.account_type,
        transaction.transaction_type,
        transaction.amount,
        transaction.balance_before or 0,
        transaction.balance_after or 0,
        transaction.target_or_sender or nil,
        transaction.note or nil,
        transaction.metadata and json.encode(transaction.metadata) or nil
    }
    MySQL.insert(query, params, function(success)
        if not success then debug_log('error', ('Failed to log transaction for %s account on %s'):format(transaction.account_type, transaction.identifier)) end
    end)
end

accounts.log_transaction = log_transaction
exports('log_transaction', log_transaction)

return accounts