**##Client Overview**

This repository provides the investor evaluation module for the Evalora platform, built with Flutter. The app delivers an elegant interface for authenticating users, exploring startup profiles, sending evaluation requests, and visualizing analytics—bringing data-driven clarity to the startup investment process.



**##Features**

* Browse and search startup profiles with dynamic filtering.
* Score startups using customizable evaluation metrics.
* View analytics and track evaluation history.
* Secure user authentication and session management.
* Responsive design for mobile and web.



**##Core Dart Modules**

**#Data Models**

1. *user.dart*: Defines the UserModel class capturing user ID, name, and email for authentication and attribution.
2. *startup.dart*: Defines the Startup class containing fields for id, idea, domain, founder, investment score, and funding status.
3. *evaluation\_request.dart*: Implements the EvaluationRequest class and RequestStage enum, managing evaluation lifecycle stages such as submission and scheduling.



**#State Management**

1. *auth\_provider.dart*: Flutter-based state notifier for user authentication, including sign-in and sign-out methods using a mock backend service.
2. *startup\_provider.dart*: Asynchronously fetches the list of available startups for evaluation using the mock service.



**#Services**

1. *mock\_service.dart*: Mock API for development and demo purposes, simulating network delays, generating random startups, tracking evaluation progress, and handling various submit/fetch requests.



**#App Entry and Theme**

1. *main.dart*: Application entry point, initializing Firebase at startup, setting up Riverpod state scope, applying custom themes, and routing to primary screens such as authentication.
2. *theme.dart*: Defines consistent theme and color schemes including Royal Blue, Emerald Green, and Off-white, using Material 3 features for cohesive UI styling across the app.



**##File Structure**

bash

lib/

├─ models/

│    ├─ user.dart

│    ├─ startup.dart

│    ├─ evaluation\_request.dart

├─ api/

│    ├─ mock\_service.dart

├─ providers/

│    ├─ auth\_provider.dart

│    ├─ startup\_provider.dart

├─ main.dart

├─ theme.dart



**##Steps to install:**

1. Ensure Flutter is installed.
2. Clone the repository.
    **#bash**
3. git clone <repository-url>
4. cd <repo-folder>
5. Run dependency installation.
    **#bash**
6. flutter pub get
7. Launch the application.
    **#bash**
8. flutter run



**Customization**

1. Change colors or fonts by editing *theme.dart*.
2. Adjust mock data/services by updating *mock\_service.dart*.



**Contribution**

To contribute, please fork the repository, create a feature branch, and submit a pull request with a clear description.



**License**

Code is released under the MIT License.

