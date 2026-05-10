## Demo Video

A short demonstration of the AVCI Medical App is available below.

> Note: The GIF preview may take a few seconds to load, depending on the internet connection and GitHub preview speed.

![AVCI Medical App Demo](./demo/project_demo.gif)

[Watch the full demo video](./demo/project_demo.mp4)

If GitHub cannot preview the MP4 directly, click **View raw** on the video page to download and watch the full demo.

The demo shows:

- Doctor registration and login
- Patient creation and search
- AVC dossier creation
- Multi-step AVC form
- PDF report generation
- Gmail/email sharing flow

---

## Application Overview

AVCI Medical App is a Flutter-based medical application developed for the mobile development mini-project.  
It is designed for doctors to manage patients affected by ischemic stroke, create structured AVC medical dossiers, store data locally, and generate professional PDF reports.

The application works without a backend server. All data is saved locally using SQLite, which allows the app to keep functioning even without an internet connection.

### Main Features

- Local doctor registration and login
- Session persistence using SharedPreferences
- Patient management with create, read, update, delete, and search
- Structured AVC dossier management
- Multi-step AVC form based on the medical workflow
- Local SQLite database persistence
- PDF medical report generation
- Gmail/email sharing flow
- Professional dark medical user interface

### Technical Stack

- Flutter
- Dart
- Provider for state management
- SQLite for local persistence
- sqflite_common_ffi_web for browser SQLite support
- SharedPreferences for session storage
- pdf and printing packages for report generation
- url_launcher for Gmail/email sharing

### Project Objective

The objective of this project is to provide a simple, fast, and reliable medical application that helps doctors collect, organize, consult, and export clinical data related to AVCI patients in a hospital context.