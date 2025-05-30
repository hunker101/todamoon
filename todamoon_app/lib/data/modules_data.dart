class LocalModule {
  final String id;
  final String title;
  final List<LocalLesson> lessons;
  final List<LocalQuizQuestion> quiz;
  final String imagePath;

  LocalModule({
    required this.id,
    required this.title,
    required this.lessons,
    required this.quiz,
    required this.imagePath,
  });

  // Convert LocalModule to Module
  Module toModule() {
    return Module(
      id: id,
      title: title,
      imagePath: imagePath,
      lessons:
          lessons.asMap().entries.map((entry) {
            int index = entry.key;
            LocalLesson localLesson = entry.value;
            return Lesson(
              id: '${id}_lesson_$index',
              title: localLesson.title,
              description: 'Lesson ${index + 1}',
              content: [
                LessonSection(
                  title: localLesson.title,
                  content: localLesson.content,
                ),
              ],
            );
          }).toList(),
    );
  }
}

class LocalLesson {
  final String title;
  final String content;

  LocalLesson({required this.title, required this.content});
}

class LocalQuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  LocalQuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });
}

final List<LocalModule> localModules = [
  LocalModule(
    id: 'crypto1',
    title: 'Introduction',
    imagePath: 'assets/images/bg.png',
    lessons: [
      LocalLesson(
        title: 'What is a cryptocurrency?',
        content: """
What is a cryptocurrency?

Cryptocurrencies have become extremely popular in recent years. Not just online, but everywhere.

You’ve probably even seen TV commercials about cryptocurrencies being the next big thing. And maybe even your favorite actor or athlete promoting them.

But what are they?

How are they different from traditional currencies? What makes them so special?

What are cryptocurrencies?

A cryptocurrency (or “crypto”) is an umbrella term for a new kind of “digital money” that relies on a combination of technologies that allows it to exist outside the control of central authorities like governments and banks.

Cryptocurrencies are digital.

Cryptocurrencies have no physical form. There are no dollar bills or metal coins.

They are completely digital, meaning they’re literally just lines of computer code.

￼

Cryptocurrencies are borderless.

Regardless of where you live or who you are, you can send it almost instantaneously to others anywhere in the world, without concern for geographic distance and country borders.

Cryptocurrencies are borderless. All you need is a device, like a phone or a computer, that’s connected to the internet.

Cryptocurrencies are permissionless.

Anybody can send and receive cryptocurrencies. You don’t need to register an account or fill out an application. Cryptocurrencies are permissionless.

You don’t even need to give your name. Instead of names and account numbers, all you need to provide is a computer-generated string of letters and numbers known as an “address”.

This address is not inherently tied to any of your personal information, so you can theoretically send cryptocurrencies to other people without ever knowing each other’s actual identities.

Since you can send and receive cryptocurrencies without giving any personally identifying information, cryptocurrencies provide some degree of privacy.

Cryptocurrencies are decentralized.

Unlike traditional currencies, also known as “fiat” currencies, such as the U.S. dollar, cryptocurrencies are not connected to any government or central bank.

For example, the U.S. dollar is issued and controlled by the Federal Reserve (“Fed”), the euro by the European Central Bank (ECB), and the Japanese yen by the Bank of Japan (BOJ).

￼

This means that, unlike fiat currencies, cryptocurrencies are not controlled by a central authority. There is no bank or government behind them. This defining feature of cryptocurrencies is known as decentralization.

If no central bank or government issues or creates cryptocurrencies, then who creates them?

Units of a cryptocurrency are generated based on predetermined rules written in code which are executed by software.

￼

One of the most important aspects of cryptocurrencies is their supply since this heavily determines their utility and value.

Depending on the rules written in the code of the software, cryptocurrencies can be created and destroyed. Some cryptocurrencies have a finite (or fixed) total supply, meaning that there is a maximum number of units that will ever be in circulation, creating scarcity.

Others are launched with an infinite total supply, meaning there is no maximum cap! (Although there might be a limit on the number of new units that can be created within a certain timeframe such as every year.)

Cryptocurrencies are counterfeit-proof.

Cryptocurrencies are also designed to be counterfeit-proof.

This is where cryptography is involved and how it’s used to securely record and store transactions.

In cryptography, the prefix “crypt” means “hidden” and the suffix “graphy” means “writing”.

￼

Before computers existed, cryptography was the study of techniques to keep handwritten information safe from prying eyes.

Even Julius Caesar was known to use cryptography to communicate with his generals.

But in the modern age, cryptography is now associated with protecting computer information using fancy math.

Since cryptocurrencies rely on cryptography for their security, that’s where the ”crypto” comes from in “cryptocurrencies.”

What makes cryptocurrencies special?

Cryptocurrencies exist independently from any government, central bank, or other central institution.

In summary, cryptocurrencies are special because:

They are digital. Cryptocurrencies have no physical form. Everything is done from phones and computers.

They are borderless. Anyone with an internet connection can send and receive cryptocurrencies. anywhere in the world, with (usually) smaller fees and faster speeds than traditional money transfers.

They are permissionless and available to everyone. You don’t need to be approved by a bank and have a bank account to use cryptocurrencies. No third party (like a bank) needed to confirm and approve transactions.

They provide some degree of privacy, which means that you can make transactions without using your name. Different cryptocurrencies vary in the degree of anonymity they provide.

They are decentralized, which means governments can’t meddle with or control them. No one person or entity owns or controls them. Users can transact directly without the involvement of any intermediary, which for fiat currencies, would usually be a bank.

They are created by software. The supply of a cryptocurrency is NOT determined by any central bank but based on predefined rules explicitly written in software code. In other words, software replaces the central bank.

They are counterfeit-proof. This is due to the way the transaction information is recorded and stored.

Due to these special characteristics, cryptocurrencies provide the potential to give people total control of their money with zero involvement from a third party.

Whether crypto can live up to this potential remains to be seen. Its popularity in the financial world is growing and is now considered an emerging asset clas
 """,
      ),
      LocalLesson(
        title: 'Crypto as a new asset class',
        content: 'It is decentralized...',
      ),
      LocalLesson(
        title: 'Meet Toshi Moshi',
        content: 'Crypto may revolutionize global finance...',
      ),
      LocalLesson(
        title: 'Getting started with bitcoin',
        content: 'Crypto may revolutionize global finance...',
      ),
    ],
    quiz: [
      LocalQuizQuestion(
        question: 'What is cryptocurrency?',
        options: ['Digital asset', 'Bank', 'Paper money'],
        answer: 'Digital asset',
      ),
    ],
  ),
  LocalModule(
    id: 'crypto2',
    title: 'Bitcoin',
    imagePath: 'assets/images/bg.png',
    lessons: [
      LocalLesson(
        title: 'What is a cryptocurrency?',
        content: 'Cryptocurrency is a digital asset...',
      ),
      LocalLesson(
        title: 'What\'s special about it?',
        content: 'It is decentralized...',
      ),
      LocalLesson(
        title: 'The future of finance',
        content: 'Crypto may revolutionize global finance...',
      ),
    ],
    quiz: [
      LocalQuizQuestion(
        question: 'What is cryptocurrency?',
        options: ['Digital asset', 'Bank', 'Paper money'],
        answer: 'Digital asset',
      ),
    ],
  ),
  LocalModule(
    id: 'crypto3',
    title: 'Cryptocurrency II',
    imagePath: 'assets/images/bg.png',
    lessons: [
      LocalLesson(
        title: 'What is a cryptocurrency?',
        content: 'Cryptocurrency is a digital asset...',
      ),
      LocalLesson(
        title: 'What\'s special about it?',
        content: 'It is decentralized...',
      ),
      LocalLesson(
        title: 'The future of finance',
        content: 'Crypto may revolutionize global finance...',
      ),
    ],
    quiz: [
      LocalQuizQuestion(
        question: 'What is cryptocurrency?',
        options: ['Digital asset', 'Bank', 'Paper money'],
        answer: 'Digital asset',
      ),
    ],
  ),
  LocalModule(
    id: 'crypto4',
    title: 'Cryptocurrency II',
    imagePath: 'assets/images/bg.png',
    lessons: [
      LocalLesson(
        title: 'What is a cryptocurrency?',
        content: 'Cryptocurrency is a digital asset...',
      ),
      LocalLesson(
        title: 'What\'s special about it?',
        content: 'It is decentralized...',
      ),
      LocalLesson(
        title: 'The future of finance',
        content: 'Crypto may revolutionize global finance...',
      ),
    ],
    quiz: [
      LocalQuizQuestion(
        question: 'What is cryptocurrency?',
        options: ['Digital asset', 'Bank', 'Paper money'],
        answer: 'Digital asset',
      ),
    ],
  ),
];

class Module {
  final String id;
  final String title;
  final String imagePath;
  final List<Lesson> lessons;
  final String? description;

  Module({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.lessons,
    this.description,
  });
}

class Lesson {
  final String id;
  final String title;
  final String? description;
  final List<LessonSection> content;

  Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.content,
  });
}

class LessonSection {
  final String? title;
  final String content;
  final List<String>? bulletPoints;

  LessonSection({this.title, required this.content, this.bulletPoints});
}
