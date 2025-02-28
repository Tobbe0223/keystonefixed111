return {
    test = {
        account_type = 'test',
        label = 'Test Account',
        balance = 200000,
        allow_negative = true,
        interest_rate = 5.00,
        interest_interval_hours = 1,
        metadata = {}
    },

    general = {
        account_type = 'general',
        label = 'General',
        balance = 10000,
        allow_negative = true,
        interest_rate = 0.01,
        interest_interval_hours = 24,
        metadata = {}
    },

    savings = {
        account_type = 'savings',
        label = 'Savings',
        balance = 0,
        allow_negative = false,
        interest_rate = 0.50,
        interest_interval_hours = 24,
        metadata = {}
    }
}
