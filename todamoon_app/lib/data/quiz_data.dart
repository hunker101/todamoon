class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String moduleId;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.moduleId,
  });
}


final Map<String, List<QuizQuestion>> moduleQuizQuestions = {
  'introduction': [
  QuizQuestion(
    question: 'What makes cryptocurrencies decentralized?',
    options: ['They are digital', 'No government or central bank controls them', 'They use the internet', 'They are encrypted'],
    correctAnswer: 'No government or central bank controls them',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'What does the prefix "crypt" mean in cryptocurrency?',
    options: ['Digital', 'Hidden', 'Secure', 'Fast'],
    correctAnswer: 'Hidden',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'How are cryptocurrencies most commonly used today?',
    options: ['As payment for goods and services', 'As financial assets for trading and investing', 'As replacement for banks', 'As digital receipts'],
    correctAnswer: 'As financial assets for trading and investing',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'What was the first cryptocurrency?',
    options: ['Ethereum', 'Dogecoin', 'Bitcoin', 'Litecoin'],
    correctAnswer: 'Bitcoin',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'What makes cryptocurrencies "borderless"?',
    options: ['They have no transaction fees', 'They can be sent globally with just internet access', 'They are not regulated', 'They are anonymous'],
    correctAnswer: 'They can be sent globally with just internet access',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'What does "permissionless" mean in cryptocurrency?',
    options: ['No fees required', 'Anyone can use them without approval', 'They are completely anonymous', 'No internet needed'],
    correctAnswer: 'Anyone can use them without approval',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'Who creates new units of cryptocurrency?',
    options: ['Central banks', 'Governments', 'Software following predetermined rules', 'Cryptocurrency exchanges'],
    correctAnswer: 'Software following predetermined rules',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'What is a "fiat" currency?',
    options: ['Digital money', 'Traditional currency controlled by governments/banks', 'Cryptocurrency', 'Online payment system'],
    correctAnswer: 'Traditional currency controlled by governments/banks',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'How does the crypto market differ from the forex market in terms of operating hours?',
    options: ['Crypto closes on weekends', 'Forex is open 24/7', 'Crypto is open 24/7, forex closes on weekends', 'They have the same hours'],
    correctAnswer: 'Crypto is open 24/7, forex closes on weekends',
    moduleId: 'introduction',
  ),
  QuizQuestion(
    question: 'What should be your approach when entering the crypto market?',
    options: ['Buy any coin that promises to change the world', 'Treat it as a sure bet for automatic money growth', 'Understand the technology before investing', 'Follow social media recommendations'],
    correctAnswer: 'Understand the technology before investing',
    moduleId: 'introduction',
  ),
],
  
  'bitcoin': [
    QuizQuestion(
      question: 'Who created Bitcoin and when was it first introduced?',
      options: ['Vitalik Buterin in 2009', 'Satoshi Nakamoto in 2008', 'Elon Musk in 2010', 'Mark Zuckerberg in 2007'],
      correctAnswer: 'Satoshi Nakamoto in 2008',
      moduleId: 'bitcoin',
    ),
    QuizQuestion(
      question: 'What is the maximum supply of Bitcoin that will ever exist?',
      options: ['100 million', '50 million', '21 million', 'Unlimited'],
      correctAnswer: '21 million',
      moduleId: 'bitcoin',
    ),
    QuizQuestion(
      question: 'What was the main problem Bitcoin was designed to solve?',
      options: ['Making money faster', 'Allowing online payments without going through financial institutions', 'Creating cheaper transactions', 'Making money anonymous'],
      correctAnswer: 'Allowing online payments without going through financial institutions',
      moduleId: 'bitcoin',
    ),
    QuizQuestion(
      question: 'What does "decentralized" mean in the context of Bitcoin?',
      options: ['It uses advanced encryption', 'No single entity or authority controls it', 'It operates only on weekends', 'It requires government approval'],
      correctAnswer: 'No single entity or authority controls it',
      moduleId: 'bitcoin',
    ),
    QuizQuestion(
      question: 'What is the most secure type of Bitcoin wallet for long-term storage?',
      options: ['Web wallets', 'Exchange wallets', 'Cold wallets (hardware/paper wallets)', 'Mobile wallets'],
      correctAnswer: 'Cold wallets (hardware/paper wallets)',
      moduleId: 'bitcoin',
    ),
  ],

   'hashing': [
    QuizQuestion(
      question: 'What is the "avalanche effect" in cryptographic hash functions?',
      options: ['Hashes become larger over time', 'Small input changes cause dramatic output changes', 'Multiple inputs produce the same hash', 'Hash functions become faster'],
      correctAnswer: 'Small input changes cause dramatic output changes',
      moduleId: 'hashing',
    ),
    QuizQuestion(
      question: 'Which hash function does Bitcoin use?',
      options: ['MD5', 'SHA-256', 'Keccak-256', 'Scrypt'],
      correctAnswer: 'SHA-256',
      moduleId: 'hashing',
    ),
    QuizQuestion(
      question: 'How do blocks in a blockchain reference each other?',
      options: ['Through timestamps', 'Each block contains the hash of the previous block', 'Through transaction IDs', 'Through wallet addresses'],
      correctAnswer: 'Each block contains the hash of the previous block',
      moduleId: 'hashing',
    ),
    QuizQuestion(
      question: 'In Proof of Work mining, what are miners trying to find?',
      options: ['The fastest transaction', 'A hash that meets specific criteria (like starting with zeros)', 'The largest block size', 'The oldest transaction'],
      correctAnswer: 'A hash that meets specific criteria (like starting with zeros)',
      moduleId: 'hashing',
    ),
    QuizQuestion(
      question: 'What is a key security benefit of hash functions in blockchain?',
      options: ['They make transactions faster', 'They provide immutability - changing old data would require enormous computational power', 'They reduce transaction fees', 'They make wallets more user-friendly'],
      correctAnswer: 'They provide immutability - changing old data would require enormous computational power',
      moduleId: 'hashing',
    ),
  ],
  'blockchain': [
    QuizQuestion(
      question: 'What is a blockchain best described as?',
      options: ['A single computer storing data', 'A distributed ledger copied across many computers', 'A centralized database', 'A type of cryptocurrency'],
      correctAnswer: 'A distributed ledger copied across many computers',
      moduleId: 'blockchain',
    ),
    QuizQuestion(
      question: 'What consensus mechanism does Bitcoin use?',
      options: ['Proof of Stake', 'Proof of Work', 'Delegated Proof of Stake', 'Proof of Authority'],
      correctAnswer: 'Proof of Work',
      moduleId: 'blockchain',
    ),
    QuizQuestion(
      question: 'What is the main advantage of Proof of Stake over Proof of Work?',
      options: ['More secure', 'Much more energy efficient', 'Completely decentralized', 'Faster mining'],
      correctAnswer: 'Much more energy efficient',
      moduleId: 'blockchain',
    ),
    QuizQuestion(
      question: 'What is a Merkle Tree used for in blockchain?',
      options: ['Storing user passwords', 'Efficiently summarizing all transactions in a block', 'Creating new cryptocurrencies', 'Managing user wallets'],
      correctAnswer: 'Efficiently summarizing all transactions in a block',
      moduleId: 'blockchain',
    ),
    QuizQuestion(
      question: 'Beyond cryptocurrency, blockchain technology can be applied to:',
      options: ['Only financial services', 'Supply chain management and digital identity', 'Only gaming applications', 'Only voting systems'],
      correctAnswer: 'Supply chain management and digital identity',
      moduleId: 'blockchain',
    ),
  ],
  'altcoins': [
  QuizQuestion(
    question: 'What does "altcoin" stand for?',
    options: ['Alternative coin', 'Advanced coin', 'Algorithmic coin', 'Automated coin'],
    correctAnswer: 'Alternative coin',
    moduleId: 'altcoins',
  ),
  QuizQuestion(
    question: 'Which was the first blockchain to successfully implement smart contracts at scale?',
    options: ['Bitcoin', 'Ethereum', 'Litecoin', 'Cardano'],
    correctAnswer: 'Ethereum',
    moduleId: 'altcoins',
  ),
  QuizQuestion(
    question: 'What are stablecoins designed to do?',
    options: ['Increase in value over time', 'Maintain stable value relative to reference assets', 'Enable smart contracts', 'Provide enhanced privacy'],
    correctAnswer: 'Maintain stable value relative to reference assets',
    moduleId: 'altcoins',
  ),
  QuizQuestion(
    question: 'Which privacy coin uses ring signatures and stealth addresses?',
    options: ['Zcash', 'Dash', 'Monero', 'Litecoin'],
    correctAnswer: 'Monero',
    moduleId: 'altcoins',
  ),
  QuizQuestion(
    question: 'What is the primary purpose of oracle tokens like Chainlink?',
    options: ['Enable faster payments', 'Provide stable value storage', 'Connect blockchains to real-world data', 'Create meme-based communities'],
    correctAnswer: 'Connect blockchains to real-world data',
    moduleId: 'altcoins',
  ),
],
'crypto_exchanges': [
  QuizQuestion(
    question: 'What is the main difference between centralized and decentralized exchanges?',
    options: ['Centralized exchanges are faster', 'Centralized exchanges hold user funds while decentralized exchanges let users maintain control', 'Decentralized exchanges have better customer support', 'Centralized exchanges only trade Bitcoin'],
    correctAnswer: 'Centralized exchanges hold user funds while decentralized exchanges let users maintain control',
    moduleId: 'crypto_exchanges',
  ),
  QuizQuestion(
    question: 'What type of order executes immediately at the current market price?',
    options: ['Limit Order', 'Stop Order', 'Market Order', 'Stop-Limit Order'],
    correctAnswer: 'Market Order',
    moduleId: 'crypto_exchanges',
  ),
  QuizQuestion(
    question: 'Which security practice is most recommended for protecting exchange accounts?',
    options: ['Using SMS for two-factor authentication', 'Keeping all funds on the exchange for convenience', 'Enabling 2FA with an authenticator app and using strong passwords', 'Sharing account credentials with trusted friends'],
    correctAnswer: 'Enabling 2FA with an authenticator app and using strong passwords',
    moduleId: 'crypto_exchanges',
  ),
  QuizQuestion(
    question: 'What does "Not your keys, not your crypto" mean?',
    options: ['You should memorize your passwords', 'If you don\'t control the private keys, you don\'t truly own the cryptocurrency', 'Exchanges are always safer than personal wallets', 'You need physical keys to access crypto'],
    correctAnswer: 'If you don\'t control the private keys, you don\'t truly own the cryptocurrency',
    moduleId: 'crypto_exchanges',
  ),
  QuizQuestion(
    question: 'What is Dollar-Cost Averaging (DCA) in crypto trading?',
    options: ['Buying only when prices are low', 'Making regular purchases regardless of price to reduce volatility impact', 'Selling everything when market crashes', 'Only trading during certain hours'],
    correctAnswer: 'Making regular purchases regardless of price to reduce volatility impact',
    moduleId: 'crypto_exchanges',
  ),
],
  
};