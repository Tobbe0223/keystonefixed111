local accounts_function = get_module('accounts')

Accounts = {}

Accounts.__index = Accounts

--- Creates a new Accounts instance for the given player.
--- @param player table: The player instance.
--- @return table: The new Accounts object.
function Accounts.new(player)
    if player.accounts then return player.accounts end
    return setmetatable({ player = player }, Accounts)
end

--- Retrieves all accounts of the player.
--- @return table: A table containing all the players accounts.
function Accounts:get_accounts()
    return self.player._data.accounts or {}
end

exports('get_accounts', function(source)
    local player = player_registry[source]
    if not player then return nil end
    return player.accounts:get_accounts()
end)

--- Retrieves a specific account of the player.
--- @param account string: The name of the account to retrieve.
--- @return table|nil: The account data if found, or nil if not found.
function Accounts:get_account(account)
    return self.player._data.accounts[account] or nil
end

exports('get_account', function(source, account)
    local player = player_registry[source]
    if not player then return nil end
    return player.accounts:get_account(account)
end)

--- Checks if the player has at least a specified amount in an account.
--- @param account string: The account name to check.
--- @param amount number: The amount to check for.
--- @return boolean: True if the player has the required balance, false otherwise.
function Accounts:has_balance(account, amount)
    local acc = self:get_account(account)
    return acc and acc.balance >= amount
end

exports('has_balance', function(source, account, amount)
    local player = player_registry[source]
    if not player then return false end
    return player.accounts:has_balance(account, amount)
end)

--- Adds money to a players account and logs the transaction.
--- @param account string: The account name to add money to.
--- @param amount number: The amount to add.
--- @param sender string|nil: The senders identifier if applicable.
--- @param note string|nil: Optional note explaining the transaction.
--- @return boolean: True if money was added successfully, false otherwise.
function Accounts:add_money(account, amount, sender, note)
    if amount < 0 then return false end
    local acc = self:get_account(account)
    if not acc then return false end
    local balance_before = acc.balance
    acc.balance = acc.balance + amount
    accounts_function.log_transaction({
        identifier = self.player.identifier,
        account_type = account,
        transaction_type = sender and 'transfer' or 'deposit',
        amount = amount,
        balance_before = balance_before,
        balance_after = acc.balance,
        target_or_sender = sender or nil,
        note = note or nil
    })
    return true
end

exports('add_money', function(source, account, amount, sender, note)
    local player = player_registry[source]
    if not player then return false end
    return player.accounts:add_money(account, amount, sender, note)
end)

--- Removes money from a players account and logs the transaction.
--- @param account string: The account name to remove money from.
--- @param amount number: The amount to remove.
--- @param recipient string|nil: The recipients identifier if applicable.
--- @param note string|nil: Optional note explaining the transaction.
--- @return boolean: True if money was removed successfully, false otherwise.
function Accounts:remove_money(account, amount, recipient, note)
    if amount < 0 then return false end
    local acc = self:get_account(account)
    if not acc or acc.balance < amount then return false end
    local balance_before = acc.balance
    acc.balance = acc.balance - amount
    accounts_function.log_transaction({
        identifier = self.player.identifier,
        account_type = account,
        transaction_type = recipient and 'transfer' or 'withdraw',
        amount = amount,
        balance_before = balance_before,
        balance_after = acc.balance,
        target_or_sender = recipient or nil,
        note = note or nil
    })
    return true
end

exports('remove_money', function(source, account, amount, recipient, note)
    local player = player_registry[source]
    if not player then return false end
    return player.accounts:remove_money(account, amount, recipient, note)
end)