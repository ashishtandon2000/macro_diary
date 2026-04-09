# Micro Diary

A Flutter app to track daily food intake with automatic macro calculation using USDA FoodData Central. 

## 🚀 Features

- Add food items with macro tracking (calories, protein, carbs, fats)
- Search food using USDA FoodData Central API
- Auto-fill macros from selected food
- Offline storage using Isar database
- Clean architecture (MVVM + Repository + Usecases)
- Scalable structure for future AI integration

## 🏗️ Architecture

The project follows a feature-first Clean Architecture approach:

- Presentation → UI + ViewModels (Riverpod)
- Domain → Usecases + Repository Contracts
- Data → Repository Implementations + API + Local DB (Isar)

Flow:
UI → ViewModel → Usecase → Repository → (API / Local DB)

## 🧰 Tech Stack

- **Flutter** (UI)
- **Riverpod** (State Management)
- **Isar** (Local Database)
- REST API (USDA FoodData Central)
- Clean Architecture (**MVVM** + Repository pattern)

## ⚙️ Setup

1. Clone the repo
2. Run `flutter pub get`
3. Add your USDA API key in `.env`
4. Run the app

## 🔮 Roadmap

- Migration to Riverpod & clean architecture
- Integration with USDA FoodData API
- Offline-first storage using Isar
- Planned: AI-based macro suggestions, remote sync, analytics

## 💡 Key Learnings

- Implemented clean architecture in Flutter from scratch
- Designed scalable repository pattern with abstraction
- Integrated external APIs with structured data mapping
- Built offline-first app with local caching

Reference

USDA APIs: https://fdc.nal.usda.gov/api-spec/fdc_api.html#/FDC/getFoodsSearch