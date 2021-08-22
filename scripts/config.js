const dotenv = require('dotenv');
dotenv.config();


module.exports = {
    mnemonic = process.env.SEED_PHRASE,
    url = process.env.NETWORK_URL,
    pri_key_1 = process.env.PRIVATE_KEY_1,
    pri_key_2 = process.env.PRIVATE_KEY_2,
    private_keys = [pri_key_1, pri_key_2]
};
