**V-Connect MUET: Intelligent Student-Organization Engagement Platform**

1. Introduction
   
V-Connect MUET is a role-based mobile application developed using Flutter to facilitate structured volunteer engagement within the Mehran University of Engineering & Technology (MUET). The system enables seamless interaction between students seeking volunteer opportunities and university organizations offering them. The application ensures efficient communication, streamlined opportunity management, and improved visibility of campus-wide activities.

2. Objective

The primary objective of this application is to provide a unified platform where MUET students can explore, apply for, and participate in volunteer activities, while organizations can efficiently manage postings and applications.

3. Key Features

3.1 Authentication and Role Management

Firebase Authentication for secure login and signup
Role-based navigation distinguishing Students and Organizations
Profile data stored and retrieved dynamically from Cloud Firestore

3.2 Student Module

Student profile creation (skills, interests, department, contact)
Exploration of available volunteer opportunities
One-click application to opportunities
Access to application statuses
In-app notification system
Integrated Dialogflow chatbot for user assistance

3.3 Organization Module

Organization profile setup
Posting, updating, and deleting volunteer opportunities
Reviewing student applications
Accepting or rejecting submissions
Automatic in-app notifications triggered through Firestore

3.4 Notification System

The system employs in-app notifications powered by Firestore triggers.
Notifications are generated for:

New opportunities (sent to students)
Student applications (sent to organizations)
Application status updates (sent to students)

3.5 Chatbot Integration

Dialogflow is integrated to support users by providing automated responses to frequently asked questions and app navigation guidance.

4. System Architecture

The application incorporates Firebase services including Authentication, Firestore Database, and Storage. It follows a role-based architectural flow supported by a Wrapper class for dynamic navigation.

5. Technology Stack

Flutter (Frontend/UI)

Firebase Authentication
Cloud Firestore
Firestore Triggers (In-app notifications)
Firebase Storage
Dialogflow (Chatbot)

6. Limitations

University email verification is not implemented
Push notifications are excluded due to design constraints
System use is limited to MUET’s internal ecosystem

7. Future Scope

Implementation of MUET domain-based email verification
Push notification integration
Calendar synchronization
Organizational analytics
Profile completion progress indicators
Final Year Project
