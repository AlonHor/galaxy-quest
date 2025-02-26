# Galaxy Quest

Galaxy Quest is an x86-16-bit assembly game featuring Mario in space. This project is a fun and challenging game developed entirely in Assembly language.

## Table of Contents

- [Description](#description)
- [Technologies](#technologies)
- [Setup](#setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Description

Galaxy Quest takes the classic Mario gameplay and transports it to a space setting. Navigate through space, avoid enemies, and consume stars to progress through the game and reach a high score.

## Technologies

- **Assembly**: The entire game is developed using x86-16-bit Assembly language.

## Setup

To set up the project locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/AlonHor/galaxy-quest.git
   ```

2. Navigate to the project directory:
   ```bash
   cd galaxy-quest
   ```

3. Assemble the game using an assembler like TASM inside DOSBox:
   ```bash
   tasm /zn main
   tlink main
   ```

4. (Optional) To run the game, simply specify the file name:
   ```bash
   main
   ```

## Usage

To play Galaxy Quest, run the assembled binary using an x86 emulator or on compatible hardware. Follow the in-game instructions to play the game.

## Contributing

We welcome contributions to the Galaxy Quest project. To contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch with a descriptive name:
   ```bash
   git checkout -b my-feature-branch
   ```
3. Make your changes.
4. Commit your changes with a meaningful commit message:
   ```bash
   git commit -m "Add new feature"
   ```
5. Push your changes to your fork:
   ```bash
   git push origin my-feature-branch
   ```
6. Open a pull request to the `main` branch of the original repository.

## License

This project is licensed under the MIT License.
